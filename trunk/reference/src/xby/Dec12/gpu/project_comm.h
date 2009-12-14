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

#define VECTOR_BLOCK_SIZE 512

#include <time.h>
#define ITERATE 100

#endif //?PROJECT_COMM_H__
