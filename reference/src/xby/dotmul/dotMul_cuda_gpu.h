/*
dotMul_cuda_gpu.h

*/
#include "projektcuda.h"

__global__ void device_dotMul(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N);
