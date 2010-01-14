//host_SparseMV
#include "test_comm.h"

// ---------------------------------------------------------------------
__host__ int smat_size( int count_nzmax, int cunt_rows ) {

    return   ( sizeof(t_ve) + sizeof(t_mindex) ) * count_nzmax
           + sizeof(t_mindex)  * (cunt_rows + 1);
}

// ---------------------------------------------------------------------
__host__ void set_sparse_data( t_SparseMatrix* m, void* mv ) {

   m->pCol = (t_mindex *) mv;
   m->pNZElement = (t_ve *) (&m->pCol[m->nzmax] ) ;
   m->pRow = (t_mindex *) (&m->pNZElement[m->nzmax]);

}
void host_sparseMatrixMul(t_FullMatrix * pResultVector,t_SparseMatrix *pSparseMatrix, t_FullMatrix * pVector){

	t_SparseMatrix host_SparseMatrix,dev_SparseMatrix;
	//t_SparseMatrix data_in1,*data_in1_host,*data_in1_gpu;//input sparse Matrix
	t_FullMatrix host_Vector,dev_Vector,host_ResultVector,dev_ResultVector;
	//t_FullMatrix data_in2,*data_in2_host,*data_in2_gpu;//input vector
	//t_FullMatrix data_out,*data_out_host,*data_out_gpu;//output vector
	size_t size_NZElement,size_Row,size_Col;
	int sizeBlock,i;
	//data_in1_host=&data_in1;
	//data_in2_host=&data_in2;
	//data_out_host=&data_out;
	
	sizeBlock = VECTOR_BLOCK_SIZE;
	//=====debug==================
	printf("=======in host========== \n");
	printf("pSparseMatrix->m=%d \n",pSparseMatrix->m);
	printf("pSparseMatrix->n=%d \n",pSparseMatrix->n);
	//============================
	/*
	host_SparseMatrix.m = pSparseMatrix->m;
	host_SparseMatrix.n = pSparseMatrix->n;
	host_SparseMatrix.nzmax = pSparseMatrix->nzmax;
	host_SparseMatrix.pCol = pSparseMatrix->pCol;
	host_SparseMatrix.pNZElement = pSparseMatrix->pNZElement;
	host_SparseMatrix.pRow = pSparseMatrix->pRow;

	host_Vector.m = pVector->m;
	host_Vector.n = pVector->n;
	host_Vector.pElement = pVector->pElement;	
	
	host_ResultVector.m = pResultVector->m;
	host_Vector.n = pResultVector->n;
	host_ResultVector.pElement = pResultVector->pElement;
	*/
	//size_NZElement = sizeof(t_ve)*pSparseMatrix->nzmax;
	//size_Row =sizeof(t_mindex)*(pSparseMatrix->m+1); //sizeof(int)*pSparseMatrix->m;
	//size_Col = sizeof(t_mindex)*pSparseMatrix->nzmax;//sizeof(int)*(pSparseMatrix->n+1);
	// Create an input and output data array on the GPU
	//malloc memory for Input Sparse-Matrix
	printf("malloc sparse Matrix \n");
	dev_SparseMatrix.m = pSparseMatrix->m;
	dev_SparseMatrix.n = pSparseMatrix->n;
	dev_SparseMatrix.nzmax = pSparseMatrix->nzmax;
	int msize = smat_size( dev_SparseMatrix.nzmax, dev_SparseMatrix.n );
    printf(" got result %u \n", msize);
	void *devicemem;
    cudaError_t e;
	e = cudaMalloc ( &devicemem, msize );
	CUDA_UTIL_ERRORCHECK("cudaMalloc")
	//pSparseMatrix->pCol is the begin of memery block
	e = cudaMemcpy(  devicemem, pSparseMatrix->pCol, msize , cudaMemcpyHostToDevice);
   CUDA_UTIL_ERRORCHECK("cudaMemcpy")
   set_sparse_data( &dev_SparseMatrix, devicemem);
	//malloc device memory for Input vector
	printf("malloc vector \n");
	size_t size_VElement, size_RElement;
	size_VElement = sizeof(t_ve)*pVector->m*pVector->n;
	size_RElement = sizeof(t_ve)*pSparseMatrix->m;
	cudaMalloc( (void **) &(dev_Vector.pElement),size_VElement);
	dev_Vector.m = pVector->m;//host_Vector.m;
	dev_Vector.n = pVector->n;//host_Vector.n;
	cudaMemcpy(dev_Vector.pElement,pVector->pElement,size_VElement,cudaMemcpyHostToDevice);
	
	printf("malloc output \n");
	//malloc output Vector
	dev_ResultVector.m = pSparseMatrix->m;
	dev_ResultVector.n = 1;
	cudaMalloc( (void **) &(dev_ResultVector.pElement),size_RElement);

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
	sparseMatrixMul<<<dimGrid,dimBlock>>>(dev_ResultVector,dev_SparseMatrix,dev_Vector);
	cudaError_t e;	
	e = cudaGetLastError();
	if ( e != cudaSuccess)
	{
			fprintf(stderr, "CUDA Error on square_elements: '%s' \n", cudaGetErrorString(e));
			exit(-1);
	}
	
	printf("get Result \n");
	//cudaMemcpy( data_out_host->pElement,pResultVector->pElement,  size_RElement, cudaMemcpyDeviceToHost);
	cudaMemcpy( pResultVector->pElement,dev_ResultVector.pElement,  size_RElement, cudaMemcpyDeviceToHost);
	
	pResultVector->m = pSparseMatrix->m;
	pResultVector->n = 1;
	//=========debug==============
		printf("==================Result in host============\n");
		for( i = 0; i < pResultVector->m; i++) printf("pResultVector->pElement[%d]=%f \n",i,pResultVector->pElement[i]);
	//=======================
	
	printf("free host \n");
	cudaFree(devicemem);
	cudaFree(dev_Vector.pElement);
	cudaFree(dev_ResultVector.pElement);

}


