#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

#include "measurehelp.h"
#include "kernels/gausskernel.h"

__host__ void eleminate ( t_ve* Ab, t_ve* x, t_mindex N ) {
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

__host__ void dosolver (  t_mindex N_in ) {


    //printf("\n%u\t%f\t%f\t%f", N_in, gpudot_ms, cpudot_ms, gpudotwom_ms  );
    cudaError_t e;
    size_t devsize = SIZE_VE * N_in * ( N_in + 2 )   ;

    pt_ve abx, x, abx_d, x_d;

    abx = ( pt_ve ) malloc( devsize );
    if (  abx == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you P.pElement"); exit( -1 ); }

    t_mindex N =  N_in;

    x = &abx[ N_in * ( N_in + 1 ) ];

    for ( t_mindex m = 1; m <= N_in; m++ ) {
        for ( t_mindex n = 1; n <= N_in + 1 ; n++ ) {
            abx[ ab( m, n ) ] =  ((t_ve) rand()) / RAND_MAX - 0.5;
        }
        x[m-1] = 0;
    }

    e = cudaMalloc ( &abx_d, devsize );
    CUDA_UTIL_ERRORCHECK("cudaMalloc");

    e = cudaMemcpy( abx_d, abx, devsize, cudaMemcpyHostToDevice);
    CUDA_UTIL_ERRORCHECK("cudaMemcpy");

    x_d =  &abx_d[ N_in * ( N_in + 1 ) ];

    dim3 dimGridgauss( 1 );
    dim3 dimBlockgauss(512);

   float gpugauss_ms;

    {
           START_CUDA_TIMER

           device_gauss_solver<<<dimGridgauss,dimBlockgauss>>>( abx_d, N_in, x_d ); /* vec m is s+1 column of M - see memory allocation plan  */
           e = cudaGetLastError();  CUDA_UTIL_ERRORCHECK("device_gauss_solver<<<dimGridgauss,dimBlockgauss>>>( M, s, c )");

           STOP_CUDA_TIMER( &gpugauss_ms )

    }

   float cpugauss_ms;

    {
        START_CUDA_TIMER
        eleminate ( abx, x, N_in );

        STOP_CUDA_TIMER( &cpugauss_ms )
    }
    printf("\n%u\t%f\t%f", N_in, gpugauss_ms, cpugauss_ms  );
}


int main( int argc, char *argv[] )
{
   printf("\n measure gauss");
   printf( "\n Build configuration: sizeof(t_ve) = %u \n", sizeof(t_ve));



    int deviceCount;
    cudaGetDeviceCount(&deviceCount);

    if (deviceCount == 0)
        printf("There is no device supporting CUDA\n");

    int dev;
    for (dev = 0; dev < deviceCount; ++dev) {
        cudaDeviceProp deviceProp;
        cudaGetDeviceProperties(&deviceProp, dev);



        printf("\nDevice %d: \"%s\"\n \n", dev, deviceProp.name);
        printf("  Number of multiprocessors:                     %d\n", deviceProp.multiProcessorCount);
        printf("  CUDA Capability Major revision number:         %d\n", deviceProp.major);
        printf("  CUDA Capability Minor revision number:         %d\n", deviceProp.minor);
        printf("  Maximum number of threads per block:           %d\n", deviceProp.maxThreadsPerBlock);
    }

   t_mindex maxn = 10;

   if ( argc > 1 ) {
      maxn = atoi( argv[1] );
   }

    for ( t_mindex n = 3; n < maxn ; n++ ) {
        dosolver( n );
    }
}

