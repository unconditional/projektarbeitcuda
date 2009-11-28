#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
#include "project_comm.h"

//#include "mex.h"
/* Kernel to square elements of the array on the GPU */

/*
typedef struct{
        int width;
        int height;
        int stride;
        float * elements;
} Matrix;
///
__device__ float GetVectorElement(const Matrix A, int row, int offset){
          return A.elements[row * VECTOR_BLOCK_SIZE + offset];           
}

///??????????????????
__device__ void setVectorElement(Matrix A, int row, int offset, float value){
           A.elements[row * VECTOR_BLOCK_SIZE + offset] = value;           
}

__device__ Matrix GetSubVector(Matrix A, int row){
           Matrix Asub;
           Asub.width = 1;     
           Asub.height = VECTOR_BLOCK_SIZE;
           Asub.stride = 1;
           Asub.elements = & A.elements[row * VECTOR_BLOCK_SIZE]      
}
*/
/*
N size of Vector  
*/

__global__ void device_dotMul(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N)
{
	int idx = blockIdx.x*blockDim.x+threadIdx.x;
	if(idx > N) return;
	if(idx == 0)out[blockIdx.x] = 0;
	__syncthreads();
	
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
   //for (int a = aBegin;(a <= aEnd)&&(a <= N);a += aStep){
   for (int a = aBegin;(a <= aEnd);a += aStep){
         // Declaration of the shared memory array As used to
        // store the sub-matrix of A
        __shared__ float As[VECTOR_BLOCK_SIZE];

        // Declaration of the shared memory array Bs used to
        // store the sub-matrix of B
        __shared__ float Bs[VECTOR_BLOCK_SIZE];
		
		__shared__ float Cs[VECTOR_BLOCK_SIZE];

        // Load the matrices from device memory
        // to shared memory; each thread loads
        // one element of each matrix
        AS(row) = in1[a + row];
        BS(row) = in2[a + row];

        // Synchronize to make sure the matrices are loaded
        __syncthreads();    
		
		Cs[row] = AS(row) * BS(row);
        
		/*
        // Multiply the two matrices together;
        // each thread computes one element
        // of the block sub-matrix
		for (int k = 0; (k < VECTOR_BLOCK_SIZE)&&(k < N); ++k)
        //for (int k = 0; (k < VECTOR_BLOCK_SIZE); ++k)
            outValue += AS(k) * BS(k);
		*/
        // Synchronize to make sure that the preceding
        // computation is done before loading two new
        // sub-matrices of A and B in the next iteration
        __syncthreads();  
		
		if (row == 0) {
			
			for (int k = 0; (k < VECTOR_BLOCK_SIZE)&&(idx < N); k++)
			out[blockIdx.x] += Cs[k];
			//out[0] += 1;
			//outValue += 1;
		}
		__syncthreads();
   }
   //__syncthreads();
   
   if(idx==0){
		for(int k = 1; k <= gridDim.x; k++)out[0] += out[k];
   }
   
   //out[0] = outValue;


//	__syncthreads();

}

