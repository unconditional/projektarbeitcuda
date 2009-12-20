#include <stdlib.h>
#include <stdio.h>

#include "cublas.h"

#include "projektcuda.h"

#define NMAX 1000


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

    malloc_N( NMAX * 2 , &hostmem );

    t_ve* in1 = &hostmem[0];
    t_ve* in2 = &hostmem[NMAX];

    for ( int i = 0; i < NMAX; i++ ) {
       in1[i] = 1;
       in2[i] = 2;
    }
    cublasStatus ce;
    ce = cublasInit();
    if ( ce != CUBLAS_STATUS_SUCCESS ) { printf("<<<CUBLAS error>>>"); exit( -3); }

    t_ve* d_in1;
    ce = cublasAlloc( NMAX, sizeof(t_ve), (void**)&d_in1 );
    if ( ce != CUBLAS_STATUS_SUCCESS ) { printf("<<<CUBLAS erroralloc>>>"); exit( -3); }

    t_ve* d_in2;
    ce = cublasAlloc( NMAX, sizeof(t_ve), (void**)&d_in2 );
    if ( ce != CUBLAS_STATUS_SUCCESS ) { printf("<<<CUBLAS erroralloc>>>"); exit( -3); }

    ce = cublasSetVector( NMAX, sizeof(t_ve), in1, 1, d_in1, 1 );
    if ( ce != CUBLAS_STATUS_SUCCESS ) { printf("<<<CUBLAS erroralloc cublasSetVector>>>"); exit( -3); }

    ce = cublasSetVector( NMAX, sizeof(t_ve), in2, 1, d_in2, 1 );
    if ( ce != CUBLAS_STATUS_SUCCESS ) { printf("<<<CUBLAS erroralloc cublasSetVector>>>"); exit( -3); }

    float dm = cublasSdot( NMAX, d_in1, 1, d_in2, 1 );

    printf("\nresult dotmul: %f", dm );

    ce = cublasFree( d_in2 );
    ce = cublasFree( d_in1 );
    ce = cublasShutdown();
}
