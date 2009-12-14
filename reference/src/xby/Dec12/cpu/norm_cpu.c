/*
norm_cpu
*/
#ifndef __NORM_CPU__
#define __NORM_CPU__
#include "test_comm_cpu.h"

void norm_cpu(t_ve* in, t_ve* out, unsigned int N)
{
	int i;
	out[0] = 0;
	for( i = 0; i < N; i++){
		out[0] += in[i]*in[i];
	}
	//printf("square = %f, \n",out[0]);
	out[0] = sqrt(out[0]);
	//printf("sqrt = %f, \n",out[0]);
}
//void mexTest_norm(ppIn[0],ppOut[0],pmIn[0])
void test_norm_cpu(double * pIn,double * pOut, unsigned int N)
{
	t_ve *pVin, *pVout;
	int i;
	//variable for Time measure
	unsigned int it;
	double t_avg;
	it = ITERATE;
	t_avg = 0;
	
	pVin = (t_ve*)malloc(sizeof(t_ve)*N);
	pVout = (t_ve*)malloc(sizeof(t_ve)*1);
	
	for (i = 0; i < N; i++){
		pVin[i] = (t_ve)pIn[i];
	}	
	
	for (i=0;i<it; i++){	
		clock_t startTime;
		clock_t endTime;
		startTime=clock();
		//call computing function
		norm_cpu(pVin,pVout,N);
		
		endTime=clock();
		t_avg += endTime-startTime;
	}
	printf("lauf Tack  in CPU = %lf \n",t_avg);
	printf("laufTime  in CPU = %lf (ms)\n", ((double) t_avg)*1000 /(it* CLOCKS_PER_SEC));

	
	pOut[0] = (double)pVout[0];
	free(pVin);
	free(pVout);
}

#endif
