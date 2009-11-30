

#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"
#include "idrs.h"

__host__ void push_vector_2_device( t_ve* V,  t_ve** pV_d, unsigned int L ) {
	cudaError_t e;

	t_ve* Vd;

    e = cudaMalloc ((void **) pV_d, sizeof(t_ve) * L );
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMalloc: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
    e = cudaMemcpy(  *pV_d, V, sizeof(t_ve) * L , cudaMemcpyHostToDevice);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
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




__host__ void idrs(
                     t_ve* A_h,
                     t_ve* b_h,
                     unsigned int s,
                     t_ve  tol,
                     unsigned int maxit,
                     t_ve* x0_h,

                     unsigned int N,

                     t_ve* x_h,  /* output vector */
                     t_ve* resvec_h,
                     unsigned int* piter
                  ) {


   t_ve* A;    /* A in device , A_h is Host */
   t_ve* b;
   t_ve* x;

   t_ve* dR;
   t_ve* dX;

   printf("\n empty IDRS, malloc \n");

   push_vector_2_device( A_h, &A, N * N );
   push_vector_2_device( b_h, &b, N );
   push_vector_2_device( x_h, &x, N );

   /* m20:  dR = zeros(N,s); dX = zeros(N,s); */
   malloc_vector_on_device( &dR, N * s );
   malloc_vector_on_device( &dX, N * s );

}

