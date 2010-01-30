#include <stdlib.h>
#include <stdio.h>
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


__host__ void dbg_dotmul_checkresult ( t_ve *in1,
                                       t_ve *in2,
                                       t_ve tobeckecked,
                                       t_mindex N ,
                                       char* debugname
                                      )

                          {

    cudaError_t e;


    t_ve* v1 = (t_ve*) malloc( sizeof( t_ve* ) * N );
    if (  v1 == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you C"); exit( -1 ); }

    t_ve* v2 = (t_ve*) malloc( sizeof( t_ve* ) * N );
    if (  v2 == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you C"); exit( -1 ); }

    e = cudaMemcpy( v1, in1, sizeof(t_ve) * N , cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");

    e = cudaMemcpy( v2, in2, sizeof(t_ve) * N, cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");

    t_ve calresult = 0;

    for( t_mindex i = 0; i < N; i++ ) {
        calresult += v1[i] * v2[i];
    }
    if ( abs( calresult - tobeckecked ) > 0.001 ) {
//        printf("\n Dotmul %s OK", debugname );
//    }
//    else {
        printf("\n Dotmul %s *not‹ OK :  expected %f, got %f", debugname , calresult, tobeckecked );
        exit( - 1 );
    }

    free(v1);
    free(v2);

}

