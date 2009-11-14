#include "cuda.h"
#include "mex.h"
/* Kernel to square elements of the array on the GPU */
__global__ void dot_Mul_kernel(float* in1,float* in2, float* out, int N)
{
           
      int idx = blockIdx.x*blockDim.x+threadIdx.x;
      //if ( idx < N) out[idx] = in[idx]*in[idx];
      //if ( idx < N) out[0] = out[0]+in[idx]*in[idx];
      if ( idx < N) *out = *out + in1[idx]*in2[idx];
      __syncthreads();
}
/* Gateway function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
     int i, j, m1, n1, m2, n2;
     //pointers of input and output matrix
     double *data1, *data2, *data3;
     float *data1f, *data2f, *data3f;
     
     //pointers of the date for gpu. data1f_gpu: input data, data2f_gpu out put data
     float *data1f_gpu, *data2f_gpu, *data3f_gpu;
     mxClassID category;
     //if (nrhs != nlhs)mexErrMsgTxt("The number of input and output arguments must be the same.");


//     for (i = 0; i < nrhs; i++)
//     {
     /* Find the dimensions of the data */
        m1 = mxGetM(prhs[0]);
        n1 = mxGetN(prhs[0]);
        m2 = mxGetM(prhs[1]);
        n2 = mxGetN(prhs[1]);
        if ((n1*m1) != (n2*m2))mexErrMsgTxt("The input1 and input2 arguments must be in the same dimension.");
        /* Create an mxArray for the output data */
        //plhs[i] = mxCreateDoubleMatrix(m, n, mxREAL);
        plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);


        /* Create an input and output data array on the GPU*/
        cudaMalloc( (void **) &data1f_gpu,sizeof(float)*m1*n1);
        cudaMalloc( (void **) &data2f_gpu,sizeof(float)*m1*n1);
        //cudaMalloc( (void **) &data2f_gpu,sizeof(float)*m*n);
        cudaMalloc( (void **) &data3f_gpu,sizeof(float));

        /* Retrieve the input data */
        data1 = mxGetPr(prhs[0]);
        data2 = mxGetPr(prhs[1]);
        /* Check if the input array is single or double precision */
        category = mxGetClassID(prhs[i]);
        /*
        if( category == mxSINGLE_CLASS)
        {
        // The input array is single precision, it can be sent directly to the card 
        cudaMemcpy( data1f_gpu, data1, sizeof(float)*m*n, cudaMemcpyHostToDevice);
        }
        */
        if( category == mxDOUBLE_CLASS)
        {
         /* The input array is in double precision, it needs to be converted t
            floats before being sent to the card */
            data1f = (float *) mxMalloc(sizeof(float)*m1*n1);
            data2f = (float *) mxMalloc(sizeof(float)*m1*n1);
            for (j = 0; j < m*n; j++)
            {
                data1f[j] = (float) data1[j];
                data2f[j] = (float) data2[j];
            }
            printf("before copyHost to device \n");
            cudaMemcpy( data1f_gpu, data1f, sizeof(float)*n1*m1, cudaMemcpyHostToDevice);
            cudaMemcpy( data2f_gpu, data2f, sizeof(float)*n1*m1, cudaMemcpyHostToDevice);
         }//if( category == mxDOUBLE_CLASS)
         
         //orginal output
         //data2f = (float *) mxMalloc(sizeof(float)*m*n);
         data3f = (float *) mxMalloc(sizeof(float));

         /* Compute execution configuration using 128 threads per block */
         dim3 dimBlock(128);
         dim3 dimGrid((m*n)/dimBlock.x);
         if ( (n*m) % 128 !=0 ) dimGrid.x+=1;
    
         printf("before calling GPU \n");
         /* Call function on GPU */
         dot_Mul_kernel<<<dimGrid,dimBlock>>>(data1f_gpu, data2f_gpu, data3f_gpu, n1*m1);

         printf("before copy result back \n");
         /* Copy result back to host */
         //cudaMemcpy( data2f, data2f_gpu, sizeof(float)*n*m, cudaMemcpyDeviceToHost);
         cudaMemcpy( data3f, data3f_gpu, sizeof(float), cudaMemcpyDeviceToHost);
         /* Create a pointer to the output data */
         data3 = mxGetPr(plhs[0]);
         /* Convert from single to double before returning */
         /*
         for (j = 0; j < m*n; j++)
         {
             data2[j] = (double) data2f[j];
         }
         */
         printf("before return result to matlab \n");
         printf("data2 = %lf,  ",data3[0]);
         printf("data2f = %f \n", data3f[0]);
         data3[0] = 0;
         data3[0] = (double) data3f[0];

         /* Clean-up memory on device and host */
         mxFree(data1f);
         mxFree(data2f);
         mxFree(data3f);
         cudaFree(data1f_gpu);
         cudaFree(data2f_gpu);
         cudaFree(data3f_gpu);
//     }// for i

}
