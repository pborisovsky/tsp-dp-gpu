#include<stdio.h>
#include "Binary_operations.h"


int getNextSet(int num)
//returns the next binary number with the same number of ones
{
    int n;
    int k_1=0;
    while (GetBit(num,k_1)==1) {k_1++;};
    n=k_1;
    while (!GetBit(num,n)) n++;
    SetBit0(num,n);
    k_1++;
    n--;
    while (k_1>=1) {
        SetBit1(num,n);
        k_1--;
        n--;
      }
    while (n>=0) {SetBit0(num,n); n--;}
    return num;
}


// Creates an array of bitmaps sorted by the number of ones in a binaty representation.
// Used to enumerate all sets with a given number of elements
unsigned int * createMap(int N, int &totSize)
{

    int s ;
    int size = (1<<N) - 1;      //  = 2^N    
    unsigned int *map =  new unsigned int [2 + N + size+1];
    unsigned int *map1 = map+2+N+1;
    unsigned int *sizeMap = map+2;
    totSize = 2 + N + size+1;

    // fill maps
    map[0] = N;
    map[1] = size;

    int cnt = 0;
     for( s = 1; s  <  N ; s++ ) {
         unsigned int k = 0;
         for(int i = N-1;  i > N - 1 - s; i--) {
                SetBit1(k, i) ;
        }

        map1[cnt] = k;
        sizeMap[s-1] = cnt;
        cnt++;

        int kMin = (1<<s)-1;

        while(k > kMin) {
            k = getNextSet(k);
            map1[cnt] = k;
            cnt++;
        }
     }

 sizeMap[s-1] = cnt;
 sizeMap[s] = cnt+1;
 map1[cnt] = (1<<N) - 1;

 return map;
}


unsigned int computeSizeF(int n)
{
    int N = (1<<(n-2))  ;  // 2^(n-2)
    return n*N ;
}


