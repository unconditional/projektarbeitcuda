#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"
#include "idrs.h"
#include "mxhelper.h"

#include <time.h>

#include <math.h>

int main( int argc, char *argv[] )
{
   time_t starttime;
   time_t endtime;



   int nparam = 30;
   if ( argc > 1 ) {
      nparam = atoi( argv[1] );
   }

   t_mindex N                  = nparam;
   t_mindex sparse_NZ_elements = nparam;

   t_mindex s = 4;

   t_SparseMatrix a;
   t_SparseMatrix a2;

   t_mindex maxit = N * 100;
   t_ve tol =  0.01;

   if ( argc > 2 ) {
      tol = atof( argv[2] );
   }
   if ( argc > 3 ) {
      set_debuglevel( atoi( argv[3] ));
   }

   t_ve*  r;
   t_ve*  b;
   t_ve*  xe;

   t_ve*  x;
   t_ve*  resvec;
   t_FullMatrix P;

   unsigned int interations_needed;

   printf( "\n Build configuration host Complier: sizeof(t_ve) = %u \n", sizeof(t_ve));
   printf( "\n Build configuration libidrs: sizeof(t_ve) = %u \n"      , idrs_sizetve());


   printf("\n manual IDRS driver, running Matrix size %u \n", N);
   printf("\n  tolerance %f \n", tol );

    a.n = N;
    a.m = N;
    a.nzmax = sparse_NZ_elements;

    P.m        = s;
    P.n        = N;
    P.pElement = ( t_ve* ) malloc( sizeof( t_ve ) *  N * s );
    if (  P.pElement == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you P.pElement"); exit( -1 ); }

    resvec = ( t_ve* ) malloc( sizeof( t_ve ) *  maxit );
    if (  resvec == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you xe"); exit( -1 ); }

    xe = ( t_ve* ) malloc( sizeof( t_ve ) *  N );
    if (  xe == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you xe"); exit( -1 ); }

    x = ( t_ve* ) malloc( sizeof( t_ve ) *  N );
    if (  x == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you xe"); exit( -1 ); }

    b = ( t_ve* ) malloc( sizeof( t_ve ) *  N );
    if ( b == NULL) { fprintf(stderr, "sorry, can not allocate memory for you b"); exit( -1 ); }

    r = ( t_ve* ) malloc( sizeof( t_ve ) *  N );
    if ( r == NULL) { fprintf(stderr, "sorry, can not allocate memory for you b"); exit( -1 ); }

   for ( int i = 0; i < N; i++ ) {
      b[i] =  0;

      xe[i] =  ((t_ve) rand()) / RAND_MAX - 0.5;
   }

    b[0]   =  1;
    b[N-1] = -1;

    a.pRow = ( t_mindex* ) malloc( sizeof( t_mindex ) * ( a.m + 1) );
    if ( a.pRow == NULL) { fprintf(stderr, "sorry, can not allocate memory for you  a.pRow"); exit( -1 ); }

    a.pCol = ( t_mindex* ) malloc( sizeof( t_mindex ) * a.nzmax );
    if ( a.pCol == NULL) { fprintf(stderr, "sorry, can not allocate memory for you a.pCol"); exit( -1 ); }

    a.pNZElement = ( t_ve* ) malloc( sizeof( t_ve ) * a.nzmax );
    if ( a.pNZElement == NULL) { fprintf(stderr, "sorry, can not allocate memory for you  a.pNZElement"); exit( -1 ); }

    for ( t_mindex i = 0; i < a.nzmax; i++ ) {
        a.pNZElement[i] = 1;
    }

    for ( t_mindex i = 0; i < a.nzmax; i++ ) {
        a.pCol[i] = i;
    }
    for ( t_mindex i = 0; i < a.m ; i++ )  {
       a.pRow[i] = i;
    }
    a.pRow[a.m] = a.m;

    genmtx_t2( &a2, nparam );

    debug_dump_sparse( a2 );




/*
    idrs_1st( a2, b, xe, N, r,  &irdshandle );


*/

//idrs2nd(
//    P,
//    0.1,  /* tol */
//    s,   /* s - as discussed with Bastian on 2010-01-27 */
//    30,
//    irdshandle, /* Context Handle we got from idrs_1st */
//    x,
//    resvec,
//    &interations_needed
//);
if ( N < 30 ) {
   for ( int i = 0; i < N; i++ ) {
       printf( "\n    b[%u] %f",i,  b[i] );
   }
   for ( int i = 0; i < N; i++ ) {
       printf( "\n    x0[%u] %f",i,  xe[i] );
   }
}

starttime = time(NULL);

idrswhole(

    a2,    /* A Matrix in buyu-sparse-format */
    b,    /* b as in A * b = x */

    s,
    tol, /* tol */
    maxit,  /* t_mindex maxit,*/

    xe,

     N,

    x,
    resvec,
    &interations_needed

);


   endtime = time(NULL);

   printf("\n --------------------------------------------------------- \n");
   printf("\n ---------------         Result           ---------------- \n");
   printf("\n --------------------------------------------------------- \n");
   printf("\n\n ***X***X (m,x[n]) follows ***X***X");
   for ( unsigned int i = 0; i < N; i++ ) {
       printf( "\n%u\t%f", i + 1,  x[i] );
   }
   printf("\n\n ***X***X***X x ends here");
   printf("\n\n *** resvec (iter,resvec[i]) follows ***X***X");
   for ( unsigned int i = 0; i < interations_needed; i++ ) {
       printf( "\n%u\t%f",i + 1,  resvec[i] );
   }
   printf("\n\n *** end of resvec (iter,resvec[i]) ");
   printf("\n --------------------------------------------------------- \n");
   printf("\n debuglevel         :  %u  (0 is normal mode for measurement)", get_debuglevel() );

   printf("\n N         :  %u ", N);
   printf("\n s         :  %u ", s);
   printf("\n used tolrance: norm < %f ", tol);
   printf("\n used rel. tolrance:  %f ", tol *resvec[0]  );

   printf("\n used iterations:  %u ", interations_needed);
   printf("\n maxit          :  %u ", maxit);

   printf("\n runtime time(): %u seconds ", endtime - starttime );

/*
   if ( N < 11 ) {
   for ( int i = 0; i < N; i++ ) {
       printf( "\n   b[%u]=%f r %f  ", i, b[i], r[i] );
   }
   }
*/


}

