#include "stdio.h"

/*  First Hello World, Achim Grolms, 2009-10-20  */
//  nvcc -deviceemu -o add_vector_emu add_vector.cu


typedef float        t_ve   ; // vector element, change this to double if required
typedef unsigned int t_vidx ; // index of vector elements

#define N 4000

__global__ void add_arrays_gpu( t_ve *in1, t_ve *in2, t_ve *out, t_vidx Ntot)
{
	t_vidx i = blockIdx.x * blockDim.x + threadIdx.x;
	if ( i < Ntot )
		out[i] = in1[i] + in2[i];
}

int main()
{
	/* pointers to host memory */
	t_ve *a, *b, *c;
	/* pointers to device memory */
	t_ve *a_d, *b_d, *c_d;
//	t_vidx N=18;
	t_vidx i;

	/* Allocate arrays a, b and c on host*/
	a = (t_ve*) malloc(N*sizeof(t_ve));
	b = (t_ve*) malloc(N*sizeof(t_ve));
	c = (t_ve*) malloc(N*sizeof(t_ve));

	/* Allocate arrays a_d, b_d and c_d on device*/
	cudaMalloc ((void **) &a_d, sizeof(t_ve)*N);
	cudaMalloc ((void **) &b_d, sizeof(t_ve)*N);
	cudaMalloc ((void **) &c_d, sizeof(t_ve)*N);

	/* Initialize arrays a and b */
	for (i=0; i<N; i++)
	{
		a[i] = (float) i;
		b[i] = (float) i;
	}


	/* Copy data from host memory to device memory */
	cudaMemcpy(a_d, a, sizeof(t_ve)*N, cudaMemcpyHostToDevice);
	cudaMemcpy(b_d, b, sizeof(t_ve)*N, cudaMemcpyHostToDevice);

	/* Compute the execution configuration */

	int block_size = 200;             // threads per block
    int grid_x     = 100;
    int grid_y     = 1;

	dim3 dimBlock(block_size);
	dim3 dimGrid ( grid_x, grid_y );        // threads = blocksize * gridx * grid y

	/* Add arrays a and b, store result in c */
	add_arrays_gpu<<<dimGrid,dimBlock>>>(a_d, b_d, c_d, N);

	/* Copy data from deveice memory to host memory */
	cudaMemcpy(c, c_d, sizeof(float)*N, cudaMemcpyDeviceToHost);

	/* Print c */
	for (i=0; i<N; i++)
		printf(" c[%d]=%f\n",i,c[i]);

	/* Free the memory */

    cudaFree(a_d); cudaFree(b_d);cudaFree(c_d);
	free(a); free(b); free(c);


}

