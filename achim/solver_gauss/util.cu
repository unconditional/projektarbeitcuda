
#include <stdio.h>
#include <string.h>

#include "projektcuda.h"

#include "util.h"

/* ---------------------------------------------------- */

__host__  void dump_problem( t_ve* p_Ab, unsigned int N  ) {

    unsigned int j,i;
    for ( j = 1; j <= N; j++ ) {
        printf( "\n  %u. ", j );
        for ( i = 1; i <= N; i++ ) {
            printf( " %f", p_Ab[ a(j,i) ] );
        }
        printf( " \t b %f", p_Ab[ a(j,i) ] );
   }
}
/* ---------------------------------------------------- */

__host__ void dump_x( t_ve* x, unsigned int N  ) {

       unsigned int m;
       for ( m = 0; m < N; m++ ) {
           printf( "\n  x%u  = %f",m + 1, x[ m ] );
       }
}
/* ---------------------------------------------------- */
__host__ void backup_problem ( t_pmatrix matrix ) {

    memcpy(
            matrix->orgelements,
            matrix->elements,
            sizeof(t_ve) * (matrix->n + 1 ) * matrix->n
           );

}
/* ---------------------------------------------------- */
__host__ void free_matrix( t_pmatrix matrix ) {
    free(  matrix->elements );
    free(  matrix->orgelements );
    free(  matrix->x );
}
/* ---------------------------------------------------- */

__host__ void malloc_matrix( unsigned int size_n, t_pmatrix matrix ) {

   matrix->n        = size_n;
   matrix->elements =  (t_ve*) malloc( sizeof(t_ve) * (size_n + 1 ) * size_n ); /* store b in array, too */
   if ( matrix->elements == NULL) {
       fprintf(stderr, "sorry, can not allocate memory for you");
       exit( -1 );
   }
   matrix->orgelements =  (t_ve*) malloc( sizeof(t_ve) * (size_n + 1 ) * size_n ); /* store b in array, too */
   if ( matrix->orgelements == NULL) {
       fprintf(stderr, "sorry, can not allocate memory for you");
       exit( -1 );
   }
   matrix->x = (t_ve*) malloc( sizeof(t_ve)  * size_n ); /* the output vector */

   if ( matrix->elements == NULL) {
       fprintf(stderr, "sorry, can not allocate memory for you");
       exit( -1 );
   }
}
/* ---------------------------------------------------- */
__host__  int check_correctness(  t_ve* p_Ab, unsigned int N, t_ve* p_x ) {
    unsigned int j,i;

    for ( j = 1; j <= N; j++ ) {
        t_ve sum = 0;
        for ( i = 1; i <= N; i++ ) {
            sum += p_Ab[ a(j,i) ] * p_x[ (i-1) ] ;
        }
        printf("\n %u %f   b %f", j, sum, p_Ab[ a(j,N+1) ] );
        if ( sum != p_Ab[ a(j,N+1) ] ) {
            printf("check not ok");
            exit(-1); /*  needs to be changed to retunr instead of die!!! */
        }
    }
   return GAUSS_SOLVE_OK;
}
/* ---------------------------------------------------- */


