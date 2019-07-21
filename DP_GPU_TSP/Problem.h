
using namespace std;

class Problem
{
public:
	int n;       // No of cities
	float **a;   // distances
   
	void LoadFromFile(ifstream &in);
	~Problem();

};