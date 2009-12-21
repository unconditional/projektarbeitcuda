#include <stdlib.h>
#include <stdio.h>

#include "cublas.h"

#include "projektcuda.h"
#include "measurehelp.h"

#include "dotMul_cpu.h"


__global__ void kernel_dotmul( t_ve *in1, t_ve *in2, t_ve *out ) {
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



__host__ void own_dotmul(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N) {

     int gridsize =  ( N / (DEF_BLOCKSIZE) ) + 1;

     //printf("\n N is %u, gridsize %u", N, gridsize);

     dim3 dimGrid ( gridsize );
     dim3 dimBlock(DEF_BLOCKSIZE);

     cudaError_t e;


     kernel_dotmul<<<dimGrid,dimBlock>>>( in1, in2, out );
     e = cudaGetLastError();
     CUDA_UTIL_ERRORCHECK("summup_kernel_kernel_dotmul");

     int bla = 0;
}

__host__ void malloc_N( unsigned int size_n, t_ve** M ) {

    t_ve* v =  (t_ve*) malloc( sizeof(t_ve) * size_n  );
    if ( v == NULL) {
           fprintf(stderr, "sorry, can not allocate memory for you");
           exit( -1 );
    }
    *M = v;
}
int main()
{
    t_ve* hostmem;

    printf("\n measure CUBLAS dotmul\n");


    int deviceCount;
    cudaGetDeviceCount(&deviceCount);

    if (deviceCount == 0)
        printf("There is no device supporting CUDA\n");

    int dev;
    for (dev = 0; dev < deviceCount; ++dev) {
        cudaDeviceProp deviceProp;
        cudaGetDeviceProperties(&deviceProp, dev);

        printf("  Number of multiprocessors:                     %d\n", deviceProp.multiProcessorCount);

        printf("\nDevice %d: \"%s\"\n", dev, deviceProp.name);
        printf("  CUDA Capability Major revision number:         %d\n", deviceProp.major);
        printf("  CUDA Capability Minor revision number:         %d\n", deviceProp.minor);
        printf("  Maximum number of threads per block:           %d\n", deviceProp.maxThreadsPerBlock);
    }

    cublasStatus ce;

    ce = cublasInit();

    if ( ce != CUBLAS_STATUS_SUCCESS ) { printf("<<<error on cublasInit>>>"); exit( -3); }

    for ( int N = 10; N < 100000000; N *= 10 ) {

    malloc_N( ( N + 512) * 3 , &hostmem );

    t_ve* in1 = &hostmem[0];
    t_ve* in2 = &hostmem[N + 512];
    t_ve* out = &hostmem[ (N + 512 ) *2  ];

    for ( int i = 0; i < N; i++ ) {
       in1[i] = 1;
       in2[i] = 2;
    }



    t_ve* d_in1;
    ce = cublasAlloc( N, sizeof(t_ve), (void**)&d_in1 );
    if ( ce != CUBLAS_STATUS_SUCCESS ) { printf("<<<CUBLAS erroralloc>>>"); exit( -3); }

    t_ve* d_in2;
    ce = cublasAlloc( N, sizeof(t_ve), (void**)&d_in2 );
    if ( ce != CUBLAS_STATUS_SUCCESS ) { printf("<<<CUBLAS erroralloc>>>"); exit( -3); }

    ce = cublasSetVector( N, sizeof(t_ve), in1, 1, d_in1, 1 );
    if ( ce != CUBLAS_STATUS_SUCCESS ) { printf("<<<CUBLAS erroralloc cublasSetVector>>>"); exit( -3); }

    ce = cublasSetVector( N, sizeof(t_ve), in2, 1, d_in2, 1 );
    if ( ce != CUBLAS_STATUS_SUCCESS ) { printf("<<<CUBLAS erroralloc cublasSetVector>>>"); exit( -3); }

    cudaError_t e;
    float cublas_ms, cpu_ms, gpu_ms;
    float dm;
    {
        START_CUDA_TIMER
        for ( int i = 0; i < 2; i++ ) {
            dm = cublasSdot( N, d_in1, 1, d_in2, 1 );
        }
        STOP_CUDA_TIMER( &cublas_ms )
    }

    {
        START_CUDA_TIMER
        for ( int i = 0; i < 2; i++ ) {
            dotMul_cpu(in1, in2, out, N );
        }
        STOP_CUDA_TIMER( &cpu_ms )
    }

    ce = cublasFree( d_in2 );
    ce = cublasFree( d_in1 );

/* -------------------------------------------------------- */
    {
        t_ve* devicemem;
        e = cudaMalloc ((void **) &devicemem, sizeof(t_ve) * ( N + 512 ) * 3 );
        CUDA_UTIL_ERRORCHECK("cudaMalloc")

        e = cudaMemcpy(  devicemem, hostmem, sizeof(t_ve) * ( N + 512) * 2 , cudaMemcpyHostToDevice);
        CUDA_UTIL_ERRORCHECK("cudaMemcpy")

        t_ve* din1 = &devicemem[0];
        t_ve* din2 = &devicemem[N + 512 ];
        t_ve* dout = &devicemem[(N + 512) * 2];

        {
            START_CUDA_TIMER
            for ( int i = 0; i < 2; i++ ) {
                own_dotmul(din1, din2, dout, N );
            }
            STOP_CUDA_TIMER( &gpu_ms )
        }

        e = cudaFree(devicemem);
        CUDA_UTIL_ERRORCHECK("cudaFree")
    }

/* -------------------------------------------------------- */

    printf( "\n N = %u, time spent cublas: %f ms time CPU %f ms -- GPU %f ms", N ,cublas_ms, cpu_ms, gpu_ms);



    free( hostmem );

    }
    ce = cublasShutdown();
}
