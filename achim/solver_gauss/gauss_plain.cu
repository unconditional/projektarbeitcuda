
#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

#include "gausskernel.h"
#include "util.h"
#include "problemsamples.h"
#include "idrs.h"
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
    e = cudaMalloc ((void **) &matrix->device_x, sizeof(t_ve) * matrix->n );
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
/*
    e = cudaMemcpy( matrix->device_x, matrix->x , sizeof(t_ve)*matrix->n, cudaMemcpyHostToDevice);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
*/
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

int main()
{
    unsigned int problem;
    cudaError_t e;

    int block_size = NMAX;
    dim3 dimBlock( block_size, block_size );
    dim3 dimGrid ( 1 );

    for ( problem = 1; problem < 5; problem++ ) {
        gen_problemsample( &M1, problem );
        printf( "\n \nRunning problem No. %u , size %u\n", problem, M1.n );
        backup_problem( &M1 );
        if ( M1.n < 9 ) {
            dump_problem( M1.elements, M1.n );
        }
        push_problem_to_device( &M1 );

        if ( M1.n <= block_size ) {
        device_gauss_solver<<<dimGrid,dimBlock>>>( M1.device_elements, M1.n, M1.device_x );

        e = cudaGetLastError();
        if( e != cudaSuccess )
        {
            fprintf(stderr, "CUDA Error on add_arrays_gpu: '%s' \n", cudaGetErrorString(e));
            exit(-3);
        }

        }

        pull_problem_from_device( &M1 );


        if ( M1.n < 9 ) {
            printf( "\n solution: \n" );
            dump_problem( M1.elements, M1.n );
            dump_x( M1.x, M1.n );
        }
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



