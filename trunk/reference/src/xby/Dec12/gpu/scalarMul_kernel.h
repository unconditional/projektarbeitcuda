#ifndef __SCALARMUL_KERNEL__
#define __SCALARMUL_KERNEL__

//pIn1: input Vector;
// N: Vectorsize;
// pIn2: input scalar;
//pOut: output Vector;
__global__ void device_scalarMul(t_ve* pIn1, t_ve* pIn2,t_ve* pOut, unsigned int N);

#endif