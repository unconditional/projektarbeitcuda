#include "stdio.h"

/*  First Hello World, Achim Grolms, 2009-10-20  */
//  nvcc -deviceemu -o add_vector_emu add_vector.cu


typedef float        t_ve   ; // vector element, change this to double if required
typedef unsigned int t_vidx ; // index of vector elements

#define N 400000

__global__ void add_arrays_gpu( t_ve *in1, t_ve *in2, t_ve *out, t_vidx Ntot)
{
	t_vidx i = threadIdx.y * blockDim.x + threadIdx.x;
	if ( i < Ntot )
		out[i] = in1[i] + in2[i];
}

int main()
{

    cudaError_t e;

    cudaEvent_t start, stop;
    float time;

	/* pointers to host memory */
	t_ve *a, *b, *c;
	/* pointers to device memory */
	t_ve *a_d, *b_d, *c_d;
//	t_vidx N=18;
	t_vidx i;

    e = cudaEventCreate(&start);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaEventCreate: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
    e = cudaEventCreate(&stop);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaEventCreate: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

	/* Allocate arrays a, b and c on host*/
	a = (t_ve*) malloc(N*sizeof(t_ve));
	b = (t_ve*) malloc(N*sizeof(t_ve));
	c = (t_ve*) malloc(N*sizeof(t_ve));

	/* Allocate arrays a_d, b_d and c_d on device*/
	e = cudaMalloc ((void **) &a_d, sizeof(t_ve)*N);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMalloc: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
	e = cudaMalloc ((void **) &b_d, sizeof(t_ve)*N);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMalloc: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
	e = cudaMalloc ((void **) &c_d, sizeof(t_ve)*N);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMalloc: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

	/* Initialize arrays a and b */
	for (i=0; i<N; i++)
	{
		a[i] = (float) i;
		b[i] = (float) i;
        c[i] = (float) -1111;
	}


	/* Copy data from host memory to device memory */
	e = cudaMemcpy(a_d, a, sizeof(t_ve)*N, cudaMemcpyHostToDevice);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
	e = cudaMemcpy(b_d, b, sizeof(t_ve)*N, cudaMemcpyHostToDevice);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

	/* Compute the execution configuration */

	int block_size = 512;             // threads per block
    int grid_x     =  N / block_size + 1 ;
    int grid_y     =  1;

	dim3 dimBlock(block_size);
	dim3 dimGrid ( grid_x, grid_y );        // threads = blocksize * gridx * grid y

	/* Add arrays a and b, store result in c */

    e = cudaEventRecord( start, 0 );
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaEventRecord: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

	add_arrays_gpu<<<dimGrid,dimBlock>>>(a_d, b_d, c_d, N);
    e = cudaGetLastError();
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on add_arrays_gpu: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

    e = cudaEventRecord( stop, 0 );
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaEventRecord: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

    e = cudaEventSynchronize( stop );
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaEventRecord: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

    e = cudaEventElapsedTime( &time, start, stop );
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaEventElapsedTime: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

	/* Copy data from deveice memory to host memory */
	e = cudaMemcpy(c, c_d, sizeof(float)*N, cudaMemcpyDeviceToHost);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }

	/* Print c */
//	for (i=0; i<N; i++)
//		printf(" c[%d]=%f\n",i,c[i]);

	/* Free the memory */

    e = cudaFree(a_d);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
    e = cudaFree(b_d);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
    e = cudaFree(c_d);
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaMemcpy: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
	free(a); free(b); free(c);

    printf( "kernel runtime (size %d): %f milliseconds\n", N , time );
}

