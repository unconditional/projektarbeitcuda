
#include "projektcuda.h"
#include <stdlib.h>
#include <stdio.h>

__global__ void device_gauss_solver( t_ve* p_Ab, unsigned int N, t_ve* p_x )
{


    __shared__ unsigned int i;
    __shared__ unsigned int max;

    __shared__ t_ve Ab[ GAUSS_NMAX * ( GAUSS_NMAX + 1) ];
    __shared__ t_ve x[ GAUSS_NMAX ];

    unsigned int tidx =  threadIdx.x;


    if ( threadIdx.x < N + 1 ) {
        for ( short l = 0; l < N ; l++ ) {
           short ao = ( threadIdx.x * N + l );
           Ab[ao] = p_Ab[ao];
        }
    }

    if ( tidx == 0 ) { i = 1; }

    __syncthreads();

    while ( i <= N ) {                  /* for ( i = 1; i <= N ; i++ ) */

       if ( tidx == 0 ) {
            unsigned int j;
            max = i;

            for( j = i + 1; j <= N; j++ ) {
                if ( abs( Ab[ ab(j,i) ] ) > abs( Ab[ ab(max,i) ] )  ) {
                    max = j;
                }
            }
       }
       __syncthreads();

       unsigned int k = tidx + 1;

       if ( ( k >= i ) && ( k <= N + 1 ) ) {
           t_ve t          = Ab[ ab(i  ,k) ];
           Ab[ ab(i,k)   ] = Ab[ ab(max,k) ];
           Ab[ ab(max,k) ] = t;
      }

      __syncthreads();

      {
          unsigned int j = threadIdx.x + 1;
          if (  ( j >= i +1 ) && ( j <= N ) && threadIdx.y == 0 ) {       /*   for ( j = i +1; j <= N ; j++ ) */
              unsigned int  k ;
              for ( k = N + 1; k >= i ; k-- ) {
                 Ab[ ab(j,k) ] -= Ab[ ab(i,k) ] * Ab[ ab(j,i) ] /  Ab[ ab(i, i) ];
              }
           }
       }
       __syncthreads();
       if ( tidx == 0 ) { i++; }
       __syncthreads();
    }
    __syncthreads();

    if ( tidx == 0 ) {

        /* the substitute part */
        unsigned int j,k;
        for (j = N; j >= 1; j-- ) {
            t_ve t = 0.0;
            for ( k = j + 1; k <= N; k++ ) {
                t +=  Ab[ ab(j,k) ] * x[ k - 1 ];
            }
            x[ j - 1 ] = ( Ab[ ab(j,N+1) ] - t ) / Ab[ ab(j,j) ] ;
        }

    }
    __syncthreads();
    if ( threadIdx.x < N ) {
        p_x[threadIdx.x] = x[threadIdx.x];
    }

   __syncthreads();
}


__host__ void dbg_solver_check_result( t_ve* Ab_in, t_mindex N, t_ve* x_in ) {

    cudaError_t e;

    //return ;

    t_ve* Ab = (t_ve*) malloc( sizeof( t_ve ) * (N+1) * N );
    if ( Ab == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you Ab"); exit( -1 ); }
    t_ve* x  = (t_ve*) malloc( sizeof( t_ve ) * N );

    e = cudaMemcpy( Ab, Ab_in, sizeof(t_ve) * (N+1) * N , cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");

    e = cudaMemcpy( x, x_in, sizeof(t_ve) * (N), cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");

// -------------------------------------------------------------

   t_mindex i ;
   t_mindex j;

    for ( j = 1; j <= N; j++ ) {
        t_ve sum = 0;
        for ( i = 1; i <= N; i++ ) {
            sum += Ab[ ab(j,i) ] * x[ (i-1) ] ;
        }
        //printf("\n %u %f   b %f", j, sum, p_Ab[ ab(j,N+1) ] );
        //if ( sum != Ab[ ab(j,N+1) ] ) {
        t_ve tolerance;
        t_ve diff;
        diff = abs( sum - Ab[ ab(j,N+1)] );
        if ( abs( Ab[ ab(j,N+1) ] ) > 1 ) {
           tolerance = abs( Ab[ ab(j,N+1)] / 50 );
        }
        else {
            tolerance = 0.01;
        }
        if ( diff  > tolerance ) {
            printf("\n Gauss Solver check not ok row=%u, sum %f   b=%f (tol=%f, diff=%f )", j, sum , Ab[ ab(j,N+1)], tolerance, diff  );

            for ( int k = 1; k <=N; k++ ) {
                printf("\n b[%u]=%f ", k, Ab[ ab(k,N+1) ] );
            }
            for ( int s = 1; s <=N; s++ ) {
                for ( int k = 1; k <=N; k++ ) {
                    printf("\n A(%u,%u)=%f ", k, s, Ab[ ab(k,s) ] );
                }
            }
            for ( int k = 1; k <=N; k++ ) {
                printf("\n x[%u]=%f ", k, x[ (k-1) ] );
            }

            exit(-1); /*  needs to be changed to retunr instead of die!!! */
        }
    }
// -------------------------------------------------------------

    free(x);
    free(Ab);

}

