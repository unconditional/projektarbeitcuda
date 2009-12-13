
#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

#include "gausskernel.h"
#include "util.h"
#include "problemsamples.h"
#include "idrs.h"

#include "measurehelp.h"

#define ITERATIONS 5

t_matrix M1;



// -----------------------------------------------------------------------



// -----------------------------------------------------------------------
void pull_problem_from_device( t_pmatrix matrix ) {
   cudaError_t e;
    e = cudaMemcpy(  matrix->elements, matrix->device_elements, sizeof(t_ve) * (matrix->n + 1 ) * matrix->n, cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK("cudaMemcpy");

    e = cudaMemcpy(  matrix->x, matrix->device_x, sizeof(t_ve) * matrix->n, cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK("cudaMemcpy");

}
// -----------------------------------------------------------------------
void push_problem_to_device( t_pmatrix matrix ) {


    cudaError_t e;
    e = cudaMalloc ((void **) &matrix->device_x, sizeof(t_ve) * matrix->n );
    CUDA_UTIL_ERRORCHECK("cudaMalloc");

    e = cudaMalloc ((void **) &matrix->device_elements, sizeof(t_ve) * (matrix->n + 1 ) * matrix->n );
    CUDA_UTIL_ERRORCHECK("cudaMalloc");
/*
    e = cudaMemcpy( matrix->device_x, matrix->x , sizeof(t_ve)*matrix->n, cudaMemcpyHostToDevice);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
*/
    e = cudaMemcpy( matrix->device_elements, matrix->elements , sizeof(t_ve) * (matrix->n + 1 ) * matrix->n, cudaMemcpyHostToDevice);
    CUDA_UTIL_ERRORCHECK("cudaMemcpy");

}




// -----------------------------------------------------------------------
// -----------------------------------------------------------------------

void eleminate ( t_ve* Ab, t_ve* x, unsigned int N ) {
    unsigned int i;   // columns
    unsigned int j;   // rows, equitations
    unsigned int k, max;
    t_ve t;

    for ( i = 1; i <= N ; i++ ) {


       max = i;
       for( j = i + 1; j <= N; j++ ) {
           if ( abs( Ab[ ab(j,i) ] ) > abs( Ab[ ab(max,i) ] )  ) {
              max = j;
           }
       }

       for ( k = i; k <= N + 1; k++ ) {
          t              = Ab[ ab(i,k) ];
          Ab[ ab(i,k)   ] = Ab[ ab(max,k) ];
          Ab[ ab(max,k) ] = t;
       }

       for ( j = i +1; j <= N ; j++ ) {
          for ( k = N + 1; k >= i ; k-- ) {
             Ab[ ab(j,k) ] -= Ab[ ab(i,k) ] * Ab[ ab(j,i) ] /  Ab[ ab(i,i) ];
          }
       }


      // substitute ...

        for (j = N; j >= 1; j-- ) {
            t_ve t = 0.0;
            for ( k = j + 1; k <= N; k++ ) {
                    t +=  Ab[ ab(j,k) ] * x[ k - 1 ];
            }
            x[ j - 1 ] = ( Ab[ ab(j,N+1) ] - t ) / Ab[ ab(j,j) ] ;
        }

    }
}
// -----------------------------------------------------------------------



// -----------------------------------------------------------------------

int main()
{
    unsigned int problem;
    cudaError_t e;

//    int block_size = NMAX;
    dim3 dimBlock(  GAUSS_NMAX + 2 );
    dim3 dimGrid ( 1 );

    for ( problem = 1; problem < 5; problem++ ) {
        gen_problemsample( &M1, problem );
        printf( "\n \nRunning problem No. %u , size %u\n", problem, M1.n );
        backup_problem( &M1 );
        if ( M1.n < 0 ) {
            dump_problem( M1.elements, M1.n );
        }
        push_problem_to_device( &M1 );

        float kernel_ms;

        if ( M1.n  <= GAUSS_NMAX ) {

        {
           for ( int i = 0; i < 10; i++ ) {
            device_gauss_solver<<<dimGrid,dimBlock>>>( M1.device_elements, M1.n, M1.device_x );
            e = cudaGetLastError();
            CUDA_UTIL_ERRORCHECK("kernel");
           }
        }
        {
            START_CUDA_TIMER
            for ( int i = 0; i < ITERATIONS; i++ ) {
                device_gauss_solver<<<dimGrid,dimBlock>>>( M1.device_elements, M1.n, M1.device_x );
                e = cudaGetLastError();
                CUDA_UTIL_ERRORCHECK("kernel");
            }

            STOP_CUDA_TIMER( & kernel_ms )
        }

        printf("\nelapsed time GPU: %f ms\n", kernel_ms / ITERATIONS );
        pull_problem_from_device( &M1 );


        if ( M1.n < 9 ) {
           // printf( "\n solution: \n" );
            dump_problem( M1.elements, M1.n );
            dump_x( M1.x, M1.n );
        }
        check_correctness( M1.orgelements, M1.n, M1.x );
        }
        e = cudaFree(M1.device_elements);
        CUDA_UTIL_ERRORCHECK("cudaFree");
        e = cudaFree(M1.device_x);
        CUDA_UTIL_ERRORCHECK("cudaFree");

        float cpu_ms;

        {
            START_CUDA_TIMER

            eleminate ( M1.orgelements, M1.x, M1.n );

            STOP_CUDA_TIMER( &cpu_ms )
        }
        printf("\nelapsed time CPU: %f ms\n \n ------------------------", cpu_ms );
        free_matrix( &M1 );
    }
}



