/*
dotMul_cuda_gpu.h

*/
#ifndef __DOTMUL_CUDA_GPU__
#define __DOTMUL_CUDA_GPU__

#include "projektcuda.h"

__global__ void kernel_dotmul( t_ve *in1,
                               t_ve *in2,
                               t_ve *out
                             );

__host__ void dbg_dotmul_checkresult ( t_ve *in1,
                                       t_ve *in2,
                                       t_ve tobeckecked,
                                       t_mindex N ,
                                       char* debugname
                                     );

#endif
