#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
#include "project_comm.h"
//#include "mex.h"
/* Kernel to square elements of the array on the GPU */

__global__ void device_dotMul(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N)
{
	__shared__ float Cs[VECTOR_BLOCK_SIZE];
	int idx = blockIdx.x*blockDim.x+threadIdx.x;
	
	Cs[threadIdx.x] = 0;

	if ( idx < N ) {
	    Cs[threadIdx.x] = in1[ idx ] * in2[ idx ];
	}

	t_ve blocksum = 0;
	
	if(threadIdx.x==0){
		out[blockIdx.x]=0;
	}
	__syncthreads();
	
	if(threadIdx.x==0){
		int kEnd = N-(blockIdx.x*VECTOR_BLOCK_SIZE);
				if(kEnd > VECTOR_BLOCK_SIZE)kEnd = VECTOR_BLOCK_SIZE;
	    //for ( int i = 1; i < blockDim.x; i++ ) {
		for ( int i = 1; i < kEnd; i++ ) {
		     Cs[0] += Cs[i];
		}
		out[blockIdx.x]=Cs[0];
	}
	__syncthreads();
	if ( idx == 0 ) {
	     for ( int i = 1; i < gridDim.x; i++ ) {
		     out[0] += out[i];
		 }
	}

}