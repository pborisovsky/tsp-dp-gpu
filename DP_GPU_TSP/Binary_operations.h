#define GetBit(k,l)  (( (k) & ( 1 << (l) ) ) >> (l))   // get bit #l in k
#define SetBit1(k,l) ((k)=(k) | ( 1 << (l) ))         // set bit #l in k to 1
#define SetBit0(k,l) ((k)=(k) & (~( 1 << (l))))     // set bit #l in k to 0