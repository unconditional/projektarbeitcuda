#include "test_comm.h"
#include "time.h"

void host_scalarMul(double* pIn1, double* pIn2,double *pOut, int sizeIn, int sizeOut)
{

	int i, j;

	double *data_in1_d, *data_in2_d, *data_out_d;
	float *data_in1_f, *data_in2_f, *data_out_f;
	float *data_in1_f_gpu, *data_in2_f_gpu , *data_out_f_gpu;
	int sizeBlock;
	//VECTOR_BLOCK_SIZE defined in project_comm.h
	sizeBlock = VECTOR_BLOCK_SIZE;
	// variable for time measure
	int it;
	float t_avg;
	t_avg = 0;
	//ITERATE defined in project_comm.h
	it = ITERATE;
	// get Input data pointer
	data_in1_d = pIn1;
	data_in2_d = pIn2;
	// get Ouput data pointer
	data_out_d = pOut;
	//CUDA event
    cudaError_t e; 
    //cudaEvent_t start, stop;
    //float time;

	// Create an mxArray for the output data 
	//change sizeOut for cuda
	//sizeOut = (sizeIn)/sizeBlock;
	// Create an input and output data array on the GPU
	cudaMalloc( (void **) &data_in1_f_gpu,sizeof(t_ve)*sizeIn);
	cudaMalloc( (void **) &data_in2_f_gpu,sizeof(t_ve)*1);
	cudaMalloc( (void **) &data_out_f_gpu,sizeof(t_ve)*sizeOut);

	// The input array is in double precision, it needs to be converted t floats before being sent to the card 
	data_in1_f = (t_ve *) malloc(sizeof(t_ve)*sizeIn);
	data_in2_f = (t_ve *) malloc(sizeof(t_ve)*1);
	data_out_f = (t_ve *) malloc(sizeof(t_ve)*sizeOut);

	//startTime=clock();
	// Retrieve the input data 
	for (j = 0; j < sizeIn; j++)
	{
		data_in1_f[j] = (t_ve) data_in1_d[j];
	
	}
		data_in2_f[0] = (t_ve) data_in2_d[0];

	//startTime=clock();
 	////zeit
  /*
   e = cudaEventRecord( start, 0 );
    if( e != cudaSuccess )
    {
        fprintf(stderr, "CUDA Error on cudaEventRecord: '%s' \n", cudaGetErrorString(e));
        exit(-3);
    }
   */
	
		// copy data from host to device
	cudaMemcpy( data_in1_f_gpu, data_in1_f, sizeof(t_ve)*sizeIn, cudaMemcpyHostToDevice);
	cudaMemcpy( data_in2_f_gpu, data_in2_f, sizeof(t_ve)*1, cudaMemcpyHostToDevice);
	

		
	
	// Compute execution configuration using sizeBlock threads per block 
	dim3 dimBlock(sizeBlock);
	//define enough grid Size
	
	
	dim3 dimGrid((sizeIn)/dimBlock.x);
	if ( (sizeIn) % sizeBlock !=0 ) dimGrid.x+=1;  
	
	//it =1;
	for (i = 0; i < it ; i++){


		//Call function on GPU 
		device_scalarMul<<<dimGrid,dimBlock>>>(data_in1_f_gpu, data_in2_f_gpu, data_out_f_gpu, sizeIn);
		//cudaError_t e;
		
		e = cudaGetLastError();
		if ( e != cudaSuccess)
		{
			fprintf(stderr, "CUDA Error on square_elements: '%s' \n", cudaGetErrorString(e));
			exit(-1);
		}
		// Copy result back to host 
		cudaMemcpy( data_out_f, data_out_f_gpu, sizeof(float)*sizeOut, cudaMemcpyDeviceToHost);
		

	}//for it

	//cuda Timer end

    for (i = 0; i < sizeOut; i++)
    {
        printf("data_out_f[%d] = %f, ", i, data_out_f[i]);
    }
        printf("\n");


// Create a pointer to the output data 

	// Convert from single to double before returning 
	for (j = 0; j < sizeOut; j++)
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
     
int test_scalarMul()
{
    double *pIn1, *pIn2,*pOut;
    int sizeIn, sizeOut;
    int i;
	
	double expect;
	int loop;
	for (loop = 5000; loop < 5001; loop++) {
	int expect_error = 0;
    sizeIn = loop;
    //sizeOut =3;
	sizeOut =sizeIn;
    pIn1 = (double*)malloc(sizeof(double)*sizeIn);
    pIn2 = (double*)malloc(sizeof(double)*1);
    pOut = (double*)malloc(sizeof(double)*sizeOut);
    for (i = 0; i < sizeIn; i++){
		pIn1[i] = 1;
		
	}
	pIn2[0] = 1;
	/*
	pIn1[0] = 1;
    pIn1[1] = 2;
    pIn1[2] = 3;
    pIn2[0] = 1;
    pIn2[1] = 2;
    pIn2[2] = 3;
	*/
    host_scalarMul(pIn1, pIn2, pOut, sizeIn, sizeOut);
	expect=sizeIn;
	printf("output square result");
	/*
	if(pOut[0] != expect){
		
		for (i = 0; i < sizeOut; i++)
		{	
        printf(" pOut[%d] = %lf, ", i, pOut[i]);
		}
		
		expect_error = loop;
		printf(" pOut[0] = %lf,  ", pOut[0]);
        printf("\n");
		printf("expect error = %d,\n",expect_error);
		
	}*/
	/*
		expect_error = loop;
		printf(" pOut[0] = %lf,  ", pOut[0]);
        printf("\n");
		printf("expect error = %d,\n",expect_error);
*/

    free(pIn1);
    free(pIn2);
    free(pOut);
	}
    return 0;

}
//mexInterface 
//int mexTest_dotMul(double *pIn1,double *pIn2,int sizeIn)
int mexTest_scalarMul(double *pIn1,double *pIn2,double* pOut,int sizeIn)
{
    //double *pOut;
    int sizeOut;
    //int i;
    sizeOut =sizeIn;

    host_scalarMul(pIn1, pIn2, pOut, sizeIn, sizeOut);

    return 0;
}
