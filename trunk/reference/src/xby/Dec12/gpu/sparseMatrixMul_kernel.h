#ifndef __SPARSEMATRIXMUL_KERNEL__
#define __SPARSEMATRIXMUL_KERNEL__

//__global__ void sparseMatrixMul(t_FullMatrix * pResultVector,t_SparseMatrix *pSparseMatrix, t_FullMatrix * pVector);
__global__ void sparseMatrixMul(t_FullMatrix pResultVector,t_SparseMatrix pSparseMatrix, t_FullMatrix pVector);

#endif
