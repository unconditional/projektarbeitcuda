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
	Release: matrixMul_kernel05.cu
	create 28.Jan.2010
	using share memory to stor B vector
	each row of A occuppy one block. if gridDim is smaller than the row number of A  
*/
__device__ unsigned int getRowBaseIdx(unsigned int gridIdx,unsigned int gridStep,unsigned int blockIdx,unsigned int stepY)
{
	return gridIdx*gridStep+blockIdx*stepY;
}
__global__ void matrixMul( t_ve* C, t_ve* A, t_ve* B, int mA, int nB)
{
	
	//define a Result Vector for each block
	//__shared__ float Cs[VECTOR_BLOCK_SIZE];//VECTOR_BLOCK_SIZE shuld equal blockDim 512
	__shared__ float Cs[VECTOR_BLOCK_Y][VECTOR_BLOCK_SIZE];//VECTOR_BLOCK_SIZE shuld equal blockDim 512
	__shared__ float Bs[VECTOR_BLOCK_SIZE];
	//define gridIndex, if gridDim < mA, gridIndex > 0; 
	int gridIndex = 0;
	// get a thread indentifier
	//int idx = gridIndex*gridDim.x + blockIdx.x*blockDim.x+threadIdx.x;
	int aBegin = 0;
	int bBegin = 0;
	int aStep = gridDim.x*VECTOR_BLOCK_Y;//gridDim.x
	int bStep = VECTOR_BLOCK_SIZE; // blockDim.x
	int aEnd = mA;
	int bEnd = nB;
	int tx,bx,y;
	tx = threadIdx.x;
	bx = blockIdx.x;

    //initialise Cs 
	//for(y = 0; y < VECTOR_BLOCK_Y; y++) Cs[y][tx] = 0;
	//__syncthreads();
	
	//initialize output vector 
	//if(tx==0){
	//	for(y = 0; y < VECTOR_BLOCK_Y; y++)
	//			C[gridIndex*aStep+blockIdx.x*VECTOR_BLOCK_Y+y] = 0;
	//}
	//__syncthreads();
	// if nB > gridDim???????
	rowIdx = getRowBaseIdx(gridIndex,aStep,bx,VECTOR_BLOCK_Y);
	//idx < (gridIndex*gridDim.x+mA%VECTOR_BLOCK_SIZE)*()
	for(int a = aBegin; (a < aEnd)&&((gridIndex*gridDim.x+blockIdx.x)<aEnd); a += aStep, gridIndex++){
		//initialize output vector 
		if(tx==0){
			for(y = 0; y < VECTOR_BLOCK_Y; y++)
				C[rowIdx+y] = 0;
		}
		__syncthreads();
		
		//following is operations within one block 
		// initialize the dot product for each row in A and vector B
		t_ve blocksum = 0;
		//if nB> blockDim, split repeat the
		//for(int b = bBegin; (b < bEnd)&&((threadIdx.x+b) < bEnd); b += bStep ) {
		for(int b = bBegin; b < bEnd; b += bStep ) {
				
		//initialise Cs 
			for(y = 0; y < VECTOR_BLOCK_Y; y++) Cs[y][tx] = 0;
			__syncthreads();
			// compute scalar product
			Bs[tx] = B[b+tx];
			for(y = 0; y < VECTOR_BLOCK_Y; y++)
				if (( (rowIdx +y)<aEnd)&&((b+tx) < bEnd)) {
				//Cs[threadIdx.x] = A[a + blockIdx.x ][b + threadIdx.x] * B[b + threadIdx.x ];
					Cs[threadIdx.x] = A[(rowIdx + y)* nB+ b + tx] * Bs[tx];
				}
			__syncthreads();
			
			if(tx == 0){
				//30.Nov.2009 fixeded for Cs summe
				int kEnd = bEnd-b;
				if(kEnd > VECTOR_BLOCK_SIZE)kEnd = VECTOR_BLOCK_SIZE;
				//Because I add Cs[0...k], if blockSize and Matrix does not fit, Parts of Cs[k] are not initialized as 0.  
				for(y = 0; y < VECTOR_BLOCK_Y; y++){
					for (int k = 1; k < kEnd; k++) Cs[y][0] += Cs[y][k];
					blocksum[y] += Cs[y][0];
				}
			}
			__syncthreads();
			/*
			int offset; 
			offset = VECTOR_BLOCK_SIZE/2;
			for(y = 0; y < VECTOR_BLOCK_Y; y++)
			while (offset > 0) {
				if(tx < offset) {
					Cs[y][tx] += Cs[y][tx + offset];
				}
				offset >>= 1;
				__syncthreads();
			}
			__syncthreads();
			if(threadIdx.x == 0)
			blocksum[y] += Cs[y][0]; //??? blocksum = Cs[0];
			
		}//for b
		__syncthreads();
		*/
		if(tx == 0) 
			for(y = 0; y < VECTOR_BLOCK_Y; y++)C[rowIdx+y] = blocksum[y];
		__syncthreads();	
	}// for a

}