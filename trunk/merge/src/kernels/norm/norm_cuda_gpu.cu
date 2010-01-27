#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"



__global__ void kernel_norm(t_ve* in,t_ve* out )
{
    __shared__ t_ve Vs [DEF_BLOCKSIZE];


    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    Vs[threadIdx.x] = in[idx] * in[idx];


    __syncthreads();
    if ( threadIdx.x < 256 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  + 256 ]; }
    __syncthreads();

    if ( threadIdx.x < 128 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  + 128 ];}
    __syncthreads();

    if ( threadIdx.x <  64 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  +  64 ];}
    __syncthreads();


#ifndef PRJCUDAEMU

    if ( threadIdx.x <  32 ) {
        Vs[threadIdx.x] += Vs[ threadIdx.x + 32 ];
        Vs[threadIdx.x] += Vs[ threadIdx.x + 16 ];
        Vs[threadIdx.x] += Vs[ threadIdx.x +  8 ];
        Vs[threadIdx.x] += Vs[ threadIdx.x +  4 ];
        Vs[threadIdx.x] += Vs[ threadIdx.x +  2 ];
        Vs[threadIdx.x] += Vs[ threadIdx.x +  1 ];

        if ( threadIdx.x == 0 ) {
            //out[blockIdx.x] =  Vs[0]  ;
            out[blockIdx.x] =  Vs[0]  ;
        }
    }

#endif

#ifdef PRJCUDAEMU

    if ( threadIdx.x <  32 )
        Vs[threadIdx.x] += Vs[ threadIdx.x + 32 ];
    __syncthreads();
    if ( threadIdx.x <  16 )
        Vs[threadIdx.x] += Vs[ threadIdx.x + 16 ];
    __syncthreads();
    if ( threadIdx.x <  8 )
        Vs[threadIdx.x] += Vs[ threadIdx.x +  8 ];
    __syncthreads();
    if ( threadIdx.x <  4 )
        Vs[threadIdx.x] += Vs[ threadIdx.x +  4 ];
    __syncthreads();
    if ( threadIdx.x <  2 )
        Vs[threadIdx.x] += Vs[ threadIdx.x +  2 ];
    __syncthreads();
    if ( threadIdx.x <  1 )
        Vs[threadIdx.x] += Vs[ threadIdx.x +  1 ];
    __syncthreads();
        if ( threadIdx.x == 0 ) {
            //out[blockIdx.x] =  Vs[0]  ;
            out[blockIdx.x] =  Vs[0]  ;
        }


#endif

}

