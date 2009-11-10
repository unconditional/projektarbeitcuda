
#include "mex.h"
#include "matrix.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "cuda.h"

#include "mex_sum_kernel.cu"


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{

  /* Variable declaration */
  double *ex;
  double *hx;
  double *res;


  /* Local variables */
  int n; 

  
  double *ex_gpu;
  double *hx_gpu;
 
  /* Check for proper number of input and output arguments */    
  if (nrhs != 2) {
	mexErrMsgTxt("2 input arguments required.");
  }
  if (nlhs > 1) {
	mexErrMsgTxt("Too many output arguments.");
  }

  /* Check if Matrix is not Sparse */
  if ((mxGetClassID(prhs[0]) != mxDOUBLE_CLASS) ||
	  (mxGetClassID(prhs[1]) != mxDOUBLE_CLASS)   ) {
	mexErrMsgTxt("Cannot handle sparse arrays in this mex-function.");
  }
  
/*=================================================================
 *  INPUT Arguments
 *=================================================================*/
  

  n = mxGetM(prhs[0]);

  ex = mxGetPr(prhs[0]);

  if (mxGetM(prhs[1]) != n) {
	mexErrMsgTxt("Wrong length of h.");
  }
  hx = mxGetPr(prhs[1]);


/*=================================================================
 *  OUTPUT Arguments
 *=================================================================*/

  plhs[0] = mxCreateDoubleMatrix(n,1,mxREAL);
  res = mxGetPr(plhs[0]);
  
/*=================================================================
 *  CUDA Malloc
 *=================================================================*/
    
    cudaMalloc( (void **) &ex_gpu, sizeof(double)*n);
    cudaMalloc( (void **) &hx_gpu, sizeof(double)*n);


/*=================================================================
 *  MEMORYCOPY FROM HOST TO DEVICE
 *=================================================================*/
  
  cudaMemcpy( ex_gpu, ex, sizeof(double)*n, cudaMemcpyHostToDevice);
  cudaMemcpy( hx_gpu, hx, sizeof(double)*n, cudaMemcpyHostToDevice);


/*=================================================================
 *  START
 *=================================================================*/
  
  dim3 dimBlock(24);
  dim3 dimGrid(n/dimBlock.x);

  
    
    summup<<< dimGrid, dimBlock>>>(hx_gpu, ex_gpu, n);


    cudaThreadSynchronize();



/*=================================================================
 *  FREE MEMORY FROM DEVICE
 *=================================================================*/

    cudaMemcpy(res, hx_gpu, sizeof(double)*n, cudaMemcpyDeviceToHost);
  
    cudaFree(ex_gpu);
    cudaFree(hx_gpu);

}
/*=================================================================*/
