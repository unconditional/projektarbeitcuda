#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
#include "project_comm.h"
//#include "mex.h"
/*
	release norm_cuda_gpu02
 Kernel to square elements of the array on the GPU
 */


__global__ void norm_elements(t_ve* in,t_ve* out, unsigned int N)
{
	__shared__ float Cs[VECTOR_BLOCK_SIZE];
	int idx = blockIdx.x*blockDim.x+threadIdx.x;
	
	Cs[threadIdx.x] = 0;

	if ( idx < N ) {
	    Cs[threadIdx.x] = in[ idx ] * in[ idx ];
	}

	t_ve blocksum = 0;
	
	if(threadIdx.x==0){
		out[blockIdx.x]=0;
	}
	__syncthreads();
	
	if(threadIdx.x==0){
	    for ( int i = 0; i < blockDim.x; i++ ) {
		     blocksum += Cs[i];
		}
		out[blockIdx.x]=blocksum;
	}
	__syncthreads();
	if ( idx == 0 ) {
	     for ( int i = 1; i < gridDim.x; i++ ) {
		     out[0] += out[i];
		 }
		out[0] = sqrt(out[0]); 
	}

}