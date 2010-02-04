
#include <stdio.h>
#include "projektcuda.h"
#include "util.h"
#include "problemsamples.h"

__host__ void gen_problemsample( t_pmatrix matrix, int id ) {


    switch ( id ) {
        case 1 : {
// Example from R.Sedgewick, Page 608
           malloc_matrix( 3, matrix );

           int N = 3;

           matrix->elements[ a(1,1) ]  = 1;
           matrix->elements[ a(1,2) ]  = 3;
           matrix->elements[ a(1,3) ] = -4;

           matrix->elements[ a(2,1) ]  = 1;
           matrix->elements[ a(2,2) ]  = 1;
           matrix->elements[ a(2,3) ]  = -2;

           matrix->elements[ a(3,1) ]  = -1;
           matrix->elements[ a(3,2) ]  = -2;
           matrix->elements[ a(3,3) ]  = 5;


           matrix->elements[  a(1,4) ]  = 8;
           matrix->elements[  a(2,4) ]  = 2;
           matrix->elements[  a(3,4) ]  = -1;

           break;
        }
        case 2 : {
// Example from buyu
           int N = 3;
           malloc_matrix( 3, matrix );

           matrix->elements[ a(1,1) ]  =1;
           matrix->elements[ a(1,2) ]  =2;
           matrix->elements[ a(1,3) ] =3;

           matrix->elements[ a(2,1) ] =1;
           matrix->elements[ a(2,2) ] =1;
           matrix->elements[ a(2,3) ] =1;

           matrix->elements[ a(3,1) ] =2;
           matrix->elements[ a(3,2) ] =1;
           matrix->elements[ a(3,3) ] =1;

           matrix->elements[  a(1,4) ] =14;
           matrix->elements[  a(2,4) ] =6;
           matrix->elements[  a(3,4) ] =7;
           break;
        }
        case 3 : {
           int N = 10;
           unsigned int j, i;
           malloc_matrix( N, matrix );

           for ( j = 1; j <= N ; j++ ) {
               for ( i = 1; i <= N; i++ ) {
                   matrix->elements[ ab(j,i) ] = 0;
                   if ( i == j ) {
                       matrix->elements[ ab(j,i) ] = 1;
                   }
                   if ( i == j + 1 ) {
                       matrix->elements[ ab(j,i) ] = 2;
                   }
               }
               matrix->elements[ ab(j,N+1) ] = j;
           }

           break;
        }

        case 4 : {
           int N = 21;
           unsigned int j, i;
           malloc_matrix( N, matrix );

           for ( j = 1; j <= N ; j++ ) {
               for ( i = 1; i <= N; i++ ) {
                   matrix->elements[ ab(j,i) ] = 0;
                   if ( i == j ) {
                       matrix->elements[ ab(j,i) ] = 1;
                   }
                   if ( i == j + 1 ) {
                       matrix->elements[ ab(j,i) ] = 2;
                   }
               }
               matrix->elements[ ab(j,N+1) ] = j;
           }

           break;
        }

       default: {
          printf( "type %u not found", id );
          exit( -1 );
       }
    }

}

