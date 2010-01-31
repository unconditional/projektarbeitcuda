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


__global__ void matrixMul_long_mA( t_ve* C, t_ve* A, t_ve* B, int mA, int nB);


__host__ void dbg_matrixMul_checkresult(
                                          t_ve* C_in,
                                          t_ve* A_in,
                                          t_ve* B_in,
                                          t_mindex mA,
                                          t_mindex mB,
                                          char* debugname
                                        );

#endif

