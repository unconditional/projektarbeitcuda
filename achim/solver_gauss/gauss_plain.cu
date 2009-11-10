
#include <stdlib.h>
#include <stdio.h>

#define Ae( j , i, N ) (j -1 ) * ( N + 1 ) + i -1

#define ME( A, j , i ) A->elements[ Ae( j , i, A->n ) ]




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

__global__ void device_substitute( t_ve* x, t_ve* Ab, unsigned int N ) {

   unsigned int j,k;
   t_ve t;

   unsigned int tidx = threadIdx.y * blockDim.x + threadIdx.x;



   if ( tidx == 0 ) {

   for (j = N; j >= 1; j-- ) {
       t = 0.0;
       for ( k = j + 1; k <= N; k++ ) {
           t +=  Ab[ Ae( j , k, N ) ] * x[ k - 1 ];
       }
       x[ j - 1 ] = ( Ab[ Ae( j , N + 1, N ) ] - t ) / Ab[ Ae( j , j, N) ] ;
   }
   }
}

// -----------------------------------------------------------------------

__global__ void device_eleminate( t_ve* Ab, unsigned int N  )
{


    __shared__ unsigned int i;
    __shared__ unsigned int max;
    t_ve t;

    unsigned int tidx = threadIdx.y * blockDim.x + threadIdx.x;
//    unsigned int tidx = blockIdx.x * blockDim.x + threadIdx.x;

    if ( tidx == 0 ) { i = 1; }

    __syncthreads();

//


//       for ( i = 1; i <= N ; i++ ) {
    while ( i <= N ) {
        if ( tidx == 0 ) {
            unsigned int j;
            max = i;
            for( j = i + 1; j <= N; j++ ) {
                if ( abs( Ab[ Ae( j , i , N ) ] ) > abs( Ab[ Ae( max , i, N ) ] )  ) {
                        max = j;
                }
            }
       }
       __syncthreads();


//       for ( k = i; k <= N; k++ ) {
         if ( threadIdx.y == 0 )
         {
             unsigned int k = threadIdx.x + 1;
             if ( ( k >= i ) && ( k <= N )  ) {
                 t                          = Ab[ Ae(   i , k, N ) ];
                 Ab[ Ae( i   , k ,  N )   ] = Ab[ Ae( max , k, N ) ];
                 Ab[ Ae( max , k, N ) ]     = t;

             }
         }
         __syncthreads();

//       if ( tidx == 1 )
      {
           unsigned int j = threadIdx.x + 1;
//           printf("\n **** hallo hallo i %u ", i );
//       for ( j = i +1; j <= N ; j++ ) {
         if (  ( j >= i +1 ) && ( j <= N ) ) {
          unsigned int  k;
          for ( k = N + 1; k >= i ; k-- ) {
             Ab[ Ae( j , k , N ) ] -= Ab[ Ae( i , k, N ) ] * Ab[ Ae( j , i, N ) ] /  Ab[ Ae( i , i, N ) ];
          }
       }
       }
       __syncthreads();
       if ( tidx == 0 ) { i++; }

    }

    }
//}



// -----------------------------------------------------------------------
void pull_problem_from_device( t_pmatrix matrix ) {
   cudaError_t e;
    e = cudaMemcpy(  matrix->elements, matrix->device_elements, sizeof(t_ve) * (matrix->n + 1 ) * matrix->n, cudaMemcpyDeviceToHost);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
    e = cudaMemcpy(  matrix->x, matrix->device_x, sizeof(t_ve) * matrix->n, cudaMemcpyDeviceToHost);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
}
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




// -----------------------------------------------------------------------
void substitute( t_ve* x, t_ve* Ab, unsigned int N ) {
   unsigned int j, k;
   t_ve t;

   for (j = N; j >= 1; j-- ) {
       t = 0.0;
       for ( k = j + 1; k <= N; k++ ) {
           t +=  Ab[ Ae( j , k, N ) ] * x[ k - 1 ];
       }
       x[ j - 1 ] = ( Ab[ Ae( j , N + 1, N ) ] - t ) / Ab[ Ae( j , j, N) ] ;
   }
}
// -----------------------------------------------------------------------

void eleminate ( t_ve* Ab, unsigned int N ) {
    unsigned int i, j, k, max;
    t_ve t;


    for ( i = 1; i <= N ; i++ ) {
       max = i;
       for( j = i + 1; j <= N; j++ ) {
           if ( abs( Ab[ Ae( j , i , N ) ] ) > abs( Ab[ Ae( max , i, N ) ] )  ) {
              max = j;
           }
       }
       for ( k = i; k <= N; k++ ) {
          t                   = Ab[ Ae(   i , k, N ) ];
          Ab[ Ae( i , k ,  N )   ] = Ab[ Ae( max , k, N ) ];
          Ab[ Ae( max , k, N ) ] = t;
       }

       for ( j = i +1; j <= N ; j++ ) {
          for ( k = N + 1; k >= i ; k-- ) {
             Ab[ Ae( j , k , N ) ] -= Ab[ Ae( i , k, N ) ] * Ab[ Ae( j , i, N ) ] /  Ab[ Ae( i , i, N ) ];
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

    cudaError_t e;

    gen_textinput_01( &M1 );

    printf( "hello world , size ist set to %u\n", M1.n );


    dump_matrix( &M1 );
//    eleminate( M1.elements, M1.n );


    push_problem_to_device( &M1 );

    int block_size = 64;
    dim3 dimBlock(block_size );

    dim3 dimGrid ( 1 );

    device_eleminate<<<dimGrid,dimBlock>>>( M1.device_elements, M1.n );
    e = cudaGetLastError();
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on add_arrays_gpu: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
    device_substitute<<<dimGrid,dimBlock>>>( M1.device_x, M1.device_elements, M1.n );
    e = cudaGetLastError();
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on add_arrays_gpu: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

    pull_problem_from_device( &M1 );

    printf( "\n" );
    dump_matrix( &M1 );
}



