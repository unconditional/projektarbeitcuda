#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
//#include "mex.h"
/* Kernel to square elements of the array on the GPU */

/*
typedef struct{
        int width;
        int height;
        int stride;
        float * elements;
} Matrix;

*/
/*
N size of Vector  
*/

__global__ void norm_elements(float* in, float* out, unsigned int N)
{
   //block index
   int blockRow = blockIdx.x;
   // thread index
   int row = threadIdx.x;
   int aBegin = blockRow*VECTOR_BLOCK_SIZE;
   int aEnd = aBegin + VECTOR_BLOCK_SIZE - 1;
   int aStep = VECTOR_BLOCK_SIZE;
   //
   // comupted by the thread
   t_ve outValue = 0;
   
   for (int a = aBegin;a <= aEnd;a += aStep){
         // Declaration of the shared memory array As used to
        // store the sub-matrix of A
        __shared__ float As[VECTOR_BLOCK_SIZE];



        // Load the matrices from device memory
        // to shared memory; each thread loads
        // one element of each matrix
        AS(row) = in1[a + row];


        // Synchronize to make sure the matrices are loaded
        __syncthreads();    
        
        // Multiply the two matrices together;
        // each thread computes one element
        // of the block sub-matrix
        for (int k = 0; k < VECTOR_BLOCK_SIZE; ++k)
            outValue += AS(k) * AS(k);

        // Synchronize to make sure that the preceding
        // computation is done before loading two new
        // sub-matrices of A and B in the next iteration
        __syncthreads();  
   }
   
   out[0] = outValue;
   out[0] = sqrt(out[0]);


//	__syncthreads();

}

