
#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

#include "idrs.h"
#include <time.h>

#define N_PROBLEM 10000


__host__ void malloc_NN( unsigned int size_n, t_ve** M ) {

    t_ve*  v;
    v =  (t_ve*) malloc( sizeof(t_ve) * size_n  * size_n );
    if ( v == NULL) {
	       fprintf(stderr, "sorry, can not allocate memory for you");
	       exit( -1 );
    }
    *M = v;

}

__host__ void malloc_N( unsigned int size_n, t_ve** M ) {

    t_ve* v =  (t_ve*) malloc( sizeof(t_ve) * size_n  );
    if ( v == NULL) {
	       fprintf(stderr, "sorry, can not allocate memory for you");
	       exit( -1 );
    }
    *M = v;

}

int main()
{
    clock_t startime;
    clock_t endtime;
    startime = clock( );

	   t_ve* A ; /* the problem */
	   t_ve* b ; /* the problems right side */



       t_ve* x0 ;

       t_ve* x ;  /* output vector */
       t_ve* resvec ;
       unsigned int iter;

       malloc_NN( N_PROBLEM , &A );
       malloc_N( N_PROBLEM  , &b );
       malloc_N( N_PROBLEM  , &x0 );
       malloc_N( N_PROBLEM  , &x );



       unsigned int N  =  N_PROBLEM;

       unsigned int j, i;

           for ( j = 1; j <= N_PROBLEM ; j++ ) {
               for ( i = 1; i <= N_PROBLEM; i++ ) {
                   A[ a(j,i) ] = 0;
                   if ( i == j ) {
                      A[ a(j,i) ] = 1;
                   }
                   if ( i == j + 1 ) {
                       A[ a(j,i) ] = 2;
                   }
               }
               b[ j -1 ] = j;
           }

   idrs(
                      A ,
                      b ,
                     20 ,  /* s iterations */
                     0.1,  /* tol          */
                     50,   /* masit        */
                     x0,

                     N_PROBLEM,

                      x,  /* output vector */
                      resvec,
                     &iter
                  );

       endtime = clock();

	   printf("idrs solver - testdriver");

	   printf( "\n %f seconds,  clocks: %u : CLOCKS_PER_SEC %u \n", ( (float) (endtime - startime)) / CLOCKS_PER_SEC, endtime - startime, CLOCKS_PER_SEC );
	}

