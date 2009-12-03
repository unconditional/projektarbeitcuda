/*
dotMul_cpu.c
*/
#include "test_comm_cpu.h"

void dotMul_cpu(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N)
{
	int i;
	for( i = 0; i < N; i++){
		out[0] += in1[i]*in2[i];
	}
}

void test_dotMul_cpu(double * pIn1,double * pIn2, double* pOut, unsigned int N)
{
	t_ve *pV1, *pV2, pV3;
	int i;
	pV1 = (t_ve*)malloc(sizeof(t_ve)*N);
	pV2 = (t_ve*)malloc(sizeof(t_ve)*N);
	pV3 = (t_ve*)malloc(sizeof(t_ve));
	for (i = 0; i < N; i++){
		pV1[i] = (t_ve)pIn1[i];
		pV2[i] = (t_ve)pIn2[i];
	}	
	dotMul_cpu(pV1,pV2,pV3,N);
	pOut[0] = (double)pV3[0];
	free(pV1);
	free(pV2);
	free(pV3);
}