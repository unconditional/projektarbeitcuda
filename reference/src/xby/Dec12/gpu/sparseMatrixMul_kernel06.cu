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
	__shared__ float Bs[VECTOR_BLOCK_X];//VECTOR_BLOCK_SIZE shuld equal blockDim 
	__shared__ float Cs[VECTOR_BLOCK_Y][VECTOR_BLOCK_X];//VECTOR_BLOCK_SIZE shuld equal blockDim 
	//define gridIndex, if gridDim < mA, gridIndex > 0; 
	int gridIndex = 0;
	int tx,bx;
	//int idx = gridIndex*gridDim.x + blockIdx.x*blockDim.x+threadIdx.x;
    t_ve *pMatrixElements, *pVectorElements, *pResultElements;
    unsigned int m, n;//, i, j;
    unsigned int *pRow, *pCol;
    tx = threadIdx.x;
	bx = blockIdx.x;
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
	int rowIdx;
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
	for(int a = aBegin; (a < aEnd)&&((gridIndex*aStep+bx*blockDim.y+ty)<aEnd); a += aStep, gridIndex++){
	//for(int a = aBegin; a < aEnd; a += aStep, gridIndex++){

	rowIdx = getSparseRowIdx(gridIndex,aStep,bx,blockDim.y,ty);
		if((tx==0)&&(rowIdx<aEnd)){
			//pResultElements[gridIndex*gridDim.x+blockIdx.x]=0;
			pResultElements[rowIdx]=0;
		}
		__syncthreads();
		
		//following is operations within one block 
		// initialize the dot product for each row in A and vector B
		//t_ve blocksum = 0;
		bBegin = 0;
		bEnd = n;
		t_ve blocksum[VECTOR_BLOCK_Y]; 
		blocksum[????]= 0;
		for(b=bBegin; b<bEnd;b+=bStep){
			if((b+tx)<bEnd)
			Bs[tx] = pVectorElements[b+tx];
			for(i=0;i<VECTOR_BLOCK_Y;i++){
				Cs[tx][i] = 0;			
				for(k=pRow[i];k<pRow[i+1];i++){
					if(b+tx == pCol[k]){
						Cs[tx][i] = Bs[tx]*pMatrixElements[k];
						break;
					}
				}
				
				
			}
			
		}//for b block
		
		
		
		
		
		
		bBegin = pRow[rowIdx];
		bEnd = pRow[rowIdx + 1];
		
		//for(int b = bBegin; (b < bEnd)&&((tx+b) < bEnd); b += bStep ) {
		for(int b = bBegin; b < bEnd; b += bStep ) {

		//initialise Cs 
			//As[threadIdx.x] = 0;		
			//if(ty==0)
			
			Cs[ty][tx] = 0;
			
			// compute scalar product
	
			if ((rowIdx<aEnd)&&((b+tx) < bEnd)) {
				Bs[tx] = pVectorElements[pCol[b + tx ]];
				__syncthreads();
				//Cs[ty][tx] = pMatrixElements[b + tx] * pVectorElements[pCol[b + tx ]];//???
				Cs[ty][tx] = pMatrixElements[b + tx] * Bs[tx];//???
			}
			__syncthreads();
				
			if(tx == 0){
				int kEnd = bEnd-b;
				if(kEnd > blockDim.x)kEnd = blockDim.x;
				//Because I add Cs[0...k], if blockSize and Matrix does not fit, Parts of Cs[k] are not initialized as 0.  		
				//for (int k = 0; k < kEnd; k++) blocksum += Cs[k];
				for (int k = 0; k < kEnd; k++) blocksum[ty] += Cs[ty][k];
				
			
			}
			
			/*
			
						
			int offset; 
			offset = VECTOR_BLOCK_SIZE/2;
			while (offset > 0) {
				if(tx < offset) {
					Cs[tx] += Cs[tx + offset];
				}
				offset >>= 1;
				__syncthreads();
			}
			__syncthreads();
			if(threadIdx.x == 0)
			blocksum += Cs[0]; //??? blocksum = Cs[0];
			
			*/
			/*
			int offset; 
			offset = blockDim.x/2;
			while (offset > 0) {
				if(tx < offset) {
					Cs[ty][tx] += Cs[ty][tx + offset];
				}
				offset >>= 1;
				__syncthreads();
			}
			blocksum[ty] += Cs[ty][0];
			__syncthreads();
			*/
		}//for b
		__syncthreads();

		if(tx == 0) pResultElements[rowIdx] = blocksum[ty];//?????????????
		__syncthreads();	
    
	}//for {int a = aBegin;....
}