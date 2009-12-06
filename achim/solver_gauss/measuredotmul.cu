
#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

#include <time.h>

#include "dotMul_cuda_gpu.h"
#include "dotMul_cpu.h"
#include <time.h>

#define N_PROBLEM 50000
#define ITERSTEPS 2

__host__ void malloc_N( unsigned int size_n, t_ve** M ) {

    t_ve* v =  (t_ve*) malloc( sizeof(t_ve) * size_n  );
    if ( v == NULL) {
	       fprintf(stderr, "sorry, can not allocate memory for you");
	       exit( -1 );
    }
    *M = v;

}



__host__ void malloc_vector_on_device(  t_ve** pV_d, unsigned int L ) {
	cudaError_t e;

    e = cudaMalloc ((void **) pV_d, sizeof(t_ve) * L );
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMalloc: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

    cudaMemset ( *pV_d, 0, sizeof(t_ve) * L );
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on memset 0: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

}


int main()
{
    printf("\n measureing operation DOTMUL with N = %u, ITERSTEPS %u", N_PROBLEM, ITERSTEPS );

    t_ve* v1;
    t_ve* v2;

    t_ve* v1_d;
    t_ve* v2_d;

    t_ve* out ;  /* output vector */
    t_ve* out_d;

    int block_size = 512;


    clock_t startclocks;
    clock_t endclock;

    clock_t payoffstart;
    clock_t payoffend;


    clock_t startclockscpu;
    clock_t endclockscpu;

    cudaError_t e;

    malloc_N( N_PROBLEM * 3 , &v1 );
    //malloc_N( N_PROBLEM  , &v2 );
    //malloc_N( N_PROBLEM  , &out );






    for ( unsigned long N = 1; N < N_PROBLEM; N *= 5 ) {

		/* ------------------------------------------------------------ */



    payoffstart = clock();

        malloc_vector_on_device( &v1_d , N * 3 );

        v2_d  = &v1_d[N    ];
        out_d = &v1_d[N * 2];

        e = cudaMemcpy(  v1_d, v1, sizeof(t_ve) * N * 2 , cudaMemcpyHostToDevice);
        if( e != cudaSuccess )
        {
            fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
            exit(-3);
        }

        payoffend = clock();


        startclocks = clock( );
        for ( int i = 0; i < ITERSTEPS; i++ ) {
            dim3 dimBlock(block_size);
            dim3 dimGrid ( N / block_size + 1 );
            device_dotMul<<<dimGrid,dimBlock>>>(v1_d, v2_d, out_d, N );
        	e = cudaGetLastError();
			if( e != cudaSuccess ) {
			       fprintf(stderr, "CUDA Error on add_arrays_gpu: '%s' \n", cudaGetErrorString(e));
			       exit(-3);
            }
        }
        endclock = clock( );

        e = cudaFree(v1_d);
        if( e != cudaSuccess )
        {
            fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
            exit(-3);
        }
        /* ------------------------------------------------------------ */
		startclockscpu = clock( );
		for ( int i = 0; i < ITERSTEPS; i++ ) {
		    v1[1]++; /* ensure opearation is not answerde from cache */
		    dotMul_cpu(v1, v2, out, N );
		}
        endclockscpu   = clock( );
        /* ------------------------------------------------------------ */

        printf( "\n ----------------------------------------------------- \n N = %u", N );
	    printf( "\n GPU: %f seconds,  clocks: %u : CLOCKS_PER_SEC %u \n", ( (float) ( endclock - startclocks)) / CLOCKS_PER_SEC / ITERSTEPS, endclock - startclocks, CLOCKS_PER_SEC );
	    printf( "\n CPU: %f seconds,  clocks: %u : CLOCKS_PER_SEC %u \n", ( (float) ( endclockscpu - startclockscpu)) / CLOCKS_PER_SEC / ITERSTEPS, endclockscpu - startclockscpu, CLOCKS_PER_SEC );
	    printf( "\n cudamemcopy payoff %f secsonds (%u clocks)", (float) (payoffend - payoffstart) / CLOCKS_PER_SEC, payoffend - payoffstart );
    }
}