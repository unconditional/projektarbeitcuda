/*
matrixMul_cpu.c
*/
#ifndef __MATRIXMUL_CPU__
#define __MATRIXMUL_CPU__
#include "test_comm_cpu.h"
void matrixMul_cpu( t_ve* C, t_ve* A, t_ve* B, int mA, int nB)
{
	int i, j; 
	for(i = 0; i < mA; i++){
        C[i]=0;
		for(j = 0; j < nB; j++){
			C[i] += A[i*nB+j] * B[j];
		}
	}
}


void test_matrixMul_cpu(double * pC,double * pA, double* pB, unsigned int mA ,unsigned int nB)
{
	t_ve *pAin, *pBin, *pCout;
	int i;
	
	pAin = (t_ve*)malloc(sizeof(t_ve)*mA*nB);
	pBin = (t_ve*)malloc(sizeof(t_ve)*nB);
	pCout = (t_ve*)malloc(sizeof(t_ve)*mA);
	
	for (i = 0; i < mA*nB; i++){
		pAin[i] = (t_ve)pA[i];
	}	
	for (i = 0; i < nB; i++){
		pBin[i] = (t_ve)pB[i];
	}		
	
	matrixMul_cpu(pCout, pAin, pBin, mA, nB);
	
	for (i = 0; i < mA; i++){
		pC[i] = (double)pCout[i];
	}		
	
	free(pAin);
	free(pBin);
	free(pCout);
}


#endif