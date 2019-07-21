#include <fstream>
#include "Problem.h"

using  namespace std;

void Problem::LoadFromFile(ifstream &in)
{
   in >> n;
   int i,j;
   a = new float*[n];

   for(i = 0; i < n; i++)
   {
    a[i] = new float[n];
    for(j = 0; j < n; j++)
     {
       in >> a[i][j];
     }
   }
}


Problem::~Problem()
{
   for(int i = 0; i < n; i++)
   {
    delete[] a[i];
   }
   delete[] a;
}