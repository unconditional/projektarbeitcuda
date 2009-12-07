
#include "projektcuda.h"

__host__ void matrixMul_cpu( t_ve* C, t_ve* A, t_ve* B, int mA, int nB)
{
	int i, j;
	for(i = 0; i < mA; i++){
        C[i]=0;
		for(j = 0; j < nB; j++){
			C[i] += A[i*nB+j] * B[j];
		}
	}
}


