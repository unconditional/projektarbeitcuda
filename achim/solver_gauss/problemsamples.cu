
#include <stdio.h>

#include "util.h"
#include "problemsamples.h"

__host__ void gen_problemsample( t_pmatrix matrix, int id ) {


    switch ( id ) {
        case 1 : {
// Example from R.Sedgewick, Page 608
           malloc_matrix( 3, matrix );

           matrix->elements[ 0 ]  = 1;
           matrix->elements[ 1 ]  = 3;
           matrix->elements[ 2 ]  = -4;

           matrix->elements[ 4 ]  = 1;
           matrix->elements[ 5 ]  = 1;
           matrix->elements[ 6 ]  = -2;

           matrix->elements[  8 ]  = -1;
           matrix->elements[  9 ]  = -2;
           matrix->elements[ 10 ]  = 5;

           matrix->elements[  3 ]  = 8;
           matrix->elements[  7 ]  = 2;
           matrix->elements[ 11 ]  = -1;

           break;
        }
        case 2 : {
// Example from buyu

           malloc_matrix( 3, matrix );

           matrix->elements[0]=1;
           matrix->elements[1]=2;
           matrix->elements[2]=3;
           matrix->elements[3]=14;
           matrix->elements[4]=1;
           matrix->elements[5]=1;
           matrix->elements[6]=1;
           matrix->elements[7]=6;
           matrix->elements[8]=2;
           matrix->elements[9]=1;
           matrix->elements[10]=1;
           matrix->elements[11]=7;
           break;
        }
        case 3 : {
           int N = 9;
           unsigned int j, i;
           malloc_matrix( N, matrix );

           for ( j = 1; j <= N ; j++ ) {
               for ( i = 1; i <= N; i++ ) {
                   matrix->elements[ a(j,i) ] = 0;
                   if ( i == j ) {
                       matrix->elements[ a(j,i) ] = 1;
                   }
                   if ( i == j + 1 ) {
                       matrix->elements[ a(j,i) ] = 2;
                   }
               }
               matrix->elements[ a(j,N+1) ] = j;
           }

           break;
        }

        case 4 : {
           int N = 100;
           unsigned int j, i;
           malloc_matrix( N, matrix );

           for ( j = 1; j <= N ; j++ ) {
               for ( i = 1; i <= N; i++ ) {
                   matrix->elements[ a(j,i) ] = 0;
                   if ( i == j ) {
                       matrix->elements[ a(j,i) ] = 1;
                   }
                   if ( i == j + 1 ) {
                       matrix->elements[ a(j,i) ] = 2;
                   }
               }
               matrix->elements[ a(j,N+1) ] = j;
           }

           break;
        }

       default: {
          printf( "type %u not found", id );
          exit( -1 );
       }
    }

}

