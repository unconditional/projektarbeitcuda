#ifndef __TEST_COMM_H__
#define __TEST_COMM_H__
#include <stdio.h>

#include "..\\gpu\\projektcuda.h"
#include "..\\gpu\\project_comm.h"
#define COMMPATH "..\\gpu\\projektcuda.h"
#define COMMHEAD COMMPATH 

#if TEST == GPU

#include "cuda.h"
#define FUNCTIONPATH1 "..\\gpu\\dotMul_cuda_gpu04.cu"

#include FUNCTIONPATH1

#define FUNCTIONPATH2 "..\\gpu\\norm_cuda_gpu02.cu"

#include FUNCTIONPATH2

#define FUNCTIONPATH3 "..\\gpu\\matrixMul_kernel03.cu"
#include FUNCTIONPATH3

# else 
#include "..\\cpu\\dotMul_cpu.c"
#include "..\\cpu\\matrixMul_cpu.c"
#include "..\\cpu\\norm_cpu.c"

#endif //if TEST

#endif
