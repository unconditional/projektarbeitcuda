
#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

#include <time.h>

#include "dotMul_cuda_gpu.h"
#include "dotMul_cpu.h"
#include <time.h>

#define N_PROBLEM 100000
#define ITERSTEPS 2

__host__ void malloc_N( unsigned int size_n, t_ve** M ) {

    t_ve* v =  (t_ve*) malloc( sizeof(t_ve) * size_n  );
    if ( v == NULL) {
	       fprintf(stderr, "sorry, can not allocate memory for you");
	       exit( -1 );
    }
    *M = v;
}

//    cudaMemset ( *pV_d, 0, sizeof(t_ve) * L );

int main()
{
    pt_ve v1, v2, v1_d, v2_d, out, out_d;
    clock_t startclocks, endclock, payoffstart, payoffend, startclockscpu, endclockscpu;
    cudaError_t e;

    int deviceCount;
    cudaGetDeviceCount(&deviceCount);

    if (deviceCount == 0)
        printf("There is no device supporting CUDA\n");

    int dev;
    for (dev = 0; dev < deviceCount; ++dev) {
        cudaDeviceProp deviceProp;
        cudaGetDeviceProperties(&deviceProp, dev);

        printf("\nDevice %d: \"%s\"\n", dev, deviceProp.name);
        printf("  CUDA Capability Major revision number:         %d\n", deviceProp.major);
        printf("  CUDA Capability Minor revision number:         %d\n", deviceProp.minor);
        printf("  Maximum number of threads per block:           %d\n", deviceProp.maxThreadsPerBlock);
    }
    int block_size = 512;
    dim3 dimBlock(block_size);

    printf("\n measureing operation DOTMUL with N = %u, ITERSTEPS %u", N_PROBLEM, ITERSTEPS );
    malloc_N( N_PROBLEM * 3 , &v1 );

    for ( unsigned int N = 1; N <= N_PROBLEM; N *= 10 ) {
        payoffstart = clock();

        e = cudaMalloc ((void **) &v1_d, sizeof(t_ve) * N * 3 );
        CUDA_UTIL_ERRORCHECK("cudaMalloc &v1_d");

        v2_d  = &v1_d[N    ];
        out_d = &v1_d[N * 2];

        e = cudaMemcpy(  v1_d, v1, sizeof(t_ve) * N * 2 , cudaMemcpyHostToDevice);
        CUDA_UTIL_ERRORCHECK("cudaMemcpy v1_d");

        payoffend = clock();
        startclocks = clock( );

        dim3 dimGrid ( N / block_size + 1 );

        for ( unsigned int i = 0; i < ITERSTEPS; i++ ) {

            device_dotMul<<<dimGrid,dimBlock>>>(v1_d, v2_d, out_d, N );
        	e = cudaGetLastError();
            CUDA_UTIL_ERRORCHECK("Kernel device_dotMul")
        }
        endclock = clock( );

        e = cudaFree(v1_d);
        CUDA_UTIL_ERRORCHECK("cudaFree")

        /* ------------------------------------------------------------ */
		startclockscpu = clock( );

        v2  = &v1[N];
        out = &v1[N*2];

		for ( unsigned int i = 0; i < ITERSTEPS; i++ ) {
		    v1[1]++; /* ensure opearation is not answered from cache */
		    dotMul_cpu(v1, v2, out, N );
		}
        endclockscpu   = clock( );
        /* ------------------------------------------------------------ */

        printf( "\n ----------------------------------------------------- \n N = %u, ITER = %u", N, ITERSTEPS );
	    printf( "\n GPU: %f seconds,  clocks: %u : CLOCKS_PER_SEC %u \n", ( (float) ( endclock - startclocks)) / CLOCKS_PER_SEC / ITERSTEPS, endclock - startclocks, CLOCKS_PER_SEC );
	    printf( "\n CPU: %f seconds,  clocks: %u : CLOCKS_PER_SEC %u \n", ( (float) ( endclockscpu - startclockscpu)) / CLOCKS_PER_SEC / ITERSTEPS, endclockscpu - startclockscpu, CLOCKS_PER_SEC );
	    printf( "\n cudamemcopy payoff %f secsonds (%u clocks)", (float) (payoffend - payoffstart) / CLOCKS_PER_SEC, payoffend - payoffstart );
    }
}
