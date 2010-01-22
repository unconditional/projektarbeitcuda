#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"


__host__ void idrs(
                     t_SparseMatrix A_h,
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

    printf("unimplemented - do nothing");

}

