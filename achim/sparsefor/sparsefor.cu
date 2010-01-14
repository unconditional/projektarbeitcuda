#include <stdlib.h>
#include <stdio.h>


#include "projektcuda.h"


__global__ void kernel_sparsemul( int N, int row_step ) {


	int i = 0;

	if ( blockIdx.x == gridDim.x - 1 ) {
		printf("\n %u special case", threadIdx.x );
	}
	else {
		for ( int rs = 0; rs < row_step ; rs++ ) {
			int row = rs + row_step * blockIdx.x ;
			//printf ( "\n row %u rowblock %u block %u ", row, rs, blockIdx.x );

			// start calculation of row * b-vector here
	    }
	}


}

int main()
{
    t_ve* hostmem;

    printf("\n measure CUBLAS dotmul\n");

    int N = 2000000;

    int deviceCount;
    cudaGetDeviceCount(&deviceCount);

    int gridsize;

    if (deviceCount == 0)
        printf("There is no device supporting CUDA\n");

    int dev;
    for (dev = 0; dev < deviceCount; ++dev) {
        cudaDeviceProp deviceProp;
        cudaGetDeviceProperties(&deviceProp, dev);

        gridsize = deviceProp.multiProcessorCount;

        printf("  Number of multiprocessors:                     %d\n", deviceProp.multiProcessorCount);

        printf("\nDevice %d: \"%s\"\n", dev, deviceProp.name);
        printf("  CUDA Capability Major revision number:         %d\n", deviceProp.major);
        printf("  CUDA Capability Minor revision number:         %d\n", deviceProp.minor);
        printf("  Maximum number of threads per block:           %d\n", deviceProp.maxThreadsPerBlock);
    }

    int row_step = N / gridsize + 1;

    int n_calc = row_step * gridsize;

    printf("\n Initial N %d ", N );

    printf("\n using gridsize %d ", gridsize );
    printf("\n using row_step %d ", row_step );
    printf("\n using N_calc %d "  , n_calc );
    printf("\n \n");

    dim3 dimGrid ( gridsize );

    dim3 dimBlock( 8 );

    kernel_sparsemul<<<dimGrid,dimBlock>>>( N , row_step );

        printf("\n\n Initial N %d ", N );

	    printf("\n using gridsize %d ", gridsize );
	    printf("\n using row_step %d ", row_step );
	    printf("\n using N_calc %d "  , n_calc );
	    printf("\n \n");


}