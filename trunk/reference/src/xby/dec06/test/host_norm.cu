#include "test_comm.h"

void host_norm(double* pIn, double *pOut, int sizeIn, int sizeOut)
{

	int i, j;
	double *data1, *data2;
	float *data1f, *data2f;
	float *data1f_gpu, *data2f_gpu;
	int sizeBlock;

	// variable for time measure
	int it;
	float t_avg;
	t_avg = 0;
	//ITERATE defined in project_comm.h
	it = ITERATE;

	sizeBlock = VECTOR_BLOCK_SIZE;
	// get Input data pointer
	data1 = pIn;
	data2 = pOut;

	// Find the dimensions of the data 

	// Create an mxArray for the output data 

	// Create an input and output data array on the GPU
	cudaMalloc( (void **) &data1f_gpu,sizeof(float)*sizeIn);
	cudaMalloc( (void **) &data2f_gpu,sizeof(float)*sizeOut);
	// Retrieve the input data 

	// Check if the input array is single or double precision 

	// The input array is in double precision, it needs to be converted t floats before being sent to the card 
	data1f = (float *) malloc(sizeof(float)*sizeIn);
	for (j = 0; j < sizeIn; j++)
	{
		data1f[j] = (float) data1[j];
	}


	cudaMemcpy( data1f_gpu, data1f, sizeof(float)*sizeIn, cudaMemcpyHostToDevice);

	data2f = (float *) malloc(sizeof(float)*sizeOut);
	//cudaMemcpy( data2f_gpu, data2f, sizeof(float)*sizeOut, cudaMemcpyHostToDevice);

	// Compute execution configuration using 128 threads per block 
	dim3 dimBlock(sizeBlock);
	dim3 dimGrid((sizeIn)/dimBlock.x);
	if ( (sizeIn) % sizeBlock !=0 ) dimGrid.x+=1;
	for (i = 0; i < it ; i++){
		clock_t startTime;
		clock_t endTime;
		startTime=clock();	 
	// Call function on GPU 
	norm_elements<<<dimGrid,dimBlock>>>(data1f_gpu, data2f_gpu, sizeIn);
	cudaError_t e;
	e = cudaGetLastError();
	if ( e != cudaSuccess)
	{
		fprintf(stderr, "CUDA Error on square_elements: '%s' \n", cudaGetErrorString(e));
		exit(-1);
	}
	
	endTime=clock();
	t_avg += endTime-startTime;
	}//for it
	printf("laufTime  in CPU = %lf (ms)\n", ((double) t_avg)*1000 /(it* CLOCKS_PER_SEC));
	
	// Copy result back to host 
	cudaMemcpy( data2f, data2f_gpu, sizeof(float)*sizeOut, cudaMemcpyDeviceToHost);

	// Create a pointer to the output data 

	// Convert from single to double before returning 
	for (j = 0; j < sizeOut; j++)
	{
		data2[j] = (double) data2f[j];
	}
	// Clean-up memory on device and host 
	free(data1f);
	free(data2f);
	cudaFree(data1f_gpu);
	cudaFree(data2f_gpu);
}

int test_norm()
{

    double *pIn, *pOut;
    int sizeIn, sizeOut;
    int i;
    sizeIn = 1000;
    sizeOut = sizeIn/VECTOR_BLOCK_SIZE;
    pIn = (double*)malloc(sizeof(double)*sizeIn);
    pOut = (double*)malloc(sizeof(double)*sizeOut);
    /*
	pIn[0] = 3;
    pIn[1] = 4;
    //pIn[2] = 3;
	*/
	for (i = 0; i < sizeIn; i++){
		pIn[i] = 1;
	}
    host_norm(pIn, pOut, sizeIn, sizeOut);
	
    printf("output square result");
    for (i = 0; i < sizeOut; i++)
    {	
        printf(" pOut[%d] = %lf, ", i, pOut[i]);
    }
        printf("\n");
	printf("output norm result");
    for (i = 0; i < sizeOut; i++)
    {
		//pOut[i] = sqrt(pOut[i]);
        printf("squre of pOut[%d] = %lf, ", i, pOut[i]);
    }
        printf("\n");   
    free(pIn);
    free(pOut);
    return 0;
}
int mexTest_norm(double *pIn,double *pOut,int sizeIn)
{
    //double *pOut;
    int sizeOut;
    int i;

	//sizeOut =sizeIn/VECTOR_BLOCK_SIZE + 1;
	sizeOut=1;
    //pOut = (double*)malloc(sizeof(double)*sizeOut);

    host_norm(pIn, pOut, sizeIn, sizeOut);
	double expect=sizeIn;
	//printf("output square result");
	
	//if(pOut[0] != expect){
		
		//for (i = 0; i < sizeOut; i++)
		//{	
			//printf(" pOut[%d] = %lf, ", i, pOut[i]);
		//}

	//}

    //free(pOut);
	
    return 0;

}