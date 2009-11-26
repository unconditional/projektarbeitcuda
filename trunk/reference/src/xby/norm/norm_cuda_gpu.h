/*
dotMul_cuda_gpu.h

*/
#ifndef __NORM_CUDA_GPU__
#def __NORM_CUDA_GPU__

#include "projektcuda.h"

__global__ void norm_elements(t_ve* in, t_ve* out, unsigned int N);


#endif
