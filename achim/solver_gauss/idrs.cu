

#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"
#include "idrs.h"

__host__ void push_vector_2_device( t_ve* V,  t_ve** pV_d, unsigned int L ) {
	cudaError_t e;

    e = cudaMalloc ((void **) pV_d, sizeof(t_ve) * L );
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMalloc: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
    e = cudaMemcpy(  V, *pV_d, sizeof(t_ve) * L , cudaMemcpyDeviceToHost);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
}

__host__ void idrs(
                     t_ve* A_h,
                     t_ve* b_h,
                     t_ve* s_h,
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

   printf("\n empty IDRS, malloc \n");

   push_vector_2_device( A_h, &A, N * N );
   push_vector_2_device( b_h, &b, N );
   push_vector_2_device( x_h, &x, N );

}

