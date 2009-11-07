#include "cuda.h"
#include "mex.h"
_global_ void norm_elements(float* pIn, float* pOut, int N)
{
 		 int idx = blockIdx.x*blockDim.x+threadIdx.x;
 		 if(idx < N)
		 {
		  		*pOut += pIn[idx]*pIn[idx];
 		 }
		   
}

void mexFunction(int outArraySize, mxArray *pOutArray[], int inArraySize, const mxArray *pInArray[])
{
  	 int i, j, m, n;
  	 //pointer to matlab input array and output array 
 	 double *data1, *data2;
 	 
 	 //int rowMax, colMax;
 	 //double *pMatrix, *pX;
 	 //pointers of Host data with double precision
	 float *data1f, *data2f;
 	 // pointers of GPU data
     float *data1f_gpu, *data2f_gpu;
 	 m = mxGetM(pInArray);
 	 n = mxGetN(pInArray);
 	 
 	 //--create array for output-------------------------------------------
 	 pOutArray[0] = mxCreateDoubleMatrix(1,1,mxREAL);
 	 
 	 //--create array data on the GPU-----------------------------------------------------
 	 cudaMalloc((void **)&data1f_gpu,sizeof(float)*m*n);
 	 cudaMalloc((void **)&data2f_gpu,sizeof(float)*m*n);
 	 

     data1 = mxGetPr(pInArray[0]);
 	 
 	 
 	 //------------------------------------------
 	 cudaMemcpy(data1f_gpu,data1, sizeof(float)*m*n, cudaMemcpyHostToDevice);
 	 //---configure GPU thread------------------------------------------------
 	 dim3 dimBlock(128);
 	 dim3 dimGrid(m*n/dimBlock.x);
 	 //if ((n*m) % 128 != 0) dimGrid.x+=1;
 	 //---call GPU function------------------------------------------------
 	 //data1f_gpu:input data; data2f_gpu: output data
	  norm_elements<<<dimGrid, dimBlock>>>(data1f_gpu, dtat2f_gpu, n*m);
 	 
	  //--allocate matlab double precision----------------------------
 	 data2f = mxMalloc(sizeof(float)*m*n);
 	 //---copy result back to host------------------------------------------------
 	 cudaMemcpy(data2f, data2f_gpu,sizeof(float)*n*m);
	  
     data2 = mxGetPr(pOutArray[0]);
 	 float tmp;
 	 tmp =  *data2f;
 	 *data2 = sqrt((double )tmp);
 	 
	  
     mxFree(data1f);
 	 mxFree(data2f);
 	 cudaFree(data1f_gpu);
 	 cudaFree(data2f_gpu);
}
