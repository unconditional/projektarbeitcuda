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
	//int idx = gridIndex*gridDim.x + blockIdx.x*blockDim.x+threadIdx.x;
	int aBegin = 0;
	int bBegin = 0;
	int aStep = gridDim.x;
	int bStep = VECTOR_BLOCK_SIZE; // blockDim.x
	int aEnd = mA;
	int bEnd = nB;

		//initialise Cs 
		Cs[threadIdx.x] = 0;
		__syncthreads();
		//initialize output vector for each block
	if(threadIdx.x==0){
		C[gridIndex*gridDim.x+blockIdx.x]=0;
	}
		__syncthreads();
	// if nB > gridDim???????
	//idx < (gridIndex*gridDim.x+mA%VECTOR_BLOCK_SIZE)*()
	for(int a = aBegin; (a < aEnd)&&((gridIndex*gridDim.x+blockIdx.x)<aEnd); a += aStep, gridIndex++){
		//initialize output vector for each block
		if(threadIdx.x==0){
			C[gridIndex*gridDim.x+blockIdx.x]=0;
		}
		__syncthreads();
		
		//following is operations within one block 
		// initialize the dot product for each row in A and vector B
		t_ve blocksum = 0;
		//if nB> blockDim, split repeat the
		for(int b = bBegin; (b < bEnd)&&((threadIdx.x+b) < bEnd); b += bStep ) {
			//initialise Cs 
			Cs[threadIdx.x] = 0;
			__syncthreads();
			// compute scalar product
			if (( (gridIndex*gridDim.x+blockIdx.x)<aEnd)&&((b+threadIdx.x) < bEnd)) {
				//Cs[threadIdx.x] = A[a + blockIdx.x ][b + threadIdx.x] * B[b + threadIdx.x ];
				Cs[threadIdx.x] = A[(a + blockIdx.x)* nB+b + threadIdx.x] * B[b + threadIdx.x ];
			}
			__syncthreads();
				
			if(threadIdx.x == 0){
				//30.Nov.2009 fixeded for Cs summe
				int kEnd = bEnd-b;
				if(kEnd > VECTOR_BLOCK_SIZE)kEnd = VECTOR_BLOCK_SIZE;
				//Because I add Cs[0...k], if blockSize and Matrix does not fit, Parts of Cs[k] are not initialized as 0.  		
				for (int k = 0; k < kEnd; k++) blocksum += Cs[k];
			
			}
			__syncthreads();
			
			//Cs[threadIdx.x] = 0;
			//__syncthreads();	
		}//for b
		__syncthreads();

		if(threadIdx.x == 0) C[gridIndex*gridDim.x+blockIdx.x] = blocksum;
		__syncthreads();
		// summe all block, need test for mA bigger than one Grid
		//idx = gridIndex*gridDim.x + blockIdx.x*blockDim.x+threadIdx.x;
	
	}

}