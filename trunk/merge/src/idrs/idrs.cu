#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"


__host__ size_t smat_size( int cnt_elements, int cnt_cols ) {

    return   ( sizeof(t_ve) + sizeof(t_mindex) ) * cnt_elements
           + sizeof(t_mindex)  * (cnt_cols + 1);
}

extern "C" void idrs(
                     t_mindex N,
                     t_SparseMatrix A_h,

                     t_ve* b_h,
                     t_mindex s,
                     t_ve  tol,
                     t_mindex maxit,
                     t_ve* x0_h,



                     t_ve* x_h,  /* output vector */
                     t_ve* resvec_h,
                     t_mindex* piter
                  ) {
    cudaError_t e;
    size_t h_memblocksize;
    size_t d_memblocksize;

    t_SparseMatrix A_d;

    void *hostmem;
    void *devmem;

    h_memblocksize =   smat_size( A_h.nzmax, A_h.m )  /* A sparse     */
                     + N * sizeof( t_ve )             /* b full       */
                     ;

    d_memblocksize =  h_memblocksize
                    + N * sizeof( t_ve )            /* x             */
                    + N * sizeof( t_ve )            /* resvec        */
                      ;

    printf("\n using N = %u (full vector size )", N );
    printf("\n using %u bytes in Host   memory", h_memblocksize);
    printf("\n using %u bytes in Device memory", d_memblocksize);




    hostmem =   malloc( h_memblocksize );
    if ( hostmem == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you hostmem"); exit( -1 ); }

    e = cudaMalloc ( &devmem , d_memblocksize );
    CUDA_UTIL_ERRORCHECK("cudaMalloc")

    e = cudaMemcpy( devmem, hostmem, h_memblocksize , cudaMemcpyHostToDevice);
    CUDA_UTIL_ERRORCHECK("cudaMemcpyHostToDevice");

    A_d.m = A_h.m;
    A_d.n = A_h.n;
    A_d.nzmax = A_h.nzmax;

    A_d.pCol       = (t_mindex *) devmem;
    A_d.pNZElement = (t_ve *) (&A_d.pCol[A_d.nzmax] ) ;
    A_d.pRow       = (t_mindex *) (&A_d.pNZElement[A_d.nzmax]);


    printf("\n*** IDRS.cu - unimplemented - doing nothing  *** \n");


    e = cudaFree(devmem);
    CUDA_UTIL_ERRORCHECK("cudaFree")
    free( hostmem );

}

