#include "test_comm.h"

void host_matrixMul(double* pC, double* pA,double *pB, int mA, int nB)
{

	int i, j;

	double *data_in1_d, *data_in2_d, *data_out_d;
	float *data_in1_f, *data_in2_f, *data_out_f;
	float *data_in1_f_gpu, *data_in2_f_gpu , *data_out_f_gpu;
	int sizeBlock;
	sizeBlock = VECTOR_BLOCK_SIZE;
	int sizeA = mA*nB;
	int sizeB = nB;
	int sizeC = mA;

	// variable for time measure
	int it;
	float t_avg;
	t_avg = 0;
	//ITERATE defined in project_comm.h
	it = ITERATE;

	// get Input data pointer
	data_in1_d = pA;
	data_in2_d = pB;
	// get Ouput data pointer
	data_out_d = pC;


	// Find the dimensions of the data 

	// Create an mxArray for the output data 

	// Create an input and output data array on the GPU
	cudaMalloc( (void **) &data_in1_f_gpu,sizeof(t_ve)*sizeA);
	cudaMalloc( (void **) &data_in2_f_gpu,sizeof(t_ve)*sizeB);
	cudaMalloc( (void **) &data_out_f_gpu,sizeof(t_ve)*sizeC);
	// Retrieve the input data 

	// Check if the input array is single or double precision 

	// The input array is in double precision, it needs to be converted t floats before being sent to the card 
	data_in1_f = (t_ve *) malloc(sizeof(t_ve)*sizeA);
	data_in2_f = (t_ve *) malloc(sizeof(t_ve)*sizeB);

	data_out_f = (t_ve *) malloc(sizeof(t_ve)*sizeC);

	for (j = 0; j < sizeA; j++)
	{
		data_in1_f[j] = (t_ve) data_in1_d[j];
	}
	for (j = 0; j < sizeB; j++)
	{
		data_in2_f[j] = (t_ve) data_in2_d[j];
	}
	
	clock_t startTime;
	clock_t endTime;
	startTime=clock();
		
	cudaMemcpy( data_in1_f_gpu, data_in1_f, sizeof(t_ve)*sizeA, cudaMemcpyHostToDevice);
	cudaMemcpy( data_in2_f_gpu, data_in2_f, sizeof(t_ve)*sizeB, cudaMemcpyHostToDevice);
	
	// Compute execution configuration using 128 threads per block 
	dim3 dimBlock(sizeBlock);
	//dim3 dimGrid((sizeIn)/dimBlock.x);
	
	cudaDeviceProp deviceProp;
	cudaGetDeviceProperties(&deviceProp,0);
	printf("number of multiProcessors: %d \n",deviceProp.multiProcessorCount);
	int gridSize = deviceProp.multiProcessorCount;
	gridSize = 1024;
	
	
	//==================for matrixMul_kernel03.cu ========================
	//if(gridSize > mA) gridSize = mA;
	//================================================================
	
	//==================for matrixMul_kernel05.cu ========================
	
	int blockY = VECTOR_BLOCK_Y; //16
	if (gridSize*blockY > mA)gridSize = mA/blockY;
	if ( (mA) % blockY !=0 ) gridSize+=1;
	
	//==========================================================

	dim3 dimGrid(gridSize);
	//if ( (sizeA) % sizeBlock !=0 ) dimGrid.x+=1;
 		

	cudaError_t e;	
	START_CUDA_TIMER;
	for (i = 0; i < it ; i++){
	
			//Call function on GPU 
		matrixMul<<<dimGrid,dimBlock>>>(data_out_f_gpu,data_in1_f_gpu, data_in2_f_gpu, mA,nB);
		
		e = cudaGetLastError();
		if ( e != cudaSuccess)
		{
			fprintf(stderr, "CUDA Error on square_elements: '%s' \n", cudaGetErrorString(e));
			exit(-1);
		}
	
	}//it
	STOP_CUDA_TIMER( &t_avg);
	printf("GPU runing time =%lf (ms) \n",t_avg);
	// Copy result back to host 
	cudaMemcpy( data_out_f, data_out_f_gpu, sizeof(float)*sizeC, cudaMemcpyDeviceToHost);


	// Create a pointer to the output data 

	// Convert from single to double before returning 
	for (j = 0; j < sizeC; j++)
	{
		data_out_d[j] = (double) data_out_f[j];
	}
	// Clean-up memory on device and host 
	free(data_in1_f);
	free(data_in2_f);
	free(data_out_f);
	cudaFree(data_in1_f_gpu);
	cudaFree(data_in2_f_gpu);
	cudaFree(data_out_f_gpu);
}     
     
int test_matrixMul()
{
    double *pA, *pB,*pC;
    int mA, nB;
    int i;
	double expect;
	int loop;
	for (loop = 256; loop < 260; loop++) {
	int expect_error = 0;
    mA = loop;
    nB = loop;
    pA = (double*)malloc(sizeof(double)*mA*nB);
    pB = (double*)malloc(sizeof(double)*nB);
    pC = (double*)malloc(sizeof(double)*mA);
    for (i = 0; i < mA*nB; i++){
		pA[i] = 1;
	}
	for (i = 0; i < nB; i++){
		pB[i] = 1;
	}

    host_matrixMul(pC,pA, pB, mA, nB);
	
	expect = (double) nB;
	printf("output square result");
    for (i = 0; i < nB; i++)
    {	if(pC[i] != expect)
        printf(" pC[%d] = %lf, ", i, pC[i]);
		expect_error = loop;
    }
        printf("\n");
		printf("expect error = %d,\n",expect_error);	

    free(pA);
    free(pB);
    free(pC);
	}

    return 0;
 
}

int mexTest_matrixMul(double *pC,double *pA,double *pB,int mA, int nB)
{
    //double *pC;
    //int sizeOut;
    int i;
    //pC = (double*)malloc(sizeof(double)*mA);
    host_matrixMul(pC,pA, pB, mA, nB);
	
	//printf("output square result");
    //for (i = 0; i < nB; i++)
    //{	
	//if(pC[i] != expect)
     //   printf(" pC[%d] = %lf, ", i, pC[i]);
	//	expect_error = loop;
    //}
     //printf("\n");
	//	printf("expect error = %d,\n",expect_error);	
    //free(pC);	
    return 0;
}