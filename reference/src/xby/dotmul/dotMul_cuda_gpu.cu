#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
//#include "mex.h"
/* Kernel to square elements of the array on the GPU */
__global__ void device_dotMul(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N)
{
 
__shared__ float vOut[16];
int idx = blockIdx.x*blockDim.x+threadIdx.x;

if ( idx < N)vOut[idx] = in1[idx]*in2[idx];

__syncthreads();

if(idx == 0) {
    out[0] = 0;
	int i;
	for ( i = 0; i < N; i++ ) {
	   out[0] += vOut[i];
	}
}

__syncthreads();

}
void host_dotMul(double* pIn1, double* pIn2,double *pOut, int sizeIn, int sizeOut)
{

int i, j;
double *data_in1_d, *data_in2_d, *data_out_d;
float *data_in1_f, *data_in2_f, *data_out_f;
float *data_in1_f_gpu, *data_in2_f_gpu , *data_out_f_gpu;
int sizeBlock;
sizeBlock = 16;

// get Input data pointer
data_in1_d = pIn1;
data_in2_d = pIn2;
// get Ouput data pointer
data_out_d = pOut;


/* Find the dimensions of the data */

/* Create an mxArray for the output data */

/* Create an input and output data array on the GPU*/
cudaMalloc( (void **) &data_in1_f_gpu,sizeof(t_ve)*sizeIn);
cudaMalloc( (void **) &data_in2_f_gpu,sizeof(t_ve)*sizeIn);
cudaMalloc( (void **) &data_out_f_gpu,sizeof(t_ve)*sizeOut);
/* Retrieve the input data */

/* Check if the input array is single or double precision */

/* The input array is in double precision, it needs to be converted t
floats before being sent to the card */
data_in1_f = (t_ve *) malloc(sizeof(t_ve)*sizeIn);
data_in2_f = (t_ve *) malloc(sizeof(t_ve)*sizeIn);

data_out_f = (t_ve *) malloc(sizeof(t_ve)*sizeOut);

for (j = 0; j < sizeIn; j++)
{
data_in1_f[j] = (t_ve) data_in1_d[j];
data_in2_f[j] = (t_ve) data_in2_d[j];
}
    for (i = 0; i < sizeIn; i++)
    {
        printf("data_in1_f[%d] = %f, ", i, data_in1_f[i]);
    }
        printf("\n");

cudaMemcpy( data_in1_f_gpu, data_in1_f, sizeof(t_ve)*sizeIn, cudaMemcpyHostToDevice);
cudaMemcpy( data_in2_f_gpu, data_in2_f, sizeof(t_ve)*sizeIn, cudaMemcpyHostToDevice);


//cudaMemcpy( data2f_gpu, data2f, sizeof(float)*sizeOut, cudaMemcpyHostToDevice);

/* Compute execution configuration using 128 threads per block */
dim3 dimBlock(sizeBlock);
dim3 dimGrid((sizeIn)/dimBlock.x);
if ( (sizeIn) % sizeBlock !=0 ) dimGrid.x+=1;
    
/* Call function on GPU */
device_dotMul<<<dimGrid,dimBlock>>>(data_in1_f_gpu, data_in2_f_gpu, data_out_f_gpu, sizeIn);
cudaError_t e;
e = cudaGetLastError();
if ( e != cudaSuccess)
{
    fprintf(stderr, "CUDA Error on square_elements: '%s' \n", cudaGetErrorString(e));
    exit(-1);
}

/* Copy result back to host */
cudaMemcpy( data_out_f, data_out_f_gpu, sizeof(float)*sizeOut, cudaMemcpyDeviceToHost);
    for (i = 0; i < sizeOut; i++)
    {
        printf("data_out_f[%d] = %f, ", i, data_out_f[i]);
    }
        printf("\n");


/* Create a pointer to the output data */

/* Convert from single to double before returning */
for (j = 0; j < sizeOut; j++)
{
data_out_d[j] = (double) data_out_f[j];
}
/* Clean-up memory on device and host */
free(data_in1_f);
free(data_in2_f);
free(data_out_f);
cudaFree(data_in1_f_gpu);
cudaFree(data_in2_f_gpu);
cudaFree(data_out_f_gpu);
}

int main()
{

    double *pIn1, *pIn2,*pOut;
    int sizeIn, sizeOut;
    int i;
    sizeIn = 3;
    sizeOut = 1;
    pIn1 = (double*)malloc(sizeof(double)*sizeIn);
	pIn2 = (double*)malloc(sizeof(double)*sizeIn);
    pOut = (double*)malloc(sizeof(double)*sizeOut);
    pIn1[0] = 1;
    pIn1[1] = 2;
    pIn1[2] = 3;
	pIn2[0] = 1;
    pIn2[1] = 1;
    pIn2[2] = 1;
    host_dotMul(pIn1, pIn2, pOut, sizeIn, sizeOut);
	
	printf("output square result");
    for (i = 0; i < sizeOut; i++)
    {	
        printf(" pOut[%d] = %lf, ", i, pOut[i]);
    }
        printf("\n");
	printf("output norm result");
    for (i = 0; i < sizeOut; i++)
    {
		pOut[i] = sqrt(pOut[i]);
        printf("squre of pOut[%d] = %lf, ", i, pOut[i]);
    }
        printf("\n");
    
   
    free(pIn1);
	free(pIn2);
    free(pOut);
    return 0;
}
