// compile command
#include "stdio.h"

// Device code
__global__ void VecAdd(float* A, float* B, float* C)
{
int i = threadIdx.x;
if (i < 8){
	C[i] = A[i] + B[i];
}

}
// Host code
int main()
{
long VECTOR_SIZE=18;
int i = 0;
// Allocate vectors in host memory
float *h_A,*h_B,*h_C;
h_A = (float*)malloc(VECTOR_SIZE*sizeof(float));
h_B = (float*)malloc(VECTOR_SIZE*sizeof(float));
h_C = (float*)malloc(VECTOR_SIZE*sizeof(float));
for(i = 0;i<VECTOR_SIZE;i++)
{
	h_A[i]=(float)1;
	h_B[i]=(float)1;
	h_C[i]=(float)0;
}
// Allocate vectors in device memory
size_t size = VECTOR_SIZE * sizeof(float);
float *d_A,*d_B,*d_C;
cudaMalloc((void**)&d_A, size);
cudaMalloc((void**)&d_B, size);
cudaMalloc((void**)&d_C, size);
// Copy vectors from host memory to device memory
// h_A and h_B are input vectors stored in host memory
cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
// Invoke kernel
int threadsPerBlock = 256;
int blocksPerGrid;
blocksPerGrid =VECTOR_SIZE+threadsPerBlock-1;
blocksPerGrid=blocksPerGrid/threadsPerBlock;
VecAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C);
// Copy result from device memory to host memory
// h_C contains the result in host memory
cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
//output result vector C
for(i=0;i<VECTOR_SIZE;i++)
printf("h_A[%d]=%f,h_B[%d]=%f,h_C[%d]=%f \n",i,h_A[i],i,h_B[i],i,h_C[i]);


// Free device memory
cudaFree(d_A);
cudaFree(d_B);
cudaFree(d_C);
free(h_A);
free(h_B);
free(h_C);
}