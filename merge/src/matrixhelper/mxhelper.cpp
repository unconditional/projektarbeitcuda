#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

 void debug_dump_sparse(  t_SparseMatrix sm_in  ) {

   if ( sm_in.m < 30 ) {
       printf("\n *** MXhelper inimplemented unimplemented *** \n ");
       for ( int i = 0; i < sm_in.m + 1; i++ ) {
           printf( "\n  pRow[%u] = %u", i, sm_in.pRow[i] );
       }
       for ( int i = 0; i < sm_in.nzmax; i++ ) {
          printf( "\n  pNZElement[%u] = %f", i, sm_in.pNZElement[i] );
       }
       for ( int i = 0; i < sm_in.nzmax; i++ ) {
          printf( "\n  pCol[%u] = %u", i, sm_in.pCol[i] );
       }
   }
   else {
      printf(" Matrixsize %u too big for dump", sm_in.m );
   }
}



void genmtx_t1(  t_SparseMatrix* sm_in, t_mindex N  ) {

    sm_in->m = N;
    sm_in->n = N;

    t_mindex cnt_elements = 3 * N - 2;
    sm_in->nzmax = cnt_elements;

    sm_in->pRow = ( t_mindex* ) malloc( sizeof( t_mindex ) * ( N + 1) );
    if ( sm_in->pRow == NULL) { fprintf(stderr, "sorry, can not allocate memory for you  a.pRow"); exit( -1 ); }

    sm_in->pNZElement = ( t_ve* ) malloc( sizeof( t_ve ) * cnt_elements );
    if ( sm_in->pNZElement == NULL) { fprintf(stderr, "sorry, can not allocate memory for you  a.pNZElement"); exit( -1 ); }

    sm_in->pCol = ( t_mindex* ) malloc( sizeof( t_mindex ) * cnt_elements );
    if ( sm_in->pCol == NULL) { fprintf(stderr, "sorry, can not allocate memory for you a.pCol"); exit( -1 ); }

    t_mindex i = 0;
    t_mindex row ;
    for ( row = 0; row < N; row++ ) {
        sm_in->pRow[row] = i;



        /* lower diag */
        if ( row > 0 ) {
            sm_in->pNZElement[i] = -1;
            sm_in->pCol[i]   = row - 1;
            i++;
        }
        /* main diag */
        sm_in->pNZElement[i] = 2;
        sm_in->pCol[i]   = row;
        i++;

        /* upper diag */
        if ( row < N - 1 ) {
            sm_in->pNZElement[i] = -1;
            sm_in->pCol[i]   = row + 1;
            i++;
        }

    }
    sm_in->pRow[row] = i;

    printf("\n *** unimplemented *** \n ");
}

