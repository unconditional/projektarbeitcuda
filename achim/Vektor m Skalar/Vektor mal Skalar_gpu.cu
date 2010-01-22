#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
//#include "mex.h"
/* Kernel to square elements of the array on the GPU */
// 

__global__ void device_skalarMul(t_ve* pin1, t_ve in2,t_ve* out, unsigned int N)
{
	
	int idx = blockIdx.x*blockDim.x+threadIdx.x;
	out[idx] = 0;
	__syncthreads();
	
	if ( idx < N)out[idx] = pin1[idx]*in2;
	__syncthreads();
	
}

