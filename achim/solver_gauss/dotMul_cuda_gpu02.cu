
#include "projektcuda.h"

#include <stdio.h>
#include <device_functions.h>

__device__ unsigned int count = 0;
__shared__ bool isLastBlockDone;
__global__ void device_dotMul(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N)
{
	__shared__ float Cs[512];
	int idx = blockIdx.x*blockDim.x+threadIdx.x;

	Cs[threadIdx.x] = 0;

	if ( idx < N ) {
	    Cs[threadIdx.x] = in1[ idx ] * in2[ idx ];
	}

	t_ve blocksum = 0;

	__syncthreads();

	if(threadIdx.x==0){
	    for ( int i = 0; i < blockDim.x; i++ ) {
		     blocksum += Cs[i];
		}
		out[blockIdx.x]=blocksum ;
    }
     __threadfence();
    if(threadIdx.x==0){
        unsigned int value = atomicInc( &count, gridDim.x );
        isLastBlockDone = ( value == ( gridDim.x -1 ) );
    }
    __syncthreads();
    if(threadIdx.x==0){
         if ( isLastBlockDone ) {
             for ( int i = 1; i < gridDim.x; i++ ) {
                 out[0] += out[i];
             }
        }
    }
}

