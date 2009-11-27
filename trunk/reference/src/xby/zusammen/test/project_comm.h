#ifndef __PROJECT_COMM_H__
#define __PROJECT_COMM_H__

#include "cuda.h"
#include <stdio.h>

#define COMMPATH "..\\gpu\\projektcuda.h"
#define COMMHEAD COMMPATH 
#include COMMHEAD

#define FUNCTIONPATH1 "..\\gpu\\dotMul_cuda_gpu.cu"

#include FUNCTIONPATH1

#define FUNCTIONPATH2 "..\\gpu\\norm_cuda_gpu.cu"

#include FUNCTIONPATH2



#endif
