#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"
#include "measurehelp.h"

#define ITERATIONS 5

__host__ void malloc_N( unsigned int size_n, t_ve** M ) {

    t_ve* v =  (t_ve*) malloc( sizeof(t_ve) * size_n  );
    if ( v == NULL) {
           fprintf(stderr, "sorry, can not allocate memory for you");
           exit( -1 );
    }
    *M = v;
}

/* ----------------------------------------------------------------- */
__global__ void summup_kernel_triangle( t_ve *in, t_ve *out, unsigned int N ) {
    __shared__ t_ve Vs [DEF_BLOCKSIZE];

    Vs[threadIdx.x] = in[threadIdx.x];
    __syncthreads();

/*
    unsigned short t = 1;
    for ( t = 1 << BLOCK_EXP - 1; t > 1; t >>= 1 ) {
        __syncthreads();
        if ( threadIdx.x < t ) {
            Vs[threadIdx.x] += Vs[ threadIdx.x + t ];
        }
    }
    __syncthreads();
    if ( threadIdx.x == 0 ) { out[0] = Vs[0] + Vs[t]; }
*/

    int offset = 1;
    for (  int i = 1; i < BLOCK_EXP ; i++ ) {
         int old = offset;
        offset <<= 1;
        if ( threadIdx.x % offset == 0 ) {

           Vs[threadIdx.x] += Vs[ threadIdx.x + old ];
        }
        __syncthreads();
    }
    if ( threadIdx.x == 0 ) { out[0] = Vs[0] + Vs[offset]; }

}
/* ----------------------------------------------------------------- */
__global__ void summup_kernel_triangle_warpop( t_ve *in, t_ve *out, unsigned int N ) {
    __shared__ t_ve Vs [DEF_BLOCKSIZE];


    Vs[threadIdx.x] = in[threadIdx.x];


    __syncthreads();
    if ( threadIdx.x < 256 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  | 256 ]; }
    //if ( threadIdx.x < 256 ) { Vs[threadIdx.x] = in[threadIdx.x] + in[threadIdx.x + 256]; }
    __syncthreads();

    if ( threadIdx.x < 128 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  | 128 ];}
    __syncthreads();

    if ( threadIdx.x <  64 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  |  64 ];}
    __syncthreads();

    if ( threadIdx.x <  32 ) { Vs[threadIdx.x ] += Vs[ threadIdx.x  |  32 ];}
    __syncthreads();

    if ( threadIdx.x <  16 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  | 16 ]; }
    __syncthreads();

    if ( threadIdx.x <   8 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  | 8 ]; }
    __syncthreads();

//    if ( threadIdx.x <   4 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  | 4 ]; }
//    __syncthreads();

//    if ( threadIdx.x <   2 ) { Vs[threadIdx.x] += Vs[ threadIdx.x  | 2 ]; }
//    __syncthreads();


    if ( threadIdx.x == 0 ) {
        t_ve sum = 0;
        for ( short int i = 0; i < 8; i++ ) {
            sum += Vs[i];
        }
        out[0] =  sum;
    }

}
/* ----------------------------------------------------------------- */

__global__ void summup_kernel_for( t_ve *in, t_ve *out, unsigned int N ) {
    __shared__ t_ve v [DEF_BLOCKSIZE];
    t_ve blocksum = 0;

    v[threadIdx.x] = in[threadIdx.x];
    __syncthreads();

    if ( threadIdx.x == 0 ) {
        for ( int i = 0; i < N; i++ ) {
           blocksum += v[i];
        }
        out[0] = blocksum;
    }
}
/* ----------------------------------------------------------------- */

__host__ void summup_cpu( t_ve *in, t_ve *out, unsigned int N ) {
    t_ve sum = 0;
    for ( int i = 0; i < N; i++ ) {
       sum += in[i];
    }
    out[0] = sum;
}
/* ----------------------------------------------------------------- */

int main()
{
    cudaError_t e;



    printf("\n triangle adder,  \nrunning with %u iterations per kernel call \n\n", ITERATIONS);

    t_ve* in;

    t_ve  out;

    t_ve  outgpu_for;
    t_ve  outgpu_triangle;
    t_ve*  outgpu_d;

/*
    short offset =  1;
    for ( short i = 0; i < BLOCK_EXP ; i++ ) {
        short old = offset;
        offset <<= 1;
        printf("\n step: %u. offset %u old %u", i, offset, old );
    }
*/
    short offset = 1;
    for ( short t = 1 << BLOCK_EXP - 1; t > 1; t >>= 1 ) {
        printf("\n threadlimit %u, offset %u", t, offset );
        offset <<= 1;
    }

    malloc_N( DEF_BLOCKSIZE , &in );

    for ( int i = 0; i < DEF_BLOCKSIZE; i++ ) {
       in[i] = 10;
    }

    float cpu_ms;

    {
       START_CUDA_TIMER
       for  ( int i = 0; i < ITERATIONS; i++ ) {
           summup_cpu( in, &out, DEF_BLOCKSIZE );
       }
       STOP_CUDA_TIMER( &cpu_ms )

    }
    //printf("\n\n got from CPU calc: %f", out);

/*  --------------------------------------------------  */
    t_ve* devicemem;
    e = cudaMalloc ((void **) &devicemem, sizeof(t_ve) * (DEF_BLOCKSIZE + 1) );
    CUDA_UTIL_ERRORCHECK("cudaMalloc &devicemem");

    outgpu_d = &devicemem[DEF_BLOCKSIZE];

    e = cudaMemcpy(  devicemem, in, sizeof(t_ve) * (DEF_BLOCKSIZE), cudaMemcpyHostToDevice);
    CUDA_UTIL_ERRORCHECK("cudaMemcpy v1_d");

    dim3 dimGrid ( 1 );
    dim3 dimBlock(DEF_BLOCKSIZE);

        /* "warming up", not measured */
    for  ( int i = 0; i < 20; i++ ) {
            summup_kernel_triangle<<<dimGrid,dimBlock>>>( devicemem, outgpu_d, DEF_BLOCKSIZE);
            e = cudaGetLastError();
            CUDA_UTIL_ERRORCHECK("summup_kernel_triangle");

            summup_kernel_triangle_warpop<<<dimGrid,dimBlock>>>( devicemem, outgpu_d, DEF_BLOCKSIZE);
            e = cudaGetLastError();
            CUDA_UTIL_ERRORCHECK("summup_kernel_triangle");

    }

    float kernelfor_ms, kerneltriangle_ms, kerneltrianglewarpop_ms;

    {
        START_CUDA_TIMER
        for  ( int i = 0; i < ITERATIONS; i++ ) {
            summup_kernel_for<<<dimGrid,dimBlock>>>( devicemem, outgpu_d, DEF_BLOCKSIZE);
            e = cudaGetLastError();
            CUDA_UTIL_ERRORCHECK("summup_kernel_for");
        }
        STOP_CUDA_TIMER( &kernelfor_ms )
    }
    e = cudaMemcpy( &outgpu_for, outgpu_d, sizeof(t_ve) , cudaMemcpyDeviceToHost);

    CUDA_UTIL_ERRORCHECK("&outgpu_for, outgpu_dd");
    //printf("\n\n got from GPU for: %f", outgpu_for);
    printf("\n>>> GPU 'for' runtime: %f ms", kernelfor_ms / ITERATIONS );

    {
        START_CUDA_TIMER
        for  ( int i = 0; i < ITERATIONS; i++ ) {
            summup_kernel_triangle<<<dimGrid,dimBlock>>>( devicemem, outgpu_d, DEF_BLOCKSIZE);
            e = cudaGetLastError();
            CUDA_UTIL_ERRORCHECK("summup_kernel_triangle");
        }
        STOP_CUDA_TIMER( &kerneltriangle_ms )
    }
    e = cudaMemcpy( &outgpu_triangle, outgpu_d, sizeof(t_ve) , cudaMemcpyDeviceToHost);

    CUDA_UTIL_ERRORCHECK("&outgpu_for, outgpu_dd");
    printf("\n\n got from GPU triangle: %f", outgpu_triangle );
    {
        START_CUDA_TIMER
        for  ( int i = 0; i < ITERATIONS; i++ ) {
            summup_kernel_triangle_warpop<<<dimGrid,dimBlock>>>( devicemem, outgpu_d, DEF_BLOCKSIZE);
            e = cudaGetLastError();
            CUDA_UTIL_ERRORCHECK("summup_kernel_triangle");
        }
        STOP_CUDA_TIMER( &kerneltrianglewarpop_ms )
    }

    e = cudaMemcpy( &outgpu_triangle, outgpu_d, sizeof(t_ve) , cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK("&outgpu_triangle, outgpu_dd");
    printf("\n\n got from GPU triangleop: %f", outgpu_triangle );
    printf("\n>>> GPU 'triangle' runtime: %f ms", kerneltriangle_ms / ITERATIONS );
    printf("\n>>> GPU 'triangleop' runtime: %f ms", kerneltrianglewarpop_ms  / ITERATIONS );

    printf("\n\n runtime of 'triangle' is %f percent of 'for(...)' runtime \n\n", 100 / kernelfor_ms * kerneltriangle_ms );
    printf("\n\n runtime of 'trianglewarpop' is %f percent of 'for(...)' runtime \n\n", 100 / kernelfor_ms * kerneltrianglewarpop_ms );

    e = cudaFree(devicemem);
    CUDA_UTIL_ERRORCHECK("cudaFree")

    printf("\n runtime on CPU: %f ms \n", cpu_ms / ITERATIONS  );

   printf("\n\n runtime of 'triangleop' is %f percent of 'cpu' runtime \n\n", 100 / cpu_ms * kerneltrianglewarpop_ms );

/*  --------------------------------------------------  */


}

