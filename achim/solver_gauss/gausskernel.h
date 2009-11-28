#include "projektcuda.h"



__global__ void device_gauss_solver( t_ve* p_Ab, unsigned int N, t_ve* p_x );

