#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

#include "kernels/sparseMatrixMul_kernel.h"
#include "kernels/dotMul_cuda_gpu.h"
#include "kernels/norm_cuda_gpu.h"
#include "kernels/gausskernel.h"

#include "bastianortho.h"

#include "kernels/matrixMul_kernel.h"

typedef struct idrs_context {
    void*          devmem1stcall;
    t_SparseMatrix A;
    t_ve*          b;
    t_ve*          r;
    t_ve*          v;
    t_ve*          x;

    t_ve*          om1;
    t_ve*          om2;

} t_idrs_context;


static t_idrs_context ctxholder[4];

extern "C" size_t idrs_sizetve() {
  return sizeof(t_ve);
}


__host__  void testortholinkcompileonly() {

    t_ve dummyRes;
    t_ve dummyP;
    orthogonalize( &dummyP, &dummyRes, 12345, 6 );
}

__global__ void kernel_vec_mul_skalar( t_ve *invec, t_ve scalar, t_ve *out, t_mindex N )
{
    t_mindex i = threadIdx.y * blockDim.x + threadIdx.x;
    if ( i < N )
        out[i] = invec[i] * scalar;
}


__global__ void sub_arrays_gpu( t_ve *in1, t_ve *in2, t_ve *out, t_mindex N)
{
    t_mindex i = threadIdx.y * blockDim.x + threadIdx.x;
    if ( i < N )
        out[i] = in1[i] - in2[i];

}

__global__ void sub_and_mul_arrays_gpu(
                                         t_ve *in1,
                                         t_ve *in2,
                                         t_ve coefficient,
                                         t_ve *out,
                                         t_mindex N
                                        )
{
    t_mindex i = threadIdx.y * blockDim.x + threadIdx.x;
    if ( i < N )
        out[i] = in1[i] - coefficient * in2[i];

}


__global__ void add_and_mul_arrays_gpu(
                                         t_ve *in1,
                                         t_ve *in2,
                                         t_ve coefficient,
                                         t_ve *out,
                                         t_mindex N
                                        )
{
    t_mindex i = threadIdx.y * blockDim.x + threadIdx.x;
    if ( i < N )
        out[i] = in1[i] + coefficient * in2[i];

}



__global__ void add_arrays_gpu( t_ve *in1, t_ve *in2, t_ve *out, t_mindex N)
{
    t_mindex i = threadIdx.y * blockDim.x + threadIdx.x;
    if ( i < N )
        out[i] = in1[i] + in2[i];
}

__host__ size_t smat_size( int cnt_elements, int cnt_cols ) {

    return   ( sizeof(t_ve) + sizeof(t_mindex) ) * cnt_elements
           + sizeof(t_mindex)  * (cnt_cols + 1);
}


extern "C" void idrs2nd(
    t_FullMatrix P_in,
    t_ve tol,
    unsigned int s,
    unsigned int maxit,
    t_idrshandle ih_in, /* Context Handle we got from idrs_1st */
    t_ve* x,
    t_ve* resvec,
   unsigned int* piter
) {
    cudaError_t e;
    t_idrshandle ctx;


    t_FullMatrix mv;
    t_FullMatrix mr;
    t_FullMatrix mt;

    int cnt_multiprozessors;
    int deviceCount;
    cudaGetDeviceCount(&deviceCount);

    t_ve* om1;
    t_ve* om2;
    t_ve* v;

    t_mindex resveci  = 1;
    void* devmem;

    if (deviceCount == 0)
        printf("There is no device supporting CUDA\n");

    int dev;
    for (dev = 0; dev < deviceCount; ++dev) {
        cudaDeviceProp deviceProp;
        cudaGetDeviceProperties(&deviceProp, dev);
        printf("  Number of multiprocessors:                     %d\n", deviceProp.multiProcessorCount);
        cnt_multiprozessors = deviceProp.multiProcessorCount;
    }

    printf("\n 2nd context handle %u", ih_in );
    printf("do nothing");

    ctx = ih_in;

    t_SparseMatrix A         = ctxholder[ctx].A ;

    t_mindex N = A.m;

    size_t h_memblocksize =   N * sizeof( t_ve )            /* om1             */
                            + N * sizeof( t_ve )            /* om2             */
                            + N * sizeof( t_ve )            /* debugbuffer1    */
                            + N * sizeof( t_ve )            /* h_norm    */
                            ;

    size_t d_memblocksize =  (N*s )       * sizeof( t_ve )           /* P      */
                           + s * (s + 1 + 1 )       * sizeof( t_ve )           /* M m c    */
                           + ( N + 512 )  * sizeof( t_ve )            /* v      */
                           + (N*s )       * sizeof( t_ve )            /* dR     */
                           + (N*s )       * sizeof( t_ve )            /* dX     */
                           + (N )         * sizeof( t_ve )            /* dR_k   */
                           + (N )         * sizeof( t_ve )            /* dX_k   */
                           + (N )         * sizeof( t_ve )            /* dnormv   */
                           + (N )         * sizeof( t_ve )            /* q   */
                           + (N + 512 )   * sizeof( t_ve )            /* t   */
                           + (N + 512    ) * sizeof( t_ve )           /* buffer1   */
                           + (N + 512    ) * sizeof( t_ve )           /* dm   */
//                           + (N ) * sizeof( t_ve )                  /* x   */
                      ;

    e = cudaMalloc ( &devmem , d_memblocksize );
    CUDA_UTIL_ERRORCHECK("cudaMalloc");

    e = cudaMemset (devmem, 0, d_memblocksize );
    CUDA_UTIL_ERRORCHECK("cudaMalloc");

    printf("\n additional using %u bytes in Device memory", d_memblocksize);

    t_ve* P      = (t_ve*) devmem ;
    t_ve* M      = &P[ N * s ];
    t_ve* m      = &M[ s * s ];
    t_ve* c      = &M[ s  ];
    v            = &c[ s  ];
    t_ve* dR     = &v[N + 512 ];
    t_ve* dX     = &dR[ N * s ];
    t_ve* dR_k   = &dX[ N * s ];
    t_ve* dX_k   = &dR_k[ N  ];
    t_ve* dnormv = &dX_k[ N  ];
    t_ve* q      = &dnormv[ N  ];
    t_ve* t      = &q[ N  ];
    t_ve* buffer1 = &t[N + 512 ];
    t_ve* dm      = &buffer1[N + 512 ];

    x          = ctxholder[ctx].x;

    void* hostmem =   malloc( h_memblocksize );
    if ( hostmem == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you hostmem"); exit( -1 ); }

    t_ve*  h_om1        = (t_ve*) hostmem;
    t_ve*  h_om2        = &h_om1[N];
    t_ve*  debugbuffer1 = &h_om2[N];
    t_ve*  h_norm        = &debugbuffer1[N];

    t_ve norm;


    mr.m        = A.m;
    mr.n        = 1;
    mr.pElement = ctxholder[ctx].r;

    mt.m        = A.m;
    mt.n        = 1;
    mt.pElement = t;


    t_ve* r = mr.pElement;

    mv.m        = A.m;
    mv.n        = 1;
    mv.pElement = v ;

    om1 = ctxholder[ctx].om1;
    om2 = ctxholder[ctx].om2;

    dim3 dimGrid ( cnt_multiprozessors );
    dim3 dimBlock(512);
    dim3 dimGridsub( A.m / 512 + 1 );

    dim3 dimGridgauss( 1 );
    dim3 dimBlockgauss(512);

    t_ve som ;

    for ( int k = 1; k <= s; k++ ) {

        dR_k = &dR[ N * (k-1) ];
        dX_k = &dX[ N * (k-1) ];

        /* idrs.m line 23 */
        sparseMatrixMul<<<dimGrid,dimBlock>>>( mv, A, mr );
        e = cudaGetLastError();
        CUDA_UTIL_ERRORCHECK("testsparseMatrixMul");


        e = cudaStreamSynchronize(0);
        CUDA_UTIL_ERRORCHECK("cudaStreamSynchronize(0)");

/*
        if ( N < 200 ) {
            e = cudaMemcpy( debugbuffer1, mv.pElement, sizeof(t_ve) * N , cudaMemcpyDeviceToHost);
            CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");
            if ( k == 1 ) {
               for ( t_mindex i = 0; i < N; i++ )
               printf("\n k = 1, mv.pElement[%u] = %f", i, debugbuffer1[i]);
            }
        }
*/
        kernel_dotmul<<<dimGridsub,dimBlock>>>( v, r, om1 ) ;
        e = cudaGetLastError();
        CUDA_UTIL_ERRORCHECK("device_dotMul");

        e = cudaStreamSynchronize(0);
        CUDA_UTIL_ERRORCHECK("cudaStreamSynchronize(0)");

/*
        if ( N < 200 ) {
            e = cudaMemcpy( debugbuffer1, om1, sizeof(t_ve) * N , cudaMemcpyDeviceToHost);
            CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");
            if ( k == 1 ) {
               for ( t_mindex i = 0; i < N; i++ )
               printf("\n k = 1, om1[%u] = %f", i, debugbuffer1[i]);
            }
        }
*/
        kernel_dotmul<<<dimGridsub,dimBlock>>>( mv.pElement, mv.pElement, om2 ) ;
        //kernel_dotmul<<<vdimGridsub,dimBlock>>>( ctxholder[ctx].b, ctxholder[ctx].b, om2 ) ;
        e = cudaGetLastError();
        CUDA_UTIL_ERRORCHECK("device_dotMul");

        e = cudaStreamSynchronize(0);
        CUDA_UTIL_ERRORCHECK("cudaStreamSynchronize(0)");

        e = cudaMemcpy( h_om1, om1, sizeof(t_ve) * N * 2, cudaMemcpyDeviceToHost);
        CUDA_UTIL_ERRORCHECK("cudaMemcpy( h_om1, om1, sizeof(t_ve) * N * 2, cudaMemcpyDeviceToHost)");

        t_ve  som1 = 0;
        t_ve  som2 = 0;
        for ( t_mindex blockidx = 0; blockidx < A.m / 512 + 1; blockidx++ ) {
            som1 += h_om1[blockidx];
            som2 += h_om2[blockidx];
        }
        som = som1 / som2;



        kernel_vec_mul_skalar<<<dimGridsub,dimBlock>>>( mr.pElement,   som , dX_k, N );
        e = cudaGetLastError();
        CUDA_UTIL_ERRORCHECK("kernel_vec_mul_skalar<<<dimGridsub,dimBlock>>>( mr.pElement,   som , dX_k, N )");

        kernel_vec_mul_skalar<<<dimGridsub,dimBlock>>>( mv.pElement, - som , dR_k, N );
        e = cudaGetLastError();
        CUDA_UTIL_ERRORCHECK("kernel_vec_mul_skalar<<<dimGridsub,dimBlock>>>( mv.pElement, - som , dR_k, N )");


        e = cudaStreamSynchronize(0);
        CUDA_UTIL_ERRORCHECK("cudaStreamSynchronize(0)");

        add_arrays_gpu<<<dimGridsub,dimBlock>>>( x, dX_k, x, N );
        e = cudaGetLastError();
        CUDA_UTIL_ERRORCHECK("add_arrays_gpu<<<dimGridsub,dimBlock>>>( x, dX_k, x, N )");

        add_arrays_gpu<<<dimGridsub,dimBlock>>>( mr.pElement, dR_k, mr.pElement, N );
        e = cudaGetLastError();
        CUDA_UTIL_ERRORCHECK("add_arrays_gpu<<<dimGridsub,dimBlock>>>( mr.pElement, dR_k, mr.pElement, N );");


        kernel_norm<<<dimGridsub,dimBlock>>>( mr.pElement, dnormv );
        e = cudaGetLastError();
        CUDA_UTIL_ERRORCHECK("kernel_norm<<<dimGridsub,dimBlock>>>( mr.pElement, dnormv )");


        e = cudaMemcpy( h_norm, dnormv, sizeof(t_ve) * N , cudaMemcpyDeviceToHost);
        CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");

        t_ve snorm = 0;
        for ( t_mindex i = 0; i < N / 512 + 1 ; i++ ) {
             snorm +=  h_norm[i];
        }
        norm = snorm;
        resvec[ resveci++ ]  = sqrt( norm );

        /* 28    M(:,k) = P*dR(:,k); */

        t_ve* Mk = &M[ s * (k-1) ];
        matrixMul<<<dimGrid,dimBlock>>>( P, dR_k , Mk, s, 1 ); /*  :-/  :-/ :-/ :-( */
        e = cudaGetLastError();
        CUDA_UTIL_ERRORCHECK("matrixMul<<<dimGrid,dimBlock>>>( P, r , m, s, 1 )");


        printf("\n iteration %u,    1 %f   2 %f", k , som1, som2 );

        e = cudaStreamSynchronize(0);
        CUDA_UTIL_ERRORCHECK("cudaStreamSynchronize(0)");
    }


    t_mindex iter   = s; /* iter.m line 31 */
    t_mindex oldest = 0; /* iter.m line 32 */


    /*
     *
     *  33   m = P* r   - we need a Matrixmul that can deal with P(s,N)   (mA = s = 6 << N) :-/
     *
     *
     */

    matrixMul<<<dimGrid,dimBlock>>>( P, r , m, s, 1 ); /*  */
    e = cudaGetLastError();
    CUDA_UTIL_ERRORCHECK("matrixMul<<<dimGrid,dimBlock>>>( P, r , m, s, 1 )");


    while (  (norm > tol ) && ( iter < maxit )  ) {
        for ( t_mindex k = 0; k <= s; k++ ) {

           t_ve* dRoldest = &dR[ oldest  * N ];
           t_ve* dXoldest = &dX[ oldest  * N ];

           /* c = M\n  iter.m line 36 */
           device_gauss_solver<<<dimGridgauss,dimBlockgauss>>>( M, s, c ); /* vec m is s+1 column of M - see memory allocation plan  */
           e = cudaGetLastError();
           CUDA_UTIL_ERRORCHECK("device_gauss_solver<<<dimGridgauss,dimBlockgauss>>>( M, s, c )");


           /* q = -dR * c */
           matrixMul<<<dimGrid,dimBlock>>>( q, dR , c, N, 1 ); /* the - is missing */
           e = cudaGetLastError();
           CUDA_UTIL_ERRORCHECK("matrixMul<<<dimGridgauss,dimBlockgauss>>>( q, dR , c, N, 1 )");

           add_arrays_gpu<<<dimGridsub,dimBlock>>>( r, q, v, N );
           e = cudaGetLastError();
           CUDA_UTIL_ERRORCHECK("add_arrays_gpu<<<dimGridsub,dimBlock>>>( x, dX_k, x, N )");

           if ( k == 0 ) {
               /* t = A*v  idrs.m line 40 */
               sparseMatrixMul<<<dimGrid,dimBlock>>>( mt, A, mv );
               e = cudaGetLastError();
               CUDA_UTIL_ERRORCHECK("sparseMatrixMul<<<dimGrid,dimBlock>>>( mt, A, mv )");




               kernel_dotmul<<<dimGridsub,dimBlock>>>( t, v, om1 ) ;
                //kernel_dotmul<<<dimGridsub,dimBlock>>>( ctxholder[ctx].b, ctxholder[ctx].b, om2 ) ;
               e = cudaGetLastError();
               CUDA_UTIL_ERRORCHECK("device_dotMul");

               kernel_dotmul<<<dimGridsub,dimBlock>>>( t, t, om2 ) ;
                //kernel_dotmul<<<dimGridsub,dimBlock>>>( ctxholder[ctx].b, ctxholder[ctx].b, om2 ) ;
               e = cudaGetLastError();
               CUDA_UTIL_ERRORCHECK("device_dotMul");

               e = cudaStreamSynchronize(0);
               CUDA_UTIL_ERRORCHECK("cudaStreamSynchronize(0)");

               e = cudaMemcpy( h_om1, om1, sizeof(t_ve) * N * 2, cudaMemcpyDeviceToHost);
               CUDA_UTIL_ERRORCHECK("cudaMemcpy( h_om1, om1, sizeof(t_ve) * N * 2, cudaMemcpyDeviceToHost)");

               t_ve  som1 = 0;
               t_ve  som2 = 0;
               for ( t_mindex blockidx = 0; blockidx < A.m / 512 + 1; blockidx++ ) {
                    som1 += h_om1[blockidx];
                    som2 += h_om2[blockidx];
               }
               t_ve som = som1 / som2;

               /*  42            dR(:,oldest) = q - om*t; % 1 update */
               sub_and_mul_arrays_gpu<<<dimGridsub,dimBlock>>>( q, t, som, dRoldest , N);
               e = cudaGetLastError();
               CUDA_UTIL_ERRORCHECK("sub_and_mul_arrays_gpu");


               /*  43    dX(:,oldest) = -dX*c + om*v; % s updates + 1 scaling */
               matrixMul<<<dimGrid,dimBlock>>>( dX, c , buffer1, N, 1 ); /* the - is missing */
               e = cudaGetLastError();
               CUDA_UTIL_ERRORCHECK("matrixMul<<<dimGrid,dimBlock>>>( dX, c , dXoldest, N, 1 )");

               add_and_mul_arrays_gpu<<<dimGridsub,dimBlock>>>( buffer1, v, som, dXoldest , N);
               e = cudaGetLastError();
               CUDA_UTIL_ERRORCHECK("add_and_mul_arrays_gpu");

               printf("\n k = %u om = %f  %f %f", k, som, som1, som2   );

           }
           else {

               t_FullMatrix mdRoldest;
               t_FullMatrix mdXoldest;

               mdRoldest.m        = 1;
               mdRoldest.n        = N;
               mdRoldest.pElement = dRoldest;

               mdXoldest.m        = 1;
               mdXoldest.n        = N;
               mdXoldest.pElement = dXoldest;

              /* 46  dR(:,oldest) = -A*dX(:,oldest); % 1 matmul */
               sparseMatrixMul<<<dimGrid,dimBlock>>>( mdRoldest, A, mdXoldest );
               e = cudaGetLastError();
               CUDA_UTIL_ERRORCHECK("sparseMatrixMul<<<dimGrid,dimBlock>>>( mt, A, mv )");

               /*  45    dX(:,oldest) = -dX*c + om*v; % s updates + 1 scaling */
               matrixMul<<<dimGrid,dimBlock>>>( dX, c , buffer1, N, 1 ); /* the - is missing */
               e = cudaGetLastError();
               CUDA_UTIL_ERRORCHECK("matrixMul<<<dimGrid,dimBlock>>>( dX, c , dXoldest, N, 1 )");

               add_and_mul_arrays_gpu<<<dimGridsub,dimBlock>>>( buffer1, v, som, dXoldest , N);
               e = cudaGetLastError();
               CUDA_UTIL_ERRORCHECK("add_and_mul_arrays_gpu");
           }

           /*        r = r + dR(:,oldest); % simple addition */

           add_arrays_gpu<<<dimGridsub,dimBlock>>>( r, dRoldest, r, N );
           e = cudaGetLastError();
           CUDA_UTIL_ERRORCHECK("add_arrays_gpu<<<dimGridsub,dimBlock>>>( r, dRoldest, r, N )");

           /* x = x + dX(:,oldest); % simple addition */

           add_arrays_gpu<<<dimGridsub,dimBlock>>>( x, dXoldest, x, N );
           e = cudaGetLastError();
           CUDA_UTIL_ERRORCHECK("add_arrays_gpu<<<dimGridsub,dimBlock>>>( r, dRoldest, r, N )");



           //printf( "\n iterartion %u", iter );

           iter++;

           kernel_norm<<<dimGridsub,dimBlock>>>( mr.pElement, dnormv );
           e = cudaGetLastError();
           CUDA_UTIL_ERRORCHECK("kernel_norm<<<dimGridsub,dimBlock>>>( mr.pElement, dnormv )");


           e = cudaMemcpy( h_norm, dnormv, sizeof(t_ve) * N , cudaMemcpyDeviceToHost);
           CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");

            t_ve snorm = 0;
            for ( t_mindex i = 0; i < N / 512 + 1 ; i++ ) {
                 snorm +=  h_norm[i];
            }
            norm = snorm;
            resvec[ resveci++ ]  = sqrt( norm );
            printf( "\n iterartion %u norm %f", iter, norm );

            t_ve* Moldest = &M[ s * oldest ];


            /* 53 dm = P*dR(:,oldest); % s inner products */
            dm = Moldest;
            matrixMul<<<dimGrid,dimBlock>>>( P, dRoldest , Moldest, s, 1 ); /* the - is missing */
            e = cudaGetLastError();
            CUDA_UTIL_ERRORCHECK("matrixMul<<<dimGrid,dimBlock>>>( P, dRoldest , Moldest, s, 1 )");

            /* 55  m = m + dm; */
            add_arrays_gpu<<<dimGridgauss,dimBlock>>>( m, dm, m, s );
            e = cudaGetLastError();
            CUDA_UTIL_ERRORCHECK("add_arrays_gpu<<<dimGridsub,dimBlock>>>( r, dRoldest, r, N )");

            oldest++;
            if ( oldest > s - 1 ) {
               oldest = 1 ;
            }
        }

    }
    *piter = iter;

    e = cudaFree( devmem );
    CUDA_UTIL_ERRORCHECK("e = cudaFree( devmem );");

    e = cudaFree( ctxholder[ctx].devmem1stcall );
    CUDA_UTIL_ERRORCHECK("cudaFree ctxholder[ctx].devmem1stcall ");
}


/*
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
*/

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
                     t_ve*          xe_in,
                     t_mindex N,

                     t_ve*          r_out,    /* the r from idrs.m line 6 : r = b - A*x; */

                     t_idrshandle*  ih_out  /* handle for haloding all the device pointers between matlab calls */

           ) {



    t_idrshandle ctx;

    cudaError_t e;
    size_t h_memblocksize;
    size_t d_memblocksize;

    t_SparseMatrix A_d;

    t_ve* d_tmpAb;
    t_ve* d_b;
    t_ve* d_xe;
    t_ve* d_r;
    t_ve* xe;

    void *hostmem;
    void *devmem;

    ctx = 0;

    int cnt_multiprozessors;
    int deviceCount;
    cudaGetDeviceCount(&deviceCount);

    if (deviceCount == 0)
        printf("There is no device supporting CUDA\n");

    int dev;
    for (dev = 0; dev < deviceCount; ++dev) {
        cudaDeviceProp deviceProp;
        cudaGetDeviceProperties(&deviceProp, dev);
        printf("  Number of multiprocessors:                     %d\n", deviceProp.multiProcessorCount);
        cnt_multiprozessors = deviceProp.multiProcessorCount;
    }


    h_memblocksize =   smat_size( A_in.nzmax, A_in.m )  /* A sparse     */
                     + N * sizeof( t_ve )               /* b full       */
                     + N * sizeof( t_ve )               /* xe        */
                     ;

    d_memblocksize =  h_memblocksize
                    + (N + 512) * sizeof( t_ve )            /* d_tmpAb         */
                    + (N + 512) * sizeof( t_ve )            /* d_r             */
                    + N * sizeof( t_ve )            /* om1             */
                    + N * sizeof( t_ve )            /* om2             */
                    + N * sizeof( t_ve )            /* x               */
                    + N * sizeof( t_ve )            /* resvec          */

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
      d_xe       |  t_ve      |  N
      d_tmpAb    |  t_ve      |  N
      d_r        |  t_ve      |  N
      d_om1      |  t_ve      |  N
      d_om2      |  t_ve      |  N

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

    xe = (t_ve *) &b[N];
    memcpy( xe, xe_in,  N *  sizeof(t_ve) );

    e = cudaMalloc ( &devmem , d_memblocksize );
    CUDA_UTIL_ERRORCHECK("cudaMalloc")

    e = cudaMemset (devmem, 0, d_memblocksize );
    CUDA_UTIL_ERRORCHECK("cudaMemset");

    e = cudaMemcpy( devmem, hostmem, h_memblocksize , cudaMemcpyHostToDevice);
    CUDA_UTIL_ERRORCHECK("cudaMemcpyHostToDevice");

    free(hostmem);

    set_sparse_data(  A_in, &A_d, devmem );
    d_b     = (t_ve *) &A_d.pRow[A_in.m + 1];
    d_xe    = (t_ve *) &d_b[N];

    d_tmpAb = (t_ve *) &d_xe[N];
    d_r     = (t_ve *) &d_tmpAb[ N + 512 ];

    ctxholder[ctx].om1 = (t_ve *) &d_r[N + 512 ];
    ctxholder[ctx].om2 = (t_ve *) &ctxholder[ctx].om1[N];

    dim3 dimGrid ( cnt_multiprozessors );
    dim3 dimGridsub( N / 512 + 1 );
    dim3 dimBlock(512);

    /* --------------------------------------------------------------------- */

    t_FullMatrix mxe;
    t_FullMatrix result;

    mxe.m        = N;
    mxe.n        = 1;
    mxe.pElement = d_xe;

    result.pElement = d_tmpAb;
    result.m    = N ;
    result.n    = 1;
    //testsparseMatrixMul<<<dimGrid,dimBlock>>>( result, A_d, mb );
    sparseMatrixMul<<<dimGrid,dimBlock>>>( result, A_d, mxe );
    e = cudaGetLastError();
    CUDA_UTIL_ERRORCHECK("testsparseMatrixMul");


//   add_arrays_gpu( t_ve *in1, t_ve *in2, t_ve *out, t_mindex N)
    sub_arrays_gpu<<<dimGridsub,dimBlock>>>( d_b, d_tmpAb, d_r, N);
    e = cudaGetLastError();
    CUDA_UTIL_ERRORCHECK("sub_arrays_gpu");
    /* --------------------------------------------------------------------- */
    e = cudaMemcpy( r_out, d_r, sizeof(t_ve) * N, cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK("cudaMemcpyDeviceToHost");


    ctxholder[ctx].devmem1stcall = devmem;
    ctxholder[ctx].A             = A_d;
    ctxholder[ctx].b             = d_b;
    ctxholder[ctx].r             = d_r;
    ctxholder[ctx].v             = d_tmpAb; /* memory reusage */
    ctxholder[ctx].x             = d_xe;

    *ih_out = ctx;  /* context handle for later use in later calls */

}


