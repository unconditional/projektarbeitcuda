#include "cuda.h"
#include <stdio.h>
//#include "mex.h"
/* Kernel to square elements of the array on the GPU */
__global__ void square_elements(float* in, float* out, int N)
{
 
__shared__ float vOut[16];
int idx = blockIdx.x*blockDim.x+threadIdx.x;

if ( idx < N)vOut[idx] = in[idx]*in[idx];

__syncthreads();

if(idx == 0) {
    out[0] = 0;
	int i;
	for ( i = 0; i < N; i++ ) {
	   out[0] += vOut[i];
	}
}

__syncthreads();
if(idx == 0) {
	   out[0] = sqrt(out[0]);
}

}
void square_host(double* pIn, double *pOut, int sizeIn, int sizeOut)
{

int i, j;
double *data1, *data2;
float *data1f, *data2f;
float *data1f_gpu, *data2f_gpu;
int sizeBlock;
sizeBlock = 16;
data1 = pIn;
data2 = pOut;

/* Find the dimensions of the data */

/* Create an mxArray for the output data */

/* Create an input and output data array on the GPU*/
cudaMalloc( (void **) &data1f_gpu,sizeof(float)*sizeIn);
cudaMalloc( (void **) &data2f_gpu,sizeof(float)*sizeOut);
/* Retrieve the input data */

/* Check if the input array is single or double precision */

/* The input array is in double precision, it needs to be converted t
floats before being sent to the card */
data1f = (float *) malloc(sizeof(float)*sizeIn);
for (j = 0; j < sizeIn; j++)
{
data1f[j] = (float) data1[j];
}
    for (i = 0; i < sizeIn; i++)
    {
        printf("data1f[%d] = %f, ", i, data1f[i]);
    }
        printf("\n");

cudaMemcpy( data1f_gpu, data1f, sizeof(float)*sizeIn, cudaMemcpyHostToDevice);

data2f = (float *) malloc(sizeof(float)*sizeOut);
//cudaMemcpy( data2f_gpu, data2f, sizeof(float)*sizeOut, cudaMemcpyHostToDevice);

/* Compute execution configuration using 128 threads per block */
dim3 dimBlock(sizeBlock);
dim3 dimGrid((sizeIn)/dimBlock.x);
if ( (sizeIn) % sizeBlock !=0 ) dimGrid.x+=1;
    
/* Call function on GPU */
square_elements<<<dimGrid,dimBlock>>>(data1f_gpu, data2f_gpu, sizeIn);
cudaError_t e;
e = cudaGetLastError();
if ( e != cudaSuccess)
{
    fprintf(stderr, "CUDA Error on square_elements: '%s' \n", cudaGetErrorString(e));
    exit(-1);
}

/* Copy result back to host */
cudaMemcpy( data2f, data2f_gpu, sizeof(float)*sizeOut, cudaMemcpyDeviceToHost);
    for (i = 0; i < sizeOut; i++)
    {
        printf("data2f[%d] = %f, ", i, data2f[i]);
    }
        printf("\n");


/* Create a pointer to the output data */

/* Convert from single to double before returning */
for (j = 0; j < sizeOut; j++)
{
data2[j] = (double) data2f[j];
}
/* Clean-up memory on device and host */
free(data1f);
free(data2f);
cudaFree(data1f_gpu);
cudaFree(data2f_gpu);
}

int main()
{

    double *pIn, *pOut;
    int sizeIn, sizeOut;
    int i;
    sizeIn = 2;
    sizeOut = 1;
    pIn = (double*)malloc(sizeof(double)*sizeIn);
    pOut = (double*)malloc(sizeof(double)*sizeOut);
    pIn[0] = 3;
    pIn[1] = 4;
    //pIn[2] = 3;
    square_host(pIn, pOut, sizeIn, sizeOut);
	
	printf("output square result");
    for (i = 0; i < sizeOut; i++)
    {	
        printf(" pOut[%d] = %lf, ", i, pOut[i]);
    }
        printf("\n");
	printf("output norm result");
    for (i = 0; i < sizeOut; i++)
    {
		//pOut[i] = sqrt(pOut[i]);
        printf("squre of pOut[%d] = %lf, ", i, pOut[i]);
    }
        printf("\n");
    
   
    free(pIn);
    free(pOut);
    return 0;
}




/* Gateway function */
/*
void mexFunction(int nlhs, mxArray *plhs[],
int nrhs, const mxArray *prhs[])
{
int i, j, m, n;
double *data1, *data2;
float *data1f, *data2f;
float *data1f_gpu, *data2f_gpu;
mxClassID category;
if (nrhs != nlhs)
mexErrMsgTxt("The number of input and output arguments must be the same.");

//Create an mxArray for the output data by buyu 
//plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
//create a float host output variable for float
//data2f = (float *) mxMalloc(sizeof(float));

for (i = 0; i < nrhs; i++)
{
// Find the dimensions of the data 
m = mxGetM(prhs[i]);
n = mxGetN(prhs[i]);

//Create an mxArray for the output data 
//plhs[i] = mxCreateDoubleMatrix(m, n, mxREAL);
  plhs[i] = mxCreateDoubleMatrix(1, 1, mxREAL);


// Create an input and output data array on the GPU
cudaMalloc( (void **) &data1f_gpu,sizeof(float)*m*n);
//cudaMalloc( (void **) &data2f_gpu,sizeof(float)*m*n);
cudaMalloc( (void **) &data2f_gpu,sizeof(float));

// Retrieve the input data 
data1 = mxGetPr(prhs[i]);
// Check if the input array is single or double precision 
category = mxGetClassID(prhs[i]);
if( category == mxSINGLE_CLASS)
{
// The input array is single precision, it can be sent directly to the card
cudaMemcpy( data1f_gpu, data1, sizeof(float)*m*n,
cudaMemcpyHostToDevice);
}
if( category == mxDOUBLE_CLASS)
{
// The input array is in double precision, it needs to be converted t floats before being sent to the card 
data1f = (float *) mxMalloc(sizeof(float)*m*n);
for (j = 0; j < m*n; j++)
{
data1f[j] = (float) data1[j];
}
printf("before copyHost to device \n");
cudaMemcpy( data1f_gpu, data1f, sizeof(float)*n*m, cudaMemcpyHostToDevice);
}

//orginal output
//data2f = (float *) mxMalloc(sizeof(float)*m*n);
data2f = (float *) mxMalloc(sizeof(float));

// Compute execution configuration using 128 threads per block 
dim3 dimBlock(128);
dim3 dimGrid((m*n)/dimBlock.x);
if ( (n*m) % 128 !=0 ) dimGrid.x+=1;
    
printf("before calling GPU \n");
// Call function on GPU 
square_elements<<<dimGrid,dimBlock>>>(data1f_gpu, data2f_gpu, n*m);

printf("before copy result back \n");
// Copy result back to host 
//cudaMemcpy( data2f, data2f_gpu, sizeof(float)*n*m, cudaMemcpyDeviceToHost);
cudaMemcpy( data2f, data2f_gpu, sizeof(float), cudaMemcpyDeviceToHost);
// Create a pointer to the output data 
data2 = mxGetPr(plhs[i]);
// Convert from single to double before returning 

//for (j = 0; j < m*n; j++)
//{
//data2[j] = (double) data2f[j];
//}

printf("before return result to matlab \n");
data2[0] = 0;
data2[0] = (double) data2f[0];

// Clean-up memory on device and host 
mxFree(data1f);
mxFree(data2f);
cudaFree(data1f_gpu);
cudaFree(data2f_gpu);
}// for i

}
*/