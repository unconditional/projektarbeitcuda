#ifndef __MATRIXMUL_KERNEL_H__
#define __MATRIXMUL_KERNEL_H__

////////////////////////////////////////////////////////////////////////////////
//! Matrix and Vector multiplication on the device: C = A * B
//!	Matrix A is mA x nB  , Vector B is nB
//!	Vector C output vector in size of mA
//!	description:
//!	each row of A occuppy one block. if gridDim is smaller than the row number of A  
////////////////////////////////////////////////////////////////////////////////
__global__ void matrixMul( t_ve* C, t_ve* A, t_ve* B, int mA, int nB);

#endif

