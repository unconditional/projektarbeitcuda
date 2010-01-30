/*
dotMul_cuda_gpu.h

*/
#ifndef __NORM_CUDA_GPU__
#define __NORM_CUDA_GPU__

#include "projektcuda.h"

__global__ void kernel_norm(t_ve* in, t_ve* out );


#endif


__host__ void dbg_norm_checkresult ( t_ve *in1,

                                     t_ve tobeckecked,
                                     t_mindex N ,
                                     char* debugname
                                      );
