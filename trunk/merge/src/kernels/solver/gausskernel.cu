
#include "projektcuda.h"


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
