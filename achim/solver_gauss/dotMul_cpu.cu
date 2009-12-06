

#include "projektcuda.h"

__host__ void dotMul_cpu(t_ve* in1, t_ve* in2,t_ve* out, unsigned int N)
{
	unsigned int i;

	out[0] = 0;

	for( i = 0; i < N; i++){
		out[0] += in1[i]*in2[i];
	}

}
