#include <stdio.h>
#include "projektcuda.h"


/* Kernel to square elements of the array on the GPU */
/*
	input Matrix pSparseMatrix  ,input Vector pVector
	Vector pResultVector output vector
	C=A*B
description:
	each row of A occuppy one block. if gridDim is smaller than the row number of A
Release:
	enhancedSparseMatrixMul_kernel.cu
*/
__global__ void enhancedSparseMatrixMul(t_FullMatrix pResultVector,t_SparseMatrix pSparseMatrix, t_FullMatrix pVector,t_ve n)
{
	__shared__ t_ve Cs[VECTOR_BLOCK_SIZE];//VECTOR_BLOCK_SIZE shuld equal blockDim 512
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
	int aBegin = 0;
	int aEnd = pSparseMatrix.m;
	int bBegin = 0;
	//int aStep = gridDim.x;
	int bStep = VECTOR_BLOCK_SIZE; // blockDim.x
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

		if(threadIdx.x==0){
			pResultElements[blockIdx.x]=0;
		//C[gridIndex*gridDim.x+blockIdx.x]=0;
		}
		//following is operations within one block
		// initialize the dot product for each row in A and vector B
		t_ve blocksum = 0;
		//if nB> blockDim, split repeat the
		bBegin = pRow[blockIdx.x];
		bEnd = pRow[blockIdx.x + 1];
		for(int b = bBegin; (b < bEnd)&&((threadIdx.x+b) < bEnd); b += bStep ) {

			Cs[threadIdx.x] = 0;
			__syncthreads();

			if (( (gridIndex*gridDim.x+blockIdx.x)<aEnd)&&((b+threadIdx.x) < bEnd)) {

				Cs[threadIdx.x] = n*pMatrixElements[b + threadIdx.x] * pVectorElements[pCol[b + threadIdx.x ]];
			}
			__syncthreads();

			if(threadIdx.x == 0){
				int kEnd = bEnd-b;
				if(kEnd > VECTOR_BLOCK_SIZE)kEnd = VECTOR_BLOCK_SIZE;
				//Because I add Cs[0...k], if blockSize and Matrix does not fit, Parts of Cs[k] are not initialized as 0.
				for (int k = 0; k < kEnd; k++) blocksum += Cs[k];
				//blocksum = 2;

			}
			__syncthreads();

			//Cs[threadIdx.x] = 0;
			//__syncthreads();
		}//for b
		__syncthreads();

		if(threadIdx.x == 0) pResultElements[blockIdx.x] = blocksum;//?????????????
		__syncthreads();


}