#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
//#include "mex.h"
/* Kernel to square elements of the array on the GPU */

__global__ void device_dotMul(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N)
{
	
 

	int idx = blockIdx.x*blockDim.x+threadIdx.x;
	//__shared__ float vOut[16];
	if(idx == 0)out[0] = 0;
	
	//if ( idx < N)vOut[idx] = in1[idx]*in2[idx];
	if ( idx < N)out[idx] = in1[idx]*in2[idx];
	__syncthreads();
	
	//if(idx < N)out[0] += vOut[idx];
	
	
	if(idx == 0) {
		
		int i;
		for ( i = 1; i < N; i++ ) {
			//out[0] += vOut[i];
			out[0] += out[i];
		}
	}
	
	__syncthreads();

}

