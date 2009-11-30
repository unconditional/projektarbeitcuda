#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
#include "project_comm.h"

//#include "mex.h"
/* Kernel to square elements of the array on the GPU */

/*
  create in 28.11.2009
 It should be runging only in more than one block.
 separate vectors in parts in length of VECTOR_BLOCK_SIZE

*/

/*

N size of Vector  
*/

__global__ void device_dotMul(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N)
{
	int idx = blockIdx.x*blockDim.x+threadIdx.x;
	if(idx > N) return;
   //block index
   int blockRow = blockIdx.x;
   // thread index
   int row = threadIdx.x;
   int aBegin = blockRow*VECTOR_BLOCK_SIZE;   
   //int aEnd = aBegin + VECTOR_BLOCK_SIZE - 1;
   //working only in one block
   //int aBegin = 0;
   int aEnd = N;
   
   int aStep = VECTOR_BLOCK_SIZE;

   // comupted by the thread
   t_ve outValue = 0;
  
         // Declaration of the shared memory array As used to
        // store the sub-matrix of A
        __shared__ float As[VECTOR_BLOCK_SIZE];

        // Declaration of the shared memory array Bs used to
        // store the sub-matrix of B
        __shared__ float Bs[VECTOR_BLOCK_SIZE];
		
		__shared__ float Cs[VECTOR_BLOCK_SIZE];
		Cs[row] = 0;

        // Load the matrices from device memory
        // to shared memory; each thread loads
        // one element of each matrix
        AS(row) = in1[aBegin + row];
        BS(row) = in2[aBegin + row];
        // Synchronize to make sure the matrices are loaded
        __syncthreads();    	
		
		Cs[row] = AS(row) * BS(row);   
		//Cs[row] = in1[aBegin + row] *in2[aBegin + row];   
		
        // Synchronize to make sure that the preceding
        // computation is done before loading two new
        // sub-matrices of A and B in the next iteration
        
		__syncthreads();  
		if(threadIdx.x == 0)out[blockIdx.x] = 0;
		__syncthreads();
		
		// computing summe in one thread for one Loop 
		if (threadIdx.x == 0) {			
			for (int k = 1; (k < VECTOR_BLOCK_SIZE)&&(idx < N); k++){
                 Cs[0]+= Cs[k];
				 //out[k]= Cs[k];
            }   
			out[blockIdx.x] = Cs[0];
		}
		__syncthreads();
   //__syncthreads();   
   
   /*
   if(idx==0){
		for(int k = 1; k <= gridDim.x; k++)out[0] += out[k];
   }
   */
}

