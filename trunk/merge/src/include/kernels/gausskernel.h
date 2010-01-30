#include "projektcuda.h"



__global__ void device_gauss_solver( t_ve* p_Ab, unsigned int N, t_ve* p_x );

__host__ void dbg_solver_check_result( t_ve* Ab_in, unsigned int N, t_ve* x_in );
