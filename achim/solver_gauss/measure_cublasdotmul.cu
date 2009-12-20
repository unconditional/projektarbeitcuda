#include <stdlib.h>
#include <stdio.h>

#include "cublas.h"

#include "projektcuda.h"
#include "measurehelp.h"

#include "dotMul_cpu.h"


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

    cublasStatus ce;
    ce = cublasInit();

    for ( int N = 1; N < 10000000; N *= 10 ) {

    malloc_N( N * 3 , &hostmem );

    t_ve* in1 = &hostmem[0];
    t_ve* in2 = &hostmem[N];
    t_ve* out = &hostmem[N*2];

    for ( int i = 0; i < N; i++ ) {
       in1[i] = 1;
       in2[i] = 2;
    }

    if ( ce != CUBLAS_STATUS_SUCCESS ) { printf("<<<CUBLAS error>>>"); exit( -3); }

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
    float cublas_ms, cpu_ms;
    float dm;
    {
        START_CUDA_TIMER
        for ( int i = 0; i < 20; i++ ) {
            dm = cublasSdot( N, d_in1, 1, d_in2, 1 );
        }
        STOP_CUDA_TIMER( &cublas_ms )
    }

    {
        START_CUDA_TIMER
        for ( int i = 0; i < 20; i++ ) {
            dotMul_cpu(in1, in2, out, N );
        }
        STOP_CUDA_TIMER( &cpu_ms )
    }



    printf( "\n N = %u, time spent cublas: %f ms time CPU %f", N ,cublas_ms, cpu_ms);

    ce = cublasFree( d_in2 );
    ce = cublasFree( d_in1 );

    free( hostmem );

    }
    ce = cublasShutdown();
}
