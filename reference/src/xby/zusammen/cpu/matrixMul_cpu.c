/*
matrixMul_cpu.c
*/
#include "test_comm_cpu.h"
void matrixMul_cpu( t_ve* C, t_ve* A, t_ve* B, int mA, int nB)
{
	for(int i = 0; i < mA; i++){
		for(int j = 0; j < nB; j++){
			C[i] = A[i*nB+j] * B[j];
		}
	}
}