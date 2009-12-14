/*
dotMul_cpu.c
*/
#ifndef __DOTMUL_CPU__
#define __DOTMUL_CPU__


//#include "..\\gpu\\projektcuda.h"
//#include "..\\gpu\\project_comm.h"

#include "test_comm_cpu.h"
# include "cuda.h"

void dotMul_cpu(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N)
{
	int i;
	///initialize for iterate
	out[0] = 0;
	for( i = 0; i < N; i++){
		out[0] += in1[i]*in2[i];
	}
	
}

void test_dotMul_cpu(double * pIn1,double * pIn2, double* pOut, unsigned int N)
{

	t_ve *pV1, *pV2, *pV3;
	int i;
	
	unsigned int it;
	double t_avg;
	it = ITERATE;
	t_avg = 0;
	
	pV1 = (t_ve*)malloc(sizeof(t_ve)*N);
	pV2 = (t_ve*)malloc(sizeof(t_ve)*N);
	pV3 = (t_ve*)malloc(sizeof(t_ve)*1);
	for (i = 0; i < N; i++){
		pV1[i] = (t_ve)pIn1[i];
		pV2[i] = (t_ve)pIn2[i];
	}	
	//printf("before dotMul_cpu \n");
	
	clock_t startTime;
	clock_t endTime;
	startTime=clock();
	
	//cuda Timer begin	
	cudaEvent_t start, stop; 
	float time;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord( start, 0 ); 
	
	for (i=0;i<it; i++){	

		//call computing function
		dotMul_cpu(pV1,pV2,pV3,N);
		

	}
	
	cudaEventRecord( stop, 0 ); 
	cudaEventSynchronize( stop ); 
	cudaEventElapsedTime( &time, start, stop );
	cudaEventDestroy( start );
	cudaEventDestroy( stop );
	printf("cuda laufTime  in CPU = %lf (ms)\n", (time) /(it));
	
	endTime=clock();
	t_avg = endTime-startTime;
	printf("laufTime  in CPU = %lf (ms)\n", ((double) t_avg)*1000 /(it* CLOCKS_PER_SEC));
	
	//printf("after dotMul_cpu \n");
	pOut[0] = (double)pV3[0];
	free(pV1);
	free(pV2);
	free(pV3);
}
#endif