
#include "projektcuda.h"



__global__ void kernel_dotmul( t_ve *in1,
                               t_ve *in2,
                               t_ve *out
                             ) {
    __shared__ t_ve Vs [DEF_BLOCKSIZE];


    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    Vs[threadIdx.x] = in1[idx] * in2[idx];


    __syncthreads();
    if ( threadIdx.x < 256 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  + 256 ]; }
    __syncthreads();

    if ( threadIdx.x < 128 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  + 128 ];}
    __syncthreads();

    if ( threadIdx.x <  64 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  +  64 ];}
    __syncthreads();


    if ( threadIdx.x <  32 ) {
        Vs[threadIdx.x] += Vs[ threadIdx.x + 32 ];
        Vs[threadIdx.x] += Vs[ threadIdx.x + 16 ];
        Vs[threadIdx.x] += Vs[ threadIdx.x +  8 ];
        Vs[threadIdx.x] += Vs[ threadIdx.x +  4 ];
        Vs[threadIdx.x] += Vs[ threadIdx.x +  2 ];
        Vs[threadIdx.x] += Vs[ threadIdx.x +  1 ];

        if ( threadIdx.x == 0 ) {
            out[blockIdx.x] =  Vs[0]  ;
        }
    }
}

