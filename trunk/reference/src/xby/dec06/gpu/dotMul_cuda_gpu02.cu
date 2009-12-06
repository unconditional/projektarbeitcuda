#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
#include "project_comm.h"
//#include "mex.h"
/* Kernel to square elements of the array on the GPU */

__global__ void device_dotMul(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N)
{
	//define a Result Vector for each block
	__shared__ float Cs[VECTOR_BLOCK_SIZE];
	// get a thread indentifier
	int idx = blockIdx.x*blockDim.x+threadIdx.x;
	//initialise Cs
	Cs[threadIdx.x] = 0;
	// compute scalar product
	if ( idx < N ) {
	    Cs[threadIdx.x] = in1[ idx ] * in2[ idx ];
	}

	t_ve blocksum = 0;
	
	//initialize output vector for each block
	if(threadIdx.x==0){
		out[blockIdx.x]=0;
	}
	__syncthreads();
	
	//compute summe of all thread's results for each block 
	if(threadIdx.x==0){
	    for ( int i = 0; i < blockDim.x; i++ ) {
		     blocksum += Cs[i];
		}
		out[blockIdx.x]=blocksum;
	}
	__syncthreads();
	
	//compute the sume of all block's result for the grid
	
	if ( idx == 0 ) {
	     for ( int i = 1; i < gridDim.x; i++ ) {
		     out[0] += out[i];
		 }
	}

}