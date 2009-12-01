/*
dotMul_cpu.c
*/
#include "test_comm_cpu.h"
void dotMul_cpu(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N)
{
	for(int i = 0; i < N; i++){
		out[i] = in1[i]*in2[i];
	}
}