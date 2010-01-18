#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"


texture<float,1, cudaReadModeElementType> texRef;


int MSIZE = 1000000;

__global__ void kernel_testtex() {


	float bla = tex1Dfetch( texRef , 0 );
}



int main()
{


    printf("\n test texture \n");

    cudaError_t e;

    cudaChannelFormatDesc channelDesc
        = cudaCreateChannelDesc( 32, 0, 0, 0, cudaChannelFormatKindFloat );

    /* cudaChannelFormatKindNone */

    float* dev_mem;


    e = cudaMalloc ((void **) &dev_mem, sizeof(double) * MSIZE );
    CUDA_UTIL_ERRORCHECK("cudaMalloc")



     e = cudaBindTexture (
		               NULL ,      /*size_t  offset,*/
                       texRef,     /*const struct textureReference  texref */
                       dev_mem,    /* const void devPtr, */
                       channelDesc,
                       sizeof(double) * MSIZE
                     );

     CUDA_UTIL_ERRORCHECK("cudaBindTexture")


     dim3 dimGrid ( 2 );
     dim3 dimBlock(32);

     kernel_testtex<<<dimGrid,dimBlock>>>();

     e = cudaGetLastError();
     CUDA_UTIL_ERRORCHECK("kernel_testtex");

}