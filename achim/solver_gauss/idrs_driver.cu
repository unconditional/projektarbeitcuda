
#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

#include "idrs.h"

#define N_PROBLEM 20000


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

    *M =  (t_ve*) malloc( sizeof(t_ve) * size_n  );
    if ( *M == NULL) {
	       fprintf(stderr, "sorry, can not allocate memory for you");
	       exit( -1 );
    }

}

int main()
{

	   t_ve* A = NULL; /* the problem */
	   t_ve* b = NULL; /* the problems right side */
       t_ve* s = NULL;


       t_ve* x0 = NULL;

       t_ve* x = NULL;  /* output vector */
       t_ve* resvec = NULL;
       unsigned int iter;

       malloc_NN( N_PROBLEM , &A );
       malloc_N( N_PROBLEM  , &b );

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
                      s ,
                     0.1, /* tol */
                     50,  /* masit  */
                     x0,

                     N_PROBLEM,

                      x,  /* output vector */
                      resvec,
                     &iter
                  );


	   printf("idrs solver - testdriver");
	}

