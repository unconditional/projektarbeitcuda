#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
#include "project_comm.h"
//#include "mex.h"
/* Kernel to square elements of the array on the GPU */

/**/
__global__ void device_scalarMul(t_ve* pIn1, t_ve* pIn2,t_ve* pOut, unsigned int N)
{
	//__shared__ float Cs[VECTOR_BLOCK_SIZE];
	
	int tid = threadIdx.x;
	int idx = blockIdx.x*blockDim.x + tid;
	
	//Cs[threadIdx.x] = 0;

	if ( idx < N ) {
	    //Cs[threadIdx.x] = pin1[ idx ] * in2;
		pOut[idx] = pIn1[idx]*pIn2[0];
	}

}