#include "projektcuda.h"

#define GAUSSNMAX 22

__global__ void device_gauss_solver( t_ve* p_Ab, unsigned int N, t_ve* p_x );

