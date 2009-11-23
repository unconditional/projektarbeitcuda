
#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

#include "gausskernel.h"
#include "util.h"
#include "problemsamples.h"

#define NMAX 22




t_matrix M1;



// -----------------------------------------------------------------------



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
    unsigned int problem;
    cudaError_t e;

    int block_size = NMAX;
    dim3 dimBlock(block_size, block_size );
    dim3 dimGrid ( 1 );

    for ( problem = 1; problem < 3; problem++ ) {
        gen_problemsample( &M1, 2 );
        printf( "\n \nRunning problem No. %u\n", problem );
        backup_problem( &M1 );
        dump_problem( M1.elements, M1.n );
        push_problem_to_device( &M1 );

        device_gauss_solver<<<dimGrid,dimBlock>>>( M1.device_elements, M1.n, M1.device_x );

        e = cudaGetLastError();
        if( e != cudaSuccess )
        {
            fprintf(stderr, "CUDA Error on add_arrays_gpu: '%s' \n", cudaGetErrorString(e));
            exit(-3);
        }


        pull_problem_from_device( &M1 );
        printf( "\n solution: \n" );

        dump_problem( M1.elements, M1.n );
        dump_x( M1.x, M1.n );
        check_correctness( M1.orgelements, M1.n, M1.x );
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
        free_matrix( &M1 );
    }
}



