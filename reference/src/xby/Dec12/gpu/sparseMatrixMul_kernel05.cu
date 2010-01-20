#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"
#include "project_comm.h"

/* Kernel to square elements of the array on the GPU */
/*	sparseMatrixMul_kernel05.cu
	input Matrix pSparseMatrix  ,input Vector pVector 
	Vector pResultVector output vector 
	C=A*B
description:
	
	each row of A occuppy one block. if gridDim is smaller than the row number of A  
	
	enchance of sparseMatrixMul_kernel03.cu for supprting Vector size biger than Maximu block size
	
*/

__device__ unsigned int getSparseRowIdx(unsigned int gridIdx,unsigned int gridStep,unsigned int blockIdx,unsigned int blockStepY,unsigned int threadIdxY)
{
	return gridIdx*gridStep+blockIdx*blockStepY+threadIdxY;
}
__global__ void sparseMatrixMul(t_FullMatrix pResultVector,t_SparseMatrix pSparseMatrix, t_FullMatrix pVector)
{
	//__shared__ float As[VECTOR_BLOCK_SIZE];//VECTOR_BLOCK_SIZE shuld equal blockDim 
	__shared__ float Bs[blockDim.x];//VECTOR_BLOCK_SIZE shuld equal blockDim 
	__shared__ float Cs[blockDim.y][blockDim.x];//VECTOR_BLOCK_SIZE shuld equal blockDim 
	//define gridIndex, if gridDim < mA, gridIndex > 0; 
	int gridIndex = 0;
	//int idx = gridIndex*gridDim.x + blockIdx.x*blockDim.x+threadIdx.x;
    t_ve *pMatrixElements, *pVectorElements, *pResultElements;
    unsigned int m, n;//, i, j;
    unsigned int *pRow, *pCol;
    //unsigned int colbegin, colend;
    pMatrixElements = pSparseMatrix.pNZElement;
    pVectorElements = pVector.pElement;
    pResultElements = pResultVector.pElement;
    m = pSparseMatrix.m;
    n = pSparseMatrix.n;
	//aBegin,aEnd,aStep are defined for 
	int aBegin = 0;
	int aEnd = pSparseMatrix.m;
	//int aStep = gridDim.x;
	int aStep = gridDim.x*blockDim.y;//gridDim.x
	
	int bBegin = 0;

	int bStep = blockDim.x;
	//int aEnd = mA;
	int bEnd;
    //==check size of Arguments========================================================
    if(m != pResultVector.m*(pResultVector.n)){
        //printf("Result Vector does not match the Matrix\n");
        return;
    }   
    if(n != pVector.m*(pVector.n)){
        //printf("input Vector does not match the Matrix\n");
        return;
    }
	//pRow and pCol may should in share memory or texture
    pRow = pSparseMatrix.pRow;
    pCol = pSparseMatrix.pCol;
    //cal
	//for(int a = aBegin; (a < aEnd)&&((gridIndex*gridDim.x+blockIdx.x)<aEnd); a += aStep, gridIndex++){
	for(int a = aBegin; (a < aEnd)&&((gridIndex*aStep+blockIdx.x)<aEnd); a += aStep, gridIndex++){
		rowIdx = getSparseRowIdx(gridIndex,aStep,blockIdx.x,blockDim.y,threadIdx.y);
		if(threadIdx.x==0){
			//pResultElements[gridIndex*gridDim.x+blockIdx.x]=0;
			pResultElements[rowIdx]=0;
		}
		__syncthreads();
		
		//following is operations within one block 
		// initialize the dot product for each row in A and vector B
		//t_ve blocksum = 0;
		t_ve blocksum[] 
		blocksum[threadIdx.y]= 0;
		//if nB> blockDim, split repeat the
		bBegin = pRow[gridIndex*aStep+blockIdx.x];
		bEnd = pRow[gridIndex*aStep+blockIdx.x + 1];
		for(int b = bBegin; (b < bEnd)&&((threadIdx.x+b) < bEnd); b += bStep ) {
			//initialise Cs 
			//As[threadIdx.x] = 0;
			//Bs[threadIdx.x] = 0;// consider text memory
			Cs[threadIdx.x] = 0;
			__syncthreads();
			// compute scalar product
	
			if (( (gridIndex*gridDim.x+blockIdx.x)<aEnd)&&((b+threadIdx.x) < bEnd)) {
				
				Cs[threadIdx.x] = pMatrixElements[b + threadIdx.x] * pVectorElements[pCol[b + threadIdx.x ]];
			}
			__syncthreads();
				
			if(threadIdx.x == 0){
				int kEnd = bEnd-b;
				if(kEnd > blockDim.x)kEnd = blockDim.x;
				//Because I add Cs[0...k], if blockSize and Matrix does not fit, Parts of Cs[k] are not initialized as 0.  		
				//for (int k = 0; k < kEnd; k++) blocksum += Cs[k];
				for (int k = 0; k < kEnd; k++) blocksum[threadIdx.y] += Cs[threadIdx.y][k];
				
			
			}
			__syncthreads();
			
			//Cs[threadIdx.x] = 0;
			//__syncthreads();	
		}//for b
		__syncthreads();

		if(threadIdx.x == 0) pResultElements[rowIdx] = blocksum[threadIdx.y];//?????????????
		__syncthreads();	
    
	}//for {int a = aBegin;....
}