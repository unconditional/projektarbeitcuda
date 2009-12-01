/*
UnitTestMain
*/

#include <stdio.h>
#define GPU 1
#ifdef GPU
#include "host_dotMul.cu"
#include "host_norm.cu"
#include "host_matrixMul.cu"
#else

#endif //ifdef GPU
int main()
{
	 //test_matrixMul();
     test_dotMul();
	 //test_norm();
	 return 1;
}
