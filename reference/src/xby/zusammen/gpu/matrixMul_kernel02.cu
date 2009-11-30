#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
#include "project_comm.h"

/* Kernel to square elements of the array on the GPU */
/*
	Matrix A is mA x nB  , Vector B is nB
	Vector C output vector in size of mA
	C=A*B
description:
	each row of A occuppy one block. if gridDim is smaller than the row number of A  
*/

__global__ void matrixMul( t_ve* C, t_ve* A, t_ve* B, int mA, int nB)
{
	

	//define a Result Vector for each block
	__shared__ float Cs[VECTOR_BLOCK_SIZE];//VECTOR_BLOCK_SIZE shuld equal blockDim 512
	
	//define gridIndex, if gridDim < mA, gridIndex > 0; 
	int gridIndex = 0;
	// get a thread indentifier
	int idx = blockIdx.x*blockDim.x+threadIdx.x;//int idx = gridIndex*gridDim.x + blockIdx.x*blockDim.x+threadIdx.x;
	int aBegin = 0;
	int bBegin = 0;
	int aStep = gridDim.x;
	int bStep = VECTOR_BLOCK_SIZE; // blockDim.x
	int aEnd = mA;

		//initialize output vector for each block
		if(threadIdx.x==0){
			C[gridIndex*gridDim.x+blockIdx.x]=0;
		}
		__syncthreads();
	
	// if nB > gridDim???????
	for(int a = aBegin; (a < aEnd)&&(idx < mA*nB); a += aStep, gridIndex++){
		
		//following is operations within one block 
		// initialize the dot product for each row in A and vector B
		t_ve blocksum = 0;
		//if nB> blockDim, split repeat the
		for(int b = bBegin; (b < nB)&&((threadIdx.x+b) < nB); b += bStep ) {
			//initialise Cs 
			Cs[threadIdx.x] = 0;
			__syncthreads();
			// compute scalar product
			if (( idx < mA*nB )&&(threadIdx.x < nB)) {
				//Cs[threadIdx.x] = A[a + blockIdx.x ][b + threadIdx.x] * B[b + threadIdx.x ];
				Cs[threadIdx.x] = A[(a + blockIdx.x)* nB+b + threadIdx.x] * B[b + threadIdx.x ];
			}
			__syncthreads();
				
			if(threadIdx.x==0){
				for (int k = 1; k < VECTOR_BLOCK_SIZE; k++) Cs[0] += Cs[k];
				blocksum += Cs[0];
			}
			__syncthreads();
			
			Cs[threadIdx.x] = 0;
			__syncthreads();
			
		}
		__syncthreads();

		if(threadIdx.x == 0) C[gridIndex*gridDim.x+blockIdx.x] = blocksum;
		__syncthreads();
		// summe all block
	
	}


}