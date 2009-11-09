
#include <stdlib.h>
#include <stdio.h>

typedef float        t_ve   ;
//#typedef unsigned int t_vidx ; // index of vector elements

t_ve *a;

typedef struct {

    unsigned int n;
    t_ve*    elements;
    t_ve*    x;

    t_ve*    device_elements;
    t_ve*    device_x;

} t_matrix;

typedef t_matrix* t_pmatrix;

t_matrix M1;

// -----------------------------------------------------------------------
void push_problem_to_device( t_pmatrix matrix ) {


    cudaError_t e;
    e = cudaMalloc ((void **) &matrix->device_x, sizeof(t_ve) * (matrix->n + 1 ) * matrix->n );
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMalloc: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
    e = cudaMalloc ((void **) &matrix->device_elements, sizeof(t_ve) * (matrix->n + 1 ) * matrix->n );
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMalloc: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

    e = cudaMemcpy( matrix->device_x, matrix->x , sizeof(t_ve)*matrix->n, cudaMemcpyHostToDevice);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

    e = cudaMemcpy( matrix->device_elements, matrix->elements , sizeof(t_ve) * (matrix->n + 1 ) * matrix->n, cudaMemcpyHostToDevice);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

}
// -----------------------------------------------------------------------
void malloc_matrix( unsigned int size_n, t_pmatrix matrix ) {

   matrix->n        = size_n;
   matrix->elements =  (t_ve*) malloc( sizeof(t_ve) * (size_n + 1 ) * size_n ); /* store b in array, too */
   if ( matrix->elements == NULL) {
       fprintf(stderr, "sorry, can not allocate memory for you");
       exit( -1 );
   }
   matrix->x = (t_ve*) malloc( sizeof(t_ve)  * size_n ); /* the output vector */

   if ( matrix->elements == NULL) {
       fprintf(stderr, "sorry, can not allocate memory for you");
       exit( -1 );
   }
}


#define ME( A, j , i ) A->elements[ (j -1 ) * ( A->n + 1 ) + i -1 ]

// -----------------------------------------------------------------------
void substitute( t_pmatrix matrix ) {
   unsigned int j, k, N;
   t_ve t;

   N = matrix->n;

   for (j = N; j >= 1; j-- ) {
       t = 0.0;
       for ( k = j + 1; k <= N; k++ ) {
           t +=  ME( matrix, j , k ) * matrix->x[ k - 1 ];
       }
       matrix->x[ j - 1 ] = ( ME( matrix, j , N + 1 ) - t ) / ME( matrix, j , j );
   }
}
// -----------------------------------------------------------------------

void eleminate ( t_pmatrix matrix ) {
    unsigned int i, j, k, max, N;
    t_ve t;

    N = matrix->n;

    for ( i = 1; i <= N ; i++ ) {
       max = i;
       for( j = i + 1; j <= N; j++ ) {
           if ( abs( ME( matrix, j , i ) ) > abs( ME( matrix, max , i ) ) ) {
              max = j;
           }
       }
       for ( k = i; k <= N; k++ ) {
          t                     = ME( matrix, i , k );
          ME( matrix, i , k )   = ME( matrix, max , k );
          ME( matrix, max , k ) = t;
       }

       for ( j = i +1; j <= N ; j++ ) {
          for ( k = N + 1; k >= i ; k-- ) {
             ME( matrix, j , k ) -= ME( matrix, i , k ) * ME( matrix, j , i ) /  ME( matrix, i , i );
          }
       }
    }
}
// -----------------------------------------------------------------------
void dump_matrix( t_pmatrix matrix ) {
    int n;
    int m;
    for ( m = 0; m < matrix->n; m++ ) {
        printf( "\n  %u. ", m + 1 );
        for ( n = 0; n < matrix->n; n++ ) {
            printf( " %f", matrix->elements[ m * ( matrix->n + 1 ) + n ] );
        }
        printf( " \t b %f", matrix->elements[ m * ( matrix->n + 1 ) + n ] );
   }
   for ( m = 0; m < matrix->n; m++ ) {
      printf( "\n  x%u  = %f",m + 1, matrix->x[ m ] );
   }
}
// -----------------------------------------------------------------------
void gen_textinput_01( t_pmatrix matrix ) {

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
}
// -----------------------------------------------------------------------

int main()
{
//    malloc_matrix( 3, &M1 );

    gen_textinput_01( &M1 );

    printf( "hello world , size ist set to %u\n", M1.n );


    dump_matrix( &M1 );
//    eleminate( &M1 );
//    substitute( &M1 );

    push_problem_to_device( &M1 );

    printf( "\n" );
    dump_matrix( &M1 );
}



