#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

#include "kernels/sparseMatrixMul_kernel.h"


extern "C" size_t idrs_sizetve() {
  return sizeof(t_ve);
}


__host__ size_t smat_size( int cnt_elements, int cnt_cols ) {

    return   ( sizeof(t_ve) + sizeof(t_mindex) ) * cnt_elements
           + sizeof(t_mindex)  * (cnt_cols + 1);
}


__global__ void testsparseMatrixMul( t_FullMatrix pResultVector,t_SparseMatrix pSparseMatrix, t_FullMatrix b ) {

    t_mindex tix = blockIdx.x * blockDim.x + threadIdx.x;
    if ( tix  < pSparseMatrix.m ) {
        //printf ( "\n block %u thread %u tix %u N %u", blockIdx.x, threadIdx.x, tix, pSparseMatrix.m );
        //printf("\n %u %f", tix, b.pElement[tix] );
        pResultVector.pElement[tix] = b.pElement[tix] - 1;
    }
    if ( tix == 0 ) {
        for ( t_mindex i = 0; i < pSparseMatrix.m + 1 ; i++ ) {
             printf("\n pRow[%u] =  %u", i, pSparseMatrix.pRow[i] );
        }
        for ( t_mindex i = 0; i < pSparseMatrix.nzmax ; i++ ) {
            printf("\n pNZElement[%u] =  %f", i, pSparseMatrix.pNZElement[i] );
        }
        for ( t_mindex i = 0; i < pSparseMatrix.nzmax ; i++ ) {
            printf("\n pCol[%u] =  %u", i, pSparseMatrix.pCol[i] );
        }
    }

}


__host__ void set_sparse_data( t_SparseMatrix A_in, t_SparseMatrix* A_out, void* mv ) {

    A_out->m     = A_in.m;
    A_out->n     = A_in.n;
    A_out->nzmax = A_in.nzmax;

    A_out->pCol       = (t_mindex *)  mv;
    A_out->pNZElement = (t_ve *)     (&A_out->pCol[A_out->nzmax] ) ;
    A_out->pRow       = (t_mindex *) (&A_out->pNZElement[A_out->nzmax]);

}

extern "C" void idrs_1st(

                     t_SparseMatrix A_in,    /* A Matrix in buyu-sparse-format */
                     t_ve*          b_in,    /* b as in A * b = x */

                     t_mindex N,

                     t_ve*          r_out,    /* the r from idrs.m line 6 : r = b - A*x; */

                     t_idrshandle*  ih_out  /* handle for haloding all the device pointers between matlab calls */

           ) {

    cudaError_t e;
    size_t h_memblocksize;
    size_t d_memblocksize;

    t_SparseMatrix A_d;

    t_ve* d_tmpAb;
    t_ve* d_b;

    void *hostmem;
    void *devmem;

    h_memblocksize =   smat_size( A_in.nzmax, A_in.m )  /* A sparse     */
                     + N * sizeof( t_ve )             /* b full       */
                     ;

    d_memblocksize =  h_memblocksize
                    + N * sizeof( t_ve )            /* d_tmpAb         */
                    + N * sizeof( t_ve )            /* x             */
                    + N * sizeof( t_ve )            /* resvec        */
                      ;

    printf("\n using N = %u (full vector size )", N );
    printf("\n using %u bytes in Host   memory", h_memblocksize);
    printf("\n using %u bytes in Device memory", d_memblocksize);



    hostmem =   malloc( h_memblocksize );
    if ( hostmem == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you hostmem"); exit( -1 ); }

/*
      pcol       |  t_mindex  |  .nzmax
      pNZElement |  t_ve      |  .nzmax
      pRow       |  t_mindex  |  N
      b          |  t_ve      |  N
      d_tmpAb    |  t_ve      |  N
*/

    /* copy all parameter vectors to ony monoliythic block starting at hostmem */

    t_mindex *pcol = (t_mindex *) hostmem;
    memcpy( pcol, A_in.pCol, A_in.nzmax * sizeof(t_mindex) );

    t_ve* pNZElement =  (t_ve *) &pcol[A_in.nzmax] ;
    memcpy( pNZElement, A_in.pNZElement, A_in.nzmax *  sizeof(t_ve) );

    t_mindex* pRow = (t_mindex *) (&pNZElement[A_in.nzmax]);
    memcpy( pRow, A_in.pRow, ( A_in.m + 1 ) *  sizeof(t_mindex) );

    t_ve* b = (t_ve *) &pRow[A_in.m + 1];
    memcpy( b, b_in,  N *  sizeof(t_ve) );

    e = cudaMalloc ( &devmem , d_memblocksize );
    CUDA_UTIL_ERRORCHECK("cudaMalloc")

    e = cudaMemcpy( devmem, hostmem, h_memblocksize , cudaMemcpyHostToDevice);
    CUDA_UTIL_ERRORCHECK("cudaMemcpyHostToDevice");

    set_sparse_data(  A_in, &A_d, devmem );
    d_b     = (t_ve *) &A_d.pRow[A_in.m + 1];
    d_tmpAb = (t_ve *) &d_b[N];


    dim3 dimGrid ( 10 );
    dim3 dimBlock(512);

    /* --------------------------------------------------------------------- */

    t_FullMatrix mb;
    t_FullMatrix result;

    mb.m        = N;
    mb.n        = 1;
    mb.pElement = d_b;

    result.pElement = d_tmpAb;
    result.m    = N ;
    result.n    = 1;
    //testsparseMatrixMul<<<dimGrid,dimBlock>>>( result, A_d, mb );
    sparseMatrixMul<<<dimGrid,dimBlock>>>( result, A_d, mb );
    e = cudaGetLastError();
    CUDA_UTIL_ERRORCHECK("testsparseMatrixMul");

    /* --------------------------------------------------------------------- */
    e = cudaMemcpy( r_out, d_tmpAb, sizeof(t_ve) * N, cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK("cudaMemcpyDeviceToHost");

    printf("\n*** IDRS.cu - unimplemented - doing nothing  *** \n");


    printf("\n first call of idrs_1st - unimplemented \n\n " );

}


