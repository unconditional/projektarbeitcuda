/*
norm_cpu
*/
#include "test_comm_cpu.h"

void norm_elements(t_ve* in, t_ve* out, unsigned int N)
{
	for(int i = 0; i < N; i++){
		out[i] = in[i]*in[i];
	}
}