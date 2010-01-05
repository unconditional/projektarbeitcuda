//host_SparseMV
#include "test_comm.h"
void host_sparseMatrixMul(t_FullMatrix * pResultVector,t_SparseMatrix *pSparseMatrix, t_FullMatrix * pVector){

	t_SparseMatrix *data_in1_gpu;//input sparse Matrix
	t_FullMatrix *data_in2_gpu;//input vector
	t_FullMatrix *data_out_gpu;//output vector
	
	size_t size_NZElement,size_Row,size_Col;
	
	int sizeBlock;
	sizeBlock = VECTOR_BLOCK_SIZE;
	
	size_NZElement = sizeof(t_ve)*pSparseMatrix->nzmax;
	size_Row + sizeof(int)*pSparseMatrix->m;
	size_Col = sizeof(int)*(pSparseMatrix->n+1);
	// Create an input and output data array on the GPU
	//malloc memory for Input Sparse-Matrix
	cudaMalloc( (void **) &data_in1_gpu,sizeof(t_SparseMatrix)*1);
	//cudaMalloc( (void **) &(data_in1_gpu->pNZElement),sizeof(t_ve)*pSparseMatrix->nzmax+sizeof(int)*pSparseMatrix->m+sizeof(int)*(pSparseMatrix->n+1));
	
	cudaMalloc( (void **) &(data_in1_gpu->pNZElement),size_NZElement);
	cudaMalloc( (void **) &(data_in1_gpu->pRow),size_Row);
	cudaMalloc( (void **) &(data_in1_gpu->pCol),size_Col);
	data_in1_gpu->m = pSparseMatrix->m;
	data_in1_gpu->n = pSparseMatrix->n;
	data_in1_gpu->nzmax = pSparseMatrix->nzmax;
	cudaMamcpy(data_in1_gpu->pNZElement,pSparseMatrix->pNZElement,size_NZElement,cudaMemcpyHostToDevice);
	cudaMamcpy(data_in1_gpu->pRow,pSparseMatrix->pRow,size_Row,cudaMemcpyHostToDevice);
	cudaMamcpy(data_in1_gpu->pCol,pSparseMatrix->pCol,size_Col,cudaMemcpyHostToDevice);
	
	//malloc device memory for Input vector
	size_t size_VElement, size_RElement;
	size_VElement = sizeof(t_ve)*pVector->m*pVector->n;
	size_RElement = sizeof(t_ve)*pSparseMatrix->m;
	cudaMalloc( (void **) &data_in2_gpu,sizeof(t_FullMatrix)*1);
	cudaMalloc( (void **) &(data_in2_gpu->pElement),size_VElement);
	data_in2_gpu->m = pVector->m;
	data_in2_gpu->n = pVector->n;
	cudaMamcpy(data_in2_gpu->pElement,pVector->pElement,size_Col,cudaMemcpyHostToDevice);
	
	//malloc output Vector
	cudaMalloc( (void **) &data_out_gpu,sizeof(t_FullMatrix)*1);
	cudaMalloc( (void **) &(data_out_gpu->pElement),size_RElement);

	// Compute execution configuration using 128 threads per block 
	dim3 dimBlock(sizeBlock);
	//dim3 dimGrid((sizeIn)/dimBlock.x);
	dim3 dimGrid(pSparseMatrix->m);
	//if ( (sizeA) % sizeBlock !=0 ) dimGrid.x+=1;
//sparseMatrixMul(t_FullMatrix * pResultVector,t_SparseMatrix *pSparseMatrix, t_FullMatrix * pVector)
	sparseMatrixMul<<<dimGrid,dimBlock>>>(data_out_f_gpu,data_in1_f_gpu, data_in2_f_gpu);
	e = cudaGetLastError();
	if ( e != cudaSuccess)
	{
			fprintf(stderr, "CUDA Error on square_elements: '%s' \n", cudaGetErrorString(e));
			exit(-1);
	}
	cudaMemcpy( pResultVector->pElement, data_out_f_gpu->pElement, size_RElement, cudaMemcpyDeviceToHost);
	pResultVector->m = pSparseMatrix->m;
	pResultVector->m = 1;
	
	cudaFree(data_in1_f_gpu);
	cudaFree(data_in2_f_gpu);
	cudaFree(data_out_f_gpu);
}


