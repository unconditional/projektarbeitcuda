//host_SparseMV
#include "test_comm.h"
void host_sparseMatrixMul(t_FullMatrix * pResultVector,t_SparseMatrix *pSparseMatrix, t_FullMatrix * pVector){

	t_SparseMatrix *data_in1_gpu;//input sparse Matrix
	t_FullMatrix *data_in2_gpu;//input vector
	t_FullMatrix *data_out_gpu;//output vector
	// Create an input and output data array on the GPU
	cudaMalloc( (void **) &data_in1_gpu,sizeof(t_SparseMatrix)*1);
	//cudaMalloc( (void **) &(data_in1_gpu->pNZElement),sizeof(t_ve)*pSparseMatrix->nzmax+sizeof(int)*pSparseMatrix->m+sizeof(int)*(pSparseMatrix->n+1));
	cudaMalloc( (void **) &(data_in1_gpu->pNZElement),sizeof(t_ve)*pSparseMatrix->nzmax);
	cudaMalloc( (void **) &(data_in1_gpu->pRow),sizeof(int)*pSparseMatrix->m);
	cudaMalloc( (void **) &(data_in1_gpu->pCol),sizeof(int)*(pSparseMatrix->n+1));
	data_in1_gpu->m = pSparseMatrix->m;
	data_in1_gpu->n = pSparseMatrix->n;
	data_in1_gpu->nzmax = pSparseMatrix->nzmax;
	cudaMamcpy(data_in1_gpu->pNZElement)
	
	cudaMalloc( (void **) &data_in2_gpu,sizeof(t_FullMatrix)*1);
	cudaMalloc( (void **) &(data_in2_gpu->pElement),sizeof(t_ve)*pVector->m*pVector->n);
	
	cudaMalloc( (void **) &data_out_gpu,sizeof(t_FullMatrix)*1);
	cudaMalloc( (void **) &(data_out_gpu->pElement),sizeof(t_ve)*pSparseMatrix->m);

//sparseMatrixMul(t_FullMatrix * pResultVector,t_SparseMatrix *pSparseMatrix, t_FullMatrix * pVector)

}


