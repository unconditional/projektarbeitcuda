
#include <stdlib.h>
#include <stdio.h>

#define a( r, s ) (r -1 ) * ( N + 1 ) + s -1

#define NMAX 22

typedef float        t_ve   ;

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



    if ( 0 == threadIdx.y * blockDim.x + threadIdx.x ) {
        unsigned int j,k;
        for (j = N; j >= 1; j-- ) {
            t_ve t = 0.0;
            for ( k = j + 1; k <= N; k++ ) {
                    t +=  Ab[ a(j,k) ] * x[ k - 1 ];
            }
            x[ j - 1 ] = ( Ab[ a(j,N+1) ] - t ) / Ab[ a(j,j) ] ;
        }
   }
}

// -----------------------------------------------------------------------

__global__ void device_gauss_solve( t_ve* p_Ab, unsigned int N, t_ve* p_x )
{


    __shared__ unsigned int i;
    __shared__ unsigned int max;

    __shared__ t_ve Ab[ NMAX * ( NMAX + 1) ];
     t_ve x[ NMAX ];

    unsigned int tidx = threadIdx.y * blockDim.x + threadIdx.x;
    unsigned int n;
    if ( tidx == 0 ) {
        i = 1;
        for  ( n = 0; n <  N * (N+1); n++ ) {
            Ab[n] = p_Ab[n];
        }
    }
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


       if ( threadIdx.y == 0 ) {
           unsigned int k = threadIdx.x + 1;
           if ( ( k >= i ) && ( k <= N + 1 ) ) {
               t_ve t         = Ab[ a(i  ,k) ];
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
           t +=  Ab[ a( j , k ) ] * x[ k - 1 ];
       }
       x[ j - 1 ] = ( Ab[ a(j,N+1) ] - t ) / Ab[ a(j,j) ] ;
   }
}
// -----------------------------------------------------------------------

void eleminate ( t_ve* Ab, unsigned int N ) {
    unsigned int i;   // columns
    unsigned int j;   // rows, equitations
    unsigned int k, max;
    t_ve t;



    for ( i = 1; i <= N ; i++ ) {


       max = i;
       for( j = i + 1; j <= N; j++ ) {
           if ( abs( Ab[ a(j,i) ] ) > abs( Ab[ a(max,i) ] )  ) {
              max = j;
           }
       }

       for ( k = i; k <= N + 1; k++ ) {
          t              = Ab[ a(i,k) ];
          Ab[ a(i,k)   ] = Ab[ a(max,k) ];
          Ab[ a(max,k) ] = t;
       }

       for ( j = i +1; j <= N ; j++ ) {
          for ( k = N + 1; k >= i ; k-- ) {
             Ab[ a(j,k) ] -= Ab[ a(i,k) ] * Ab[ a(j,i) ] /  Ab[ a(i,i) ];
          }
       }
    }
}
// -----------------------------------------------------------------------
void dump_matrix( t_pmatrix matrix ) {
    unsigned int j;
    unsigned int i;
    unsigned int N;

    N = matrix->n;

    for ( j = 1; j <= N; j++ ) {
        printf( "\n  %u. ", j );
        for ( i = 1; i <= N; i++ ) {
            printf( " %f", matrix->elements[ a(j,i) ] );
        }
        printf( " \t b %f", matrix->elements[ a(j,i) ] );
   }
   {
       unsigned int m;
       for ( m = 0; m < matrix->n; m++ ) {
           printf( "\n  x%u  = %f",m + 1, matrix->x[ m ] );
       }
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
// -----------------------------------------------------------------------
void gen_textinput_02( t_pmatrix matrix ) {

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
//    substitute( M1.x, M1.elements, M1.n );


    push_problem_to_device( &M1 );

    int block_size = NMAX;
    dim3 dimBlock(block_size, block_size );

    dim3 dimGrid ( 1 );

    device_gauss_solve<<<dimGrid,dimBlock>>>( M1.device_elements, M1.n, M1.device_x );
    e = cudaGetLastError();
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on add_arrays_gpu: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
//    device_substitute<<<dimGrid,dimBlock>>>( M1.device_x, M1.device_elements, M1.n );

    pull_problem_from_device( &M1 );

    printf( "\n solution: \n" );
    dump_matrix( &M1 );
    e = cudaFree(M1.device_elements);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
    e = cudaFree(M1.device_x);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
}



