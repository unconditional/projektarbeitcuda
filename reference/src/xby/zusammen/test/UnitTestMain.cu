/*
UnitTestMain
*/

#include <stdio.h>
//#include "host_dotMul.h"
#include "host_dotMul.cu"
//#include "host_norm.h"
#include "host_norm.cu"
#include "host_matrixMul.cu"

int main()
{
	 //test_matrixMul();
     test_dotMul();
	 //test_norm();
	 return 1;
}
