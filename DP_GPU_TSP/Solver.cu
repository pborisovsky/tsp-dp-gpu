#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <fstream>
#include "Binary_operations.h"
#include "Problem.h"

#define DropBit(h,z) (h=(((h)&devPattern1[z])>>1) | ((h)&devPattern2[z]))

#define MAX_N 32
#define MAX_COST 1000000

unsigned int * createMap(int N, int &totSize);
unsigned int computeSizeF(int);


__global__ void kernelInit(int n,unsigned int* devPattern1, unsigned int* devPattern2)
{
  int i,j;
  int m = n-1;
  for(i = 0; i < m; i++)
  {  
    devPattern2[i]=(1 << i)-1; 
    j=(1 << m-i-1)-1;  
    devPattern1[i]=j<<(i+1);
  } 
}

//------------------------------------------------------------------------------

__global__ void kernelFirst(
                           int n,                     
                           float *setup,
                           float* f,
                           unsigned int* devPattern1, unsigned int* devPattern2
                           )
{
    int i = blockIdx.x; // city
    int j = threadIdx.x; // subset

    if(i == j)
      return;

    int s = 1<<j;
    DropBit(s,i);

    f[s*n + i] = setup[i*n+j] + setup[j*n+(n-1)];
} 

//------------------------------------------------------------------------------

__global__ void kernelStep(
                           int n,  
                           int nS,                                            
                           float *setup,                
                           float *f,
                           unsigned int* map,
                           int ne,                      // number of '1'
                           unsigned int* devPattern1, 
                           unsigned int* devPattern2
                           )
{
    int i = threadIdx.x;   //city
    unsigned int is =  blockIdx.x * gridDim.y + blockIdx.y ;                   
    is=blockDim.y * is + threadIdx.y;  // index of the set in binary map of sets
    if(is >= nS || i >= n)
      return;

    int N = map[0];
    unsigned int *valMap = map+2+N+1;
    int spB = map[1 + ne] ;
    unsigned int s = valMap[spB + is];  // now f(s,i) is to be computed

    if(GetBit(s,i) == 1)
      return;
    
    float *iSetup = setup + i*n;

    int j; 
    float dmin = MAX_COST;
    // loop over elements in set s
    for(j = 0; j < n-1; j++)
    {
       if(GetBit(s,j) == 0 )
         continue;

       unsigned int curS = s;
       DropBit(curS, j);
       float cj = iSetup[j] + f[curS*n + j];    // corresponds to  a_ij + f(S\j, j)
       if(cj < dmin)
         dmin = cj;
    }

    DropBit(s,i);
    f[s*n+i]=dmin;      
} 

//------------------------------------------------------------------------------

__global__ void kernelGetTour(
                           int n,                                               
                           float *setup,                
                           float *f,
                           int* tour,
                           unsigned int* devPattern1, 
                           unsigned int* devPattern2
                           )
{
  int i, ic, j, k, imin;
  float dmin;
  unsigned int s=(1<<(n-1))-1; // binary string of type 11...1
  
  int m = n-1;
  int c[MAX_N];
  for(i=0;i<m;i++)
  {
    c[i]=i;
  }
  
  float part_cost=0;
 
  int prev = n-1;
  for(k = 0; k < n-1; k++)  
  {    
    dmin=MAX_COST; 
    for(ic = 0; ic < m; ic++)
    {
      i=c[ic];
      j=prev;  // previous city in a tour
      unsigned int curS=s;
      DropBit(curS,i);
      float d = part_cost + setup[j*n + i] + f[curS * n + i];
      if(d<dmin)
      {
        dmin=d;
        imin=ic;
      }
    }
   
    i=c[imin];
    tour[k]=i;
    SetBit0(s,i);
    c[imin] = c[m-1];
    part_cost += setup[prev*n + i];
    prev=i;       
    m--;
  }
  tour[n-1]=n-1;
}

//------------------------------------------------------------------------------

float solve(Problem *p, int *tour) {

	int i, n;
    n = p->n;     

    unsigned int fSize = computeSizeF(n);    
    printf("\nmemory use %iM\n", fSize*sizeof(int)/1024/1024);
    
    float* devF;
    cudaMalloc(   (void**)&devF,    fSize * sizeof(float)   );

    int mapSize;
    unsigned int *map = createMap(n-1, mapSize);
    unsigned int* devMap;
    cudaMalloc((void**)&devMap, mapSize * sizeof(int) );
    cudaMemcpy(devMap,    map,  mapSize * sizeof(int), cudaMemcpyHostToDevice);
    
    // distances
    float *s1 = new float [n*n];
    int k=0;
    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            s1[k] = p->a[i][j];
            k++;
        }
    }

    float *devS1;
    cudaMalloc((void**)&devS1, n * n * sizeof(float) );
    cudaMemcpy(devS1,    s1,   n * n * sizeof(float), cudaMemcpyHostToDevice);
       
    unsigned int *sizeMap = map+2;
	float* F = new float[fSize];
	
	unsigned int* devPattern1;
	unsigned int* devPattern2;
	cudaMalloc((void**)&devPattern1, n * sizeof(int) );
	cudaMalloc((void**)&devPattern2, n * sizeof(int) );
      
    cudaEvent_t start, stop;       
    float gpuTime = 0.0f;    

    cudaEventCreate(&start); 
    cudaEventCreate(&stop) ; 
    cudaEventRecord ( start, 0 ); 
      
    kernelInit<<<1, 1>>>(n,devPattern1,devPattern2);

    // solve for number of ones equal 1
    kernelFirst<<<n-1, n-1>>>(
                            n,
                            devS1,              
                            devF,
                            devPattern1,
                            devPattern2
                          );

    // main cycle: iterate over sets cardinality (number of ones in a binary representation)
    for(int ne = 2; ne <= n-2;  ne++)    
    {
        int nS = sizeMap[ne] - sizeMap[ne-1]; // number of sets of cardinality "ne"  

        int blocksPart = 256;
        int divisor=16;
        int  nThr = nS  /  blocksPart;       
        if(nS % blocksPart > 0)
           nThr++;       
                       
        dim3 blocks  = dim3(blocksPart/divisor, nThr);
        dim3 threads = dim3(n-1, divisor);        

	    kernelStep<<<blocks,threads>>>(
                           n,  
                           nS,                                             
                           devS1,                     
                           devF,
                           devMap,
                           ne,                      // number of '1'                           
                           devPattern1, devPattern2
                           );
         
    } 

    int* devTour;
    cudaMalloc((void**)&devTour, n * sizeof(int));

    kernelGetTour<<<1, 1>>>(n, devS1, devF, devTour, devPattern1, devPattern2);
    cudaMemcpy(tour, devTour, n * sizeof(int), cudaMemcpyDeviceToHost);
    
    float cost=0;
    for(i=0;i<n-1;i++)
    {
      cost += p->a[tour[i]][tour[i+1]];
    }
    cost += p->a[tour[n-1]][tour[0]];
        
    cudaEventRecord ( stop, 0 ); 
    cudaEventSynchronize (stop) ; 
    cudaEventElapsedTime(&gpuTime, start, stop ); 
    printf("time spent executing by the GPU: %.2f  millseconds\n", gpuTime ); 
    cudaEventDestroy(start);
    cudaEventDestroy(stop); 

  	cudaFree(devS1);
    cudaFree(devMap);
    cudaFree(devF);
    cudaFree(devTour);
    cudaFree(devPattern1);
    cudaFree(devPattern2);

    return cost;
 }
