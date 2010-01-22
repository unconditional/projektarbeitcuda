#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
#include "project_comm.h"
//#include "mex.h"
/*
 release :dotMul_cuda_gpu05
 Kernel to square elements of the array on the GPU 
*/

__global__ void device_dotMul(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N)
{
	__shared__ float Cs[VECTOR_BLOCK_SIZE];
	
	int tid = threadIdx.x;
	int idx = blockIdx.x*blockDim.x + tid;
	
	Cs[threadIdx.x] = 0;

	if ( idx < N ) {
	    Cs[threadIdx.x] = in1[ idx ] * in2[ idx ];
	}
	__syncthreads();
	
	t_ve blocksum = 0;
	
	int offset; 
	offset = VECTOR_BLOCK_SIZE/2;
	while (offset > 0) {
		if(tid < offset) {
			Cs[tid] += Cs[tid + offset];
		}
		offset >>= 1;
		__syncthreads();
	}
	/*
	if(tid < 256) {Cs[tid] += Cs[tid + 256];}
	__syncthreads();
	if(tid < 128) {Cs[tid] += Cs[tid + 128];}
	__syncthreads();
	if(tid < 64) {Cs[tid] += Cs[tid + 64];}
	__syncthreads();
	if(tid < 32) {Cs[tid] += Cs[tid + 32];}
	__syncthreads();
	if(tid < 16) {Cs[tid] += Cs[tid + 16];}
	__syncthreads();
	if(tid < 8) {Cs[tid] += Cs[tid + 8];}
	__syncthreads();
	if(tid < 4) {Cs[tid] += Cs[tid + 4];}
	__syncthreads();
	if(tid < 2) {Cs[tid] += Cs[tid + 2];}
	__syncthreads();
	if(tid < 1) {Cs[tid] += Cs[tid + 1];}
	__syncthreads();
	*/
	
	out[blockIdx.x]=0;
	out[blockIdx.x]=Cs[0];
	__syncthreads();
	
	////block summe in cpu
	/*
	if ( idx == 0 ) {
	     for ( int i = 1; i < gridDim.x; i++ ) {
		     out[0] += out[i];
		 }
	}
	*/
}