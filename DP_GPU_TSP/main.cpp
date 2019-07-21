#include <stdio.h>
#include <fstream>
#include "problem.h"
using namespace std;

float solve(Problem *p, int *tour);

int main(int argc, char* argv[])
{
    Problem P;
	ifstream in(argv[1]);
    P.LoadFromFile(in);
    in.close();

	int* tour = new int[P.n];
    float cost = solve(&P, tour);

	printf("tour ");
    for(int i = 0; i < P.n; i++)
    {
      printf(" %i", tour[i]);
    }
	printf("  cost %f\n", cost);
    return 0;
}
