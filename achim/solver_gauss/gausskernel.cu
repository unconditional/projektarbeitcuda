
#include "projektcuda.h"

#include "gausskernel.h"

__global__ void device_gauss_solver( t_ve* p_Ab, unsigned int N, t_ve* p_x )
{


    __shared__ unsigned int i;
    __shared__ unsigned int max;

    __shared__ t_ve Ab[ GAUSSNMAX * ( GAUSSNMAX + 1) ];
     t_ve x[ GAUSSNMAX ];

    unsigned int tidx = threadIdx.y * blockDim.x + threadIdx.x;
    unsigned int n;

    t_ve t ;

    if ( tidx  <  N * (N+1) ) {
         Ab[tidx] = p_Ab[tidx];
    }

    if ( tidx == 0 ) { i = 1; }

    __syncthreads();

    while ( i <= N ) {                  /* for ( i = 1; i <= N ; i++ ) */
        if ( tidx == 0 ) {
            unsigned int j;
            max = i;
            for( j = i + 1; j <= N; j++ ) {
                if ( abs( Ab[ a(j,i) ] ) > abs( Ab[ a(max,i) ] )  ) {
                    max = j;
                }
            }
       }
       __syncthreads();


//       if ( threadIdx.y == 0 ) {
           unsigned int k = tidx + 1;
         if ( tidx == 0 ) { /* does not work in parallel on device (don't not know why :-/ ) */
//           if ( ( k >= i ) && ( k <= N + 1 ) ) {
            for ( k = i; k <= N + 1; k++ ) {
               t              = Ab[ a(i  ,k) ];
               Ab[ a(i,k)   ] = Ab[ a(max,k) ];
               Ab[ a(max,k) ] = t;
           }
        }

      __syncthreads();

      {
          unsigned int j = threadIdx.x + 1;
          if (  ( j >= i +1 ) && ( j <= N ) && threadIdx.y == 0 ) {       /*   for ( j = i +1; j <= N ; j++ ) */
              unsigned int  k ;
              for ( k = N + 1; k >= i ; k-- ) {
                 Ab[ a(j,k) ] -= Ab[ a(i,k) ] * Ab[ a(j,i) ] /  Ab[ a(i, i) ];
              }
           }
       }
       __syncthreads();
       if ( tidx == 0 ) { i++; }
    }
    __syncthreads();

    if ( tidx == 0 ) {

        /* the substitute part */
        unsigned int j,k;
        for (j = N; j >= 1; j-- ) {
            t_ve t = 0.0;
            for ( k = j + 1; k <= N; k++ ) {
                    t +=  Ab[ a(j,k) ] * x[ k - 1 ];
            }
            x[ j - 1 ] = ( Ab[ a(j,N+1) ] - t ) / Ab[ a(j,j) ] ;
        }
        /* copy result back to global memory */

        for  ( n = 0; n <  N * (N+1); n++ ) {
            p_Ab[n] = Ab[n];
        }
        for  ( n = 0; n < N; n++ ) {
            p_x[n] = x[n];
        }
    }
   __syncthreads();
}
