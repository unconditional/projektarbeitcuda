#include "stdio.h"

/*  First Hello World, Achim Grolms, 2009-10-20  */
//  nvcc -deviceemu -o add_vector_emu add_vector.cu


__global__ void add_arrays_gpu( float *in1, float *in2, float *out, int Ntot)
{
	int i = blockDim.x*blockIdx.x+threadIdx.x;
	if ( i )
		out[i] = in1[i] + in2[i];
}

int main()
{
	/* pointers to host memory */
	float *a, *b, *c;
	/* pointers to device memory */
	float *a_d, *b_d, *c_d;
	int N=1800000;
    long i;

	/* Allocate arrays a, b and c on host*/
	a = (float*) malloc(N*sizeof(float));
	b = (float*) malloc(N*sizeof(float));
	c = (float*) malloc(N*sizeof(float));

	/* Allocate arrays a_d, b_d and c_d on device*/
	cudaMalloc ((void **) &a_d, sizeof(float)*N);
	cudaMalloc ((void **) &b_d, sizeof(float)*N);
	cudaMalloc ((void **) &c_d, sizeof(float)*N);

	/* Initialize arrays a and b */
	for (i=0; i<N; i++)
	{
		a[i] = (float) 1;
		b[i] = (float) -1;
	}


	/* Copy data from host memory to device memory */
	cudaMemcpy(a_d, a, sizeof(float)*N, cudaMemcpyHostToDevice);
	cudaMemcpy(b_d, b, sizeof(float)*N, cudaMemcpyHostToDevice);

	/* Compute the execution configuration */
	int block_size=64;
	dim3 dimBlock(block_size);
	dim3 dimGrid ( (N/dimBlock.x) + (!(N%dimBlock.x)?0:1) );

	/* Add arrays a and b, store result in c */
	add_arrays_gpu<<<dimGrid,dimBlock>>>(a_d, b_d, c_d, N);

	/* Copy data from deveice memory to host memory */
	cudaMemcpy(c, c_d, sizeof(float)*N, cudaMemcpyDeviceToHost);

	/* Print c */
	for (i=0; i<N; i++)
		printf(" c[%d]=%f, a[%d]=%f, b[%d]=%f\n",i,c[i],i,a[i],i,b[i]);

	/* Free the memory */

    cudaFree(a_d); cudaFree(b_d);cudaFree(c_d);
	free(a); free(b); free(c);


}

