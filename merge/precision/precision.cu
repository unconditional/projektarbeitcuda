#include <stdlib.h>
#include <stdio.h>

#define CUDA_UTIL_ERRORCHECK(MSG)        if( e != cudaSuccess ) \
        {\
            fprintf(stderr, "*** Error on CUDA operation '%s': '%s'*** \n\n", MSG, cudaGetErrorString(e));\
            exit(-3);\
        }\

#ifndef PRJACUDADOUBLE
typedef float        t_ve; /* base type of Matrizes: 'float' or 'double' */
#endif

#ifdef PRJACUDADOUBLE
typedef double       t_ve; /* base type of Matrizes: 'float' or 'double' */
#endif

int N = 10;

__global__ void minikernel(  int N_in, t_ve* out  ) {

    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N ) {
       out[i] = 1234;
    }
}


int  main () {
   printf("\n the precision- and compile-option checker \n");
   printf("\n sizeof(t_ve) = %u", sizeof(t_ve));


    int deviceCount;
    cudaGetDeviceCount(&deviceCount);

    if (deviceCount == 0)
        printf("There is no device supporting CUDA\n");

    int dev;
    for (dev = 0; dev < deviceCount; ++dev) {
        cudaDeviceProp deviceProp;
        cudaGetDeviceProperties(&deviceProp, dev);

        printf("\n\n\nDevice %d: \"%s\"\n", dev, deviceProp.name);
        printf("  CUDA Capability Major revision number:         %d\n", deviceProp.major);
        printf("  CUDA Capability Minor revision number:         %d\n", deviceProp.minor);
        printf("  Number of multiprocessors:                     %d\n", deviceProp.multiProcessorCount);
    }

    t_ve* hostmem = (t_ve*) malloc( sizeof(t_ve) * N  );

    if ( hostmem == NULL ) { printf("sorry, can not allocate memory for you"); exit(-1); }

    t_ve* devmem;
    cudaError_t e;

    e = cudaMalloc ( &devmem , sizeof(t_ve) * N );
    CUDA_UTIL_ERRORCHECK("cudaMalloc");

//    e = cudaMemset (devmem, 0, sizeof(t_ve) * N );
//    CUDA_UTIL_ERRORCHECK("cudaMalloc");

    dim3 dimGrid( 1 );
    dim3 dimBlock(512);

    minikernel<<<dimGrid,dimBlock>>>( N,  devmem );

    e = cudaGetLastError();
    CUDA_UTIL_ERRORCHECK("minikernel");

    e = cudaMemcpy( hostmem, devmem, sizeof(t_ve) * N , cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");

    for  ( int i = 0; i < N; i++ ) {
        printf("\nout[%u] = %f", i, hostmem[i]  );
    }

    free(hostmem);
    e = cudaFree( devmem);
    CUDA_UTIL_ERRORCHECK("cudaMalloc");
}

