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
typedef unsigned int t_mindex;
typedef struct Matrix{
    t_mindex m;
    t_mindex n;
    //size m*n
	t_ve* pElement;
} t_FullMatrix;

typedef struct SparseMatrix{
    t_mindex m;
    t_mindex n;
    t_mindex nzmax;
	//size m+1
    t_mindex *pRow;
    //size nzmax
	t_mindex *pCol;
	//size : nzmax
    t_ve* pNZElement;
} t_SparseMatrix;

texture<t_ve,1,cudaReadModeElementType> texRef;

#endif //?PROJECT_COMM_H__
