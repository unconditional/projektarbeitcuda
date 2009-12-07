#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

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

    short offset = 1;
    for ( short i = 0; i < BLOCK_EXP ; i++ ) {
        short old = offset;
        offset <<= 1;
        if ( threadIdx.x % offset == 0 ) {
           Vs[threadIdx.x] += Vs[ threadIdx.x + old ];
        }
        __syncthreads();
    }

    if ( threadIdx.x == 0 ) {
        out[0] = Vs[0];
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
    printf("\n triangle adder \n");

    t_ve* in;

    t_ve  out;

    t_ve  outgpu_for;
    t_ve  outgpu_triangle;
    t_ve*  outgpu_d;

    short offset =  1;
    for ( short i = 0; i < BLOCK_EXP ; i++ ) {
        short old = offset;
        offset <<= 1;
        printf("\n step: %u. offset %u old %u", i, offset, old );
    }
    malloc_N( DEF_BLOCKSIZE , &in );

    for ( int i = 0; i < DEF_BLOCKSIZE; i++ ) {
       in[i] = 10;
    }

    summup_cpu( in, &out, DEF_BLOCKSIZE );
    printf("\n\n got from CPU calc: %f", out);

/*  --------------------------------------------------  */
    t_ve* devicemem;
    e = cudaMalloc ((void **) &devicemem, sizeof(t_ve) * (DEF_BLOCKSIZE + 1) );
    CUDA_UTIL_ERRORCHECK("cudaMalloc &devicemem");

    outgpu_d = &devicemem[DEF_BLOCKSIZE];

    e = cudaMemcpy(  devicemem, in, sizeof(t_ve) * (DEF_BLOCKSIZE), cudaMemcpyHostToDevice);
    CUDA_UTIL_ERRORCHECK("cudaMemcpy v1_d");

    dim3 dimGrid ( 1 );
    dim3 dimBlock(DEF_BLOCKSIZE);

    summup_kernel_for<<<dimGrid,dimBlock>>>( in, outgpu_d, DEF_BLOCKSIZE);
    e = cudaGetLastError();
    CUDA_UTIL_ERRORCHECK("summup_kernel_for");
    e = cudaMemcpy( &outgpu_for, outgpu_d, sizeof(t_ve) , cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK("&outgpu_for, outgpu_dd");
    printf("\n\n got from GPU for: %f", outgpu_for);

    summup_kernel_triangle<<<dimGrid,dimBlock>>>( in, outgpu_d, DEF_BLOCKSIZE);
    e = cudaGetLastError();
    CUDA_UTIL_ERRORCHECK("summup_kernel_triangle");
    e = cudaMemcpy( &outgpu_triangle, outgpu_d, sizeof(t_ve) , cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK("&outgpu_for, outgpu_dd");
    printf("\n\n got from GPU triangle: %f", outgpu_triangle);

    e = cudaFree(devicemem);
    CUDA_UTIL_ERRORCHECK("cudaFree")
/*  --------------------------------------------------  */


}

