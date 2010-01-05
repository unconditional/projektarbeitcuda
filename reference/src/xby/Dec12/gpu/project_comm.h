#ifndef __PROJECT_COMM_H__
#define __PROJECT_COMM_H__



#define CHECK_BANK_CONFLICTS 0
#if CHECK_BANK_CONFLICTS
//?????????????????????????
#define AS(i) cutilBankChecker(((float*)&As[0]), (VECTOR_BLOCK_SIZE * i + j))
#define BS(i) cutilBankChecker(((float*)&Bs[0]), (VECTOR_BLOCK_SIZE * i + j))



#else
#define AS(i) As[i]
#define BS(i) Bs[i]
#endif





#include <time.h>
#define VECTOR_BLOCK_SIZE 512
#define ITERATE 100
typedef struct Matrix{
    unsigned int m;
    unsigned int n;
    //size m*n
	t_ve* pElement;
} t_FullMatrix;

typedef struct SparseMatrix{
    unsigned int m;
    unsigned int n;
    unsigned int nzmax;
	//size m+1
    unsigned int *pRow;
    //size nzmax
	unsigned int *pCol;
	//size : nzmax
    t_ve* pNZElement;
} t_SparseMatrix;

#endif //?PROJECT_COMM_H__
