
#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

#include <time.h>

#include "dotMul_cuda_gpu.h"
#include "dotMul_cpu.h"
#include "addvector_cpu.h"

#include <time.h>

#define N_PROBLEM 10000
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
    pt_ve   out, out_d, hostmem;
    clock_t startclocks, endclock, payoffstart, payoffend, startclockscpu, endclockscpu;
    cudaError_t e;

    cudaEvent_t start_host,stop_host;
    float et;
    float et_gpu;
    int deviceCount;
    cudaGetDeviceCount(&deviceCount);

     e = cudaEventCreate( &start_host );
     CUDA_UTIL_ERRORCHECK("cudaEventCreate");
     e = cudaEventCreate( &stop_host );
     CUDA_UTIL_ERRORCHECK("cudaEventCreate");

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

    int block_size = DEF_BLOCKSIZE ;

    printf("working with blocksize %u \n", block_size );

    dim3 dimBlock(block_size);

    printf("\n measureing operation DOTMUL with N = %u, ITERSTEPS %u", N_PROBLEM, ITERSTEPS );
    //malloc_N( N_PROBLEM * 3 , &v1 );

    for ( unsigned int N = 1; N <= N_PROBLEM; N *= 10 ) {


		malloc_N( N * 3, &hostmem );

        t_ve*       devivemem;
		//t_ve* A   = &hostmem[0];
		//t_ve* b   = &hostmem[ N * N ];
		//t_ve* out = &hostmem[ N * N + N];



        payoffstart = clock();

        e = cudaMalloc ((void **) &devivemem, sizeof(t_ve) * N * 3 );
        CUDA_UTIL_ERRORCHECK("cudaMalloc &devivemem");

		t_ve* in_1   = &devivemem[0];
		//t_ve* b_d   = &devivemem[ N * N ];
		//t_ve* out_d = &devivemem[ N * N + N];

        e = cudaMemcpy(  devivemem, hostmem, sizeof(t_ve) * N * 2 , cudaMemcpyHostToDevice);
        CUDA_UTIL_ERRORCHECK("cudaMemcpy v1_d");

        //e = cudaMemset ( out_d, 0, sizeof(t_ve) * (N + 1) );
        CUDA_UTIL_ERRORCHECK("cudaMemset ( out_d, 0)");

        payoffend = clock();
        startclocks = clock( );

        dim3 dimGrid ( N / block_size + 1 );

        //for ( unsigned int i = 0; i < ITERSTEPS; i++ ) {
        {
            cudaEvent_t start,stop;
            e = cudaEventCreate( &start );
            CUDA_UTIL_ERRORCHECK("cudaEventCreate");
            e = cudaEventCreate( &stop );
            CUDA_UTIL_ERRORCHECK("cudaEventCreate");
            e= cudaEventRecord(start,0);
            CUDA_UTIL_ERRORCHECK("cudaEventRecord");

            //device_dotMul<<<dimGrid,dimBlock>>>(v1_d, v2_d, out_d, N );
            //matrixMul_kernel<<<dimGrid,dimBlock>>>( out_d,  A_d, b_d, N, N);

        	e = cudaGetLastError();
            CUDA_UTIL_ERRORCHECK("Kernel matrixMul_kernel")

            e= cudaEventRecord(stop,0 );
            CUDA_UTIL_ERRORCHECK("cudaEventRecord");
            e = cudaEventSynchronize(stop);
            CUDA_UTIL_ERRORCHECK("cudaEventSynchronize");
            e = cudaEventElapsedTime( &et_gpu, start, stop );
        }
        //}
        endclock = clock( );


        /* ------------------------------------------------------------ */
		startclockscpu = clock( );

            e= cudaEventRecord(start_host,0);
            CUDA_UTIL_ERRORCHECK("cudaEventRecord");


		    //matrixMul_cpu( out,  A, b, N, N);


            e= cudaEventRecord(stop_host,0 );
            CUDA_UTIL_ERRORCHECK("cudaEventRecord");
            e = cudaEventSynchronize(stop_host);
            CUDA_UTIL_ERRORCHECK("cudaEventSynchronize");
            e = cudaEventElapsedTime( &et, start_host, stop_host );
		//}
        endclockscpu   = clock( );
        /* ------------------------------------------------------------ */

        printf( "\n ----------------------------------------------------- \n N = %u, ITER = %u", N, ITERSTEPS );
	    printf( "\n GPU: %f seconds,  clocks: %u : CLOCKS_PER_SEC %u \n", ( (float) ( endclock - startclocks)) / CLOCKS_PER_SEC / ITERSTEPS, endclock - startclocks, CLOCKS_PER_SEC );
	    printf( "\n CPU: %f seconds,  clocks: %u : CLOCKS_PER_SEC %u \n", ( (float) ( endclockscpu - startclockscpu)) / CLOCKS_PER_SEC / ITERSTEPS, endclockscpu - startclockscpu, CLOCKS_PER_SEC );
        printf( "\n CPU, measured by CUDA event: %f ms", et );
        printf( "\n GPU, measured by CUDA event: %f ms", et_gpu );
	    printf( "\n cudamemcopy payoff %f secsonds (%u clocks)", (float) (payoffend - payoffstart) / CLOCKS_PER_SEC, payoffend - payoffstart );

        e = cudaFree(devivemem);
        CUDA_UTIL_ERRORCHECK("cudaFree")
        free( hostmem );
    }
}
