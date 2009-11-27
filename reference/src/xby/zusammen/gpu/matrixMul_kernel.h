#ifndef __MATRIXMUL_KERNEL__
#define __MATRIXMUL_KERNEL__

////////////////////////////////////////////////////////////////////////////////
//! Matrix multiplication on the device: C = A * B
//! wA is A's width and wB is B's width
//! wB = 1;
////////////////////////////////////////////////////////////////////////////////
__global__ void matrixMul( float* C, float* A, float* B, int wA, int wB);

#endif

