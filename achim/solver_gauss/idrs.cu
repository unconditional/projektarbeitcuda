

#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"
#include "idrs.h"

__host__ void idrs(
                     t_ve* A,
                     t_ve* b,
                     t_ve* s,
                     t_ve  tol,
                     unsigned int maxit,
                     t_ve* x0,

                     unsigned int N,

                     t_ve* x,  /* output vector */
                     t_ve* resvec,
                     unsigned int* piter
                  ) {

   int bla;
   bla = 0;
   t_ve* A_d; /* A in device */

   printf("\n empty IDRS, malloc \n");

    cudaError_t e;
    e = cudaMalloc ((void **) &A_d, sizeof(t_ve) * N * N );
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMalloc: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

}

