#ifndef __TEST_COMM_H__
#define __TEST_COMM_H__

#include "cuda.h"
#include <stdio.h>

#define COMMPATH "..\\gpu\\projektcuda.h"
#define COMMHEAD COMMPATH 


#include "..\\gpu\\projektcuda.h"
#include "..\\gpu\\project_comm.h"



#define FUNCTIONPATH1 "..\\gpu\\dotMul_cuda_gpu04.cu"

#include FUNCTIONPATH1

#define FUNCTIONPATH2 "..\\gpu\\norm_cuda_gpu02.cu"

#include FUNCTIONPATH2

#define FUNCTIONPATH3 "..\\gpu\\matrixMul_kernel03.cu"
#include FUNCTIONPATH3
#endif
