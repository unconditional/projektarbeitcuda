#include "cuda.h"
#include "mex.h"
/* Kernel to square elements of the array on the GPU */
__global__ void square_elements(float* in, float* out, int N)
{
           
      int idx = blockIdx.x*blockDim.x+threadIdx.x;
      //if ( idx < N) out[idx] = in[idx]*in[idx];
      //if ( idx < N) out[0] = out[0]+in[idx]*in[idx];
      if ( idx < N) *out = *out + in[idx]*in[idx];
      __syncthreads();
}
/* Gateway function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
     int i, j, m, n;
     //pointers of input and output matrix
     double *data1, *data2;
     float *data1f, *data2f;
     
     //pointers of the date for gpu. data1f_gpu: input data, data2f_gpu out put data
     float *data1f_gpu, *data2f_gpu;
     mxClassID category;
     //if (nrhs != nlhs)mexErrMsgTxt("The number of input and output arguments must be the same.");


     for (i = 0; i < nrhs; i++)
     {
     /* Find the dimensions of the data */
        m = mxGetM(prhs[i]);
        n = mxGetN(prhs[i]);

        /* Create an mxArray for the output data */
        //plhs[i] = mxCreateDoubleMatrix(m, n, mxREAL);
        plhs[i] = mxCreateDoubleMatrix(1, 1, mxREAL);


        /* Create an input and output data array on the GPU*/
        cudaMalloc( (void **) &data1f_gpu,sizeof(float)*m*n);
        //cudaMalloc( (void **) &data2f_gpu,sizeof(float)*m*n);
        cudaMalloc( (void **) &data2f_gpu,sizeof(float));

        /* Retrieve the input data */
        data1 = mxGetPr(prhs[i]);
        /* Check if the input array is single or double precision */
        category = mxGetClassID(prhs[i]);
        if( category == mxSINGLE_CLASS)
        {
        /* The input array is single precision, it can be sent directly to the card */
        cudaMemcpy( data1f_gpu, data1, sizeof(float)*m*n, cudaMemcpyHostToDevice);
        }
        if( category == mxDOUBLE_CLASS)
        {
         /* The input array is in double precision, it needs to be converted t
            floats before being sent to the card */
            data1f = (float *) mxMalloc(sizeof(float)*m*n);
            for (j = 0; j < m*n; j++)
            {
                data1f[j] = (float) data1[j];
            }
            printf("before copyHost to device \n");
            cudaMemcpy( data1f_gpu, data1f, sizeof(float)*n*m, cudaMemcpyHostToDevice);
         }//if( category == mxDOUBLE_CLASS)

         //orginal output
         //data2f = (float *) mxMalloc(sizeof(float)*m*n);
         data2f = (float *) mxMalloc(sizeof(float));

         /* Compute execution configuration using 128 threads per block */
         dim3 dimBlock(128);
         dim3 dimGrid((m*n)/dimBlock.x);
         if ( (n*m) % 128 !=0 ) dimGrid.x+=1;
    
         printf("before calling GPU \n");
         /* Call function on GPU */
         square_elements<<<dimGrid,dimBlock>>>(data1f_gpu, data2f_gpu, n*m);

         printf("before copy result back \n");
         /* Copy result back to host */
         //cudaMemcpy( data2f, data2f_gpu, sizeof(float)*n*m, cudaMemcpyDeviceToHost);
         cudaMemcpy( data2f, data2f_gpu, sizeof(float), cudaMemcpyDeviceToHost);
         /* Create a pointer to the output data */
         data2 = mxGetPr(plhs[i]);
         /* Convert from single to double before returning */
         /*
         for (j = 0; j < m*n; j++)
         {
             data2[j] = (double) data2f[j];
         }
         */
         printf("before return result to matlab \n");
         data2[0] = 0;
         data2[0] = (double) data2f[0];

         /* Clean-up memory on device and host */
         mxFree(data1f);
         mxFree(data2f);
         cudaFree(data1f_gpu);
         cudaFree(data2f_gpu);
     }// for i

}
