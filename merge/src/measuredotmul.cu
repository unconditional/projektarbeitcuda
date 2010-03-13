#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

#include "measurehelp.h"

#include "kernels/dotMul_cuda_gpu.h"

#include <time.h>


__host__ t_ve cpu_imp( t_mindex N, t_ve *in1, t_ve *in2 ) {

    t_ve calresult = 0;

    for( t_mindex i = 0; i < N; i++ ) {
        calresult += in1[i] * in2[i];
    }
    return calresult;
}

__host__ void dodotmul (  t_mindex N_in ) {

    cudaError_t e;
    pt_ve v1, v2, vout, vd1, vd2, vdout;

    size_t devsize = SIZE_VE *  ( N_in + 512 ) * 3 ;

    v1 = ( pt_ve ) malloc( devsize );
    if (  v1 == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you P.pElement"); exit( -1 ); }


    memset( v1, 0, devsize );

    v2   = &v1[ N_in + 512];
    vout = &v2[ N_in + 512 ];

    for ( t_mindex i = 0; i < N_in; i++ ) {
        v1[i]   = 1;
        v2[i]   = 2;
        vout[i] = 0;
    }

    dim3 dimBlock(512);
    dim3 dimGridsub( N_in / 512 + 1 );

    e = cudaMalloc ( &vd1 , devsize );
    CUDA_UTIL_ERRORCHECK("cudaMalloc");

    e = cudaMemcpy( vd1, v1, devsize, cudaMemcpyHostToDevice);
    CUDA_UTIL_ERRORCHECK("cudaMemcpy");

    vd2   = &vd1[ N_in + 512 ];
    vdout = &vd2[ N_in + 512 ];



   float gpudot_ms;

   {
            START_CUDA_TIMER

            kernel_dotmul<<<dimGridsub,dimBlock>>>( vd1, vd2, vdout ) ;
            e = cudaGetLastError();
            CUDA_UTIL_ERRORCHECK("device_dotMul");

             e = cudaMemcpy( vout, vdout, SIZE_VE *  ( N_in / 512 + 1 ) , cudaMemcpyDeviceToHost);
             CUDA_UTIL_ERRORCHECK("cudaMemcpy( h_om1, om1, sizeof(t_ve) * N * 2, cudaMemcpyDeviceToHost)");

             t_ve  sum = 0;

              for ( t_mindex blockidx = 0; blockidx < N_in/ 512 + 1; blockidx++ ) {
                  sum += vout[blockidx];
              }
              //printf("GPU result: %f", sum );

              STOP_CUDA_TIMER( &gpudot_ms )

    }

   float gpudotwom_ms;

   {
            START_CUDA_TIMER

            kernel_dotmul<<<dimGridsub,dimBlock>>>( vd1, vd2, vdout ) ;
            e = cudaGetLastError();
            CUDA_UTIL_ERRORCHECK("device_dotMul");

            // e = cudaMemcpy( vout, vdout, SIZE_VE *  ( N_in / 512 + 1 ) , cudaMemcpyDeviceToHost);
            // CUDA_UTIL_ERRORCHECK("cudaMemcpy( h_om1, om1, sizeof(t_ve) * N * 2, cudaMemcpyDeviceToHost)");

             t_ve  sum = 0;

              //for ( t_mindex blockidx = 0; blockidx < N_in/ 512 + 1; blockidx++ ) {
              //    sum += vout[blockidx];
              //}
              //printf("GPU result: %f", sum );

              STOP_CUDA_TIMER( &gpudotwom_ms )

    }

   float cpudot_ms;

    {
         START_CUDA_TIMER
         t_ve cpures = cpu_imp( N_in, v1, v2 );
         STOP_CUDA_TIMER( &cpudot_ms )
    }


    e = cudaFree( vd1 );
    CUDA_UTIL_ERRORCHECK("e = cudaFree( devmem );");

    free( v1 );

    printf("\n%u\t%f\t%f\t%f", N_in, gpudot_ms, cpudot_ms, gpudotwom_ms  );
}

int main( int argc, char *argv[] )
{
   printf("\n measure dotmul");
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




   t_mindex order  = 3;

   if ( argc > 1 ) {
      order = atoi( argv[1] );
   }
   t_mindex  nbase = 10;
   for ( t_mindex o = 0; o < order; o++ ) {
      t_mindex n = nbase;
       for ( int i = 0; i < 9; i++ ) {
           dodotmul( n );
           n += nbase;
       }
       nbase *= 10;
   }
}

