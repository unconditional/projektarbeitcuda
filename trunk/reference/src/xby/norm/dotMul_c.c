#include "mex.h"
/* Kernel to square elements of the array on the GPU */
void dot_Mul(double* in1,double* in2, double* out, int N)
{
           
      int idx ;
      for (idx = 0; idx < N; idx++)
      {
          *out = *out + in1[idx]*in2[idx];
      }
      
     
}
/* Gateway function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
     int m1, n1, m2, n2;
     //pointers of input and output matrix
     double *data1, *data2, *data3;
    // float *data1f, *data2f, *data3f;
     
     //pointers of the date for gpu. data1f_gpu: input data, data2f_gpu out put data
     //float *data1f_gpu, *data2f_gpu, *data3f_gpu;
    // mxClassID category;
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


        /*
        // Create an input and output data array on the GPU
        cudaMalloc( (void **) &data1f_gpu,sizeof(float)*m1*n1);
        cudaMalloc( (void **) &data2f_gpu,sizeof(float)*m1*n1);
        //cudaMalloc( (void **) &data2f_gpu,sizeof(float)*m*n);
        cudaMalloc( (void **) &data3f_gpu,sizeof(float));
        */
        /* Retrieve the input data */
        data1 = mxGetPr(prhs[0]);
        data2 = mxGetPr(prhs[1]);
        /* Create a pointer to the output data */
        data3 = mxGetPr(plhs[0]);
         
         /* Call function on GPU */
         dot_Mul(data1, data2, data3, n1*m1);

         printf("before copy result back \n");
         /* Copy result back to host */
         //cudaMemcpy( data2f, data2f_gpu, sizeof(float)*n*m, cudaMemcpyDeviceToHost);
         

         /* Convert from single to double before returning */
         /*
         for (j = 0; j < m*n; j++)
         {
             data2[j] = (double) data2f[j];
         }
         */
         printf("before return result to matlab \n");
         printf("data2 = %lf,  ",data3[0]);


//     }// for i

}
