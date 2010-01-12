//host_SparseMV
#include "test_comm.h"
void host_sparseMatrixMul(t_FullMatrix * pResultVector,t_SparseMatrix *pSparseMatrix, t_FullMatrix * pVector){

	t_SparseMatrix data_in1,*data_in1_host,*data_in1_gpu;//input sparse Matrix
	t_FullMatrix data_in2,*data_in2_host,*data_in2_gpu;//input vector
	t_FullMatrix data_out,*data_out_host,*data_out_gpu;//output vector
	size_t size_NZElement,size_Row,size_Col;
	int sizeBlock,i;
	data_in1_host=&data_in1;
	data_in2_host=&data_in2;
	data_out_host=&data_out;
	sizeBlock = VECTOR_BLOCK_SIZE;
	//=====debug==================
	printf("=======in host========== \n");
	printf("pSparseMatrix->m=%d \n",pSparseMatrix->m);
	printf("pSparseMatrix->n=%d \n",pSparseMatrix->n);
	//============================
	
	size_NZElement = sizeof(t_ve)*pSparseMatrix->nzmax;
	size_Row =sizeof(int)*(pSparseMatrix->m+1); //sizeof(int)*pSparseMatrix->m;
	size_Col = sizeof(int)*pSparseMatrix->nzmax;//sizeof(int)*(pSparseMatrix->n+1);
	// Create an input and output data array on the GPU
	//malloc memory for Input Sparse-Matrix
	
	printf("malloc sparse Matrix \n");
	cudaMalloc( (void **) &(data_in1_host->pNZElement),size_NZElement);
	cudaMalloc( (void **) &(data_in1_host->pRow),size_Row);
	cudaMalloc( (void **) &(data_in1_host->pCol),size_Col);
	data_in1_host->m = pSparseMatrix->m;
	data_in1_host->n = pSparseMatrix->n;
	data_in1_host->nzmax = pSparseMatrix->nzmax;
	cudaMemcpy(data_in1_host->pNZElement,pSparseMatrix->pNZElement,size_NZElement,cudaMemcpyHostToDevice);
	cudaMemcpy(data_in1_host->pRow,pSparseMatrix->pRow,size_Row,cudaMemcpyHostToDevice);
	cudaMemcpy(data_in1_host->pCol,pSparseMatrix->pCol,size_Col,cudaMemcpyHostToDevice);
	//cudaMalloc( (void **) &data_in1_gpu,sizeof(t_SparseMatrix)*1);
	//cudaMemcpy(data_in1_gpu,data_in1_host,sizeof(t_SparseMatrix)*1,cudaMemcpyHostToDevice);
	
	//malloc device memory for Input vector
	printf("malloc vector \n");
	size_t size_VElement, size_RElement;
	size_VElement = sizeof(t_ve)*pVector->m*pVector->n;
	size_RElement = sizeof(t_ve)*pSparseMatrix->m;
	cudaMalloc( (void **) &(data_in2_host->pElement),size_VElement);
	data_in2_host->m = pVector->m;
	data_in2_host->n = pVector->n;
	cudaMemcpy(data_in2_host->pElement,pVector->pElement,size_Col,cudaMemcpyHostToDevice);
	//cudaMalloc( (void **) &data_in2_gpu,sizeof(t_FullMatrix)*1);
	//cudaMemcpy(data_in2_gpu,data_in2_host,sizeof(t_FullMatrix)*1,cudaMemcpyHostToDevice);

	
	
	printf("malloc output \n");
	//malloc output Vector
	data_out_host->m = pSparseMatrix->m;
	data_out_host->n = 1;
	cudaMalloc( (void **) &(data_out_host->pElement),size_RElement);
	//cudaMalloc( (void **) &data_out_gpu,sizeof(t_FullMatrix)*1);
	//cudaMemcpy(data_out_gpu,data_out_host,sizeof(t_FullMatrix)*1,cudaMemcpyHostToDevice);

	// Compute execution configuration using 128 threads per block 
	dim3 dimBlock(sizeBlock);
	//dim3 dimGrid((sizeIn)/dimBlock.x);
	cudaDeviceProp deviceProp;
	cudaGetDeviceProperties(&deviceProp,0);
	printf("number of multiProcessors: %d \n",deviceProp.multiProcessorCount);
	int sizeGrid = 65535;
	if (sizeGrid > pSparseMatrix->m)sizeGrid = pSparseMatrix->m;
	printf("grid size = %d\n",sizeGrid);
	dim3 dimGrid(sizeGrid);
	//if ( (sizeA) % sizeBlock !=0 ) dimGrid.x+=1;
	//sparseMatrixMul(t_FullMatrix * pResultVector,t_SparseMatrix *pSparseMatrix, t_FullMatrix * pVector)
	//sparseMatrixMul<<<dimGrid,dimBlock>>>(data_out_gpu,data_in1_gpu,data_in2_gpu);
	printf("calling kernel \n");
	sparseMatrixMul<<<dimGrid,dimBlock>>>(data_out,data_in1,data_in2);
	cudaError_t e;	
	e = cudaGetLastError();
	if ( e != cudaSuccess)
	{
			fprintf(stderr, "CUDA Error on square_elements: '%s' \n", cudaGetErrorString(e));
			exit(-1);
	}
	
	printf("get Result \n");
	//cudaMemcpy( data_out_host->pElement,pResultVector->pElement,  size_RElement, cudaMemcpyDeviceToHost);
	cudaMemcpy( pResultVector->pElement,data_out_host->pElement,  size_RElement, cudaMemcpyDeviceToHost);
	
	pResultVector->m = pSparseMatrix->m;
	pResultVector->n = 1;
	//=========debug==============
		printf("==================Result in host============\n");
		for( i = 0; i < pResultVector->m; i++) printf("pResultVector->pElement[%d]=%f \n",i,pResultVector->pElement[i]);
	//=======================
	
	printf("free host \n");
	cudaFree(data_in1_host->pNZElement);
	cudaFree(data_in1_host->pRow);
	cudaFree(data_in1_host->pCol);
	cudaFree(data_in2_host->pElement);
	cudaFree(data_out_host->pElement);

}


