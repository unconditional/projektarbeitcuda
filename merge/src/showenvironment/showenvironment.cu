#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"
#include "measurehelp.h"

int main()
{
    printf( "Build configuration: sizeof(t_ve) = %u \n", sizeof(t_ve));
    printf("\n detecting environment... \n");

    int deviceCount;
    cudaGetDeviceCount(&deviceCount);

    if (deviceCount == 0)
        printf("There is no device supporting CUDA\n");

    int dev;
    for (dev = 0; dev < deviceCount; ++dev) {
        cudaDeviceProp deviceProp;
        cudaGetDeviceProperties(&deviceProp, dev);



        printf("\nDevice %d: \"%s\"\n \n", dev, deviceProp.name);
        printf("  Number of multiprocessors:                     %d\n", deviceProp.multiProcessorCount);
        printf("  CUDA Capability Major revision number:         %d\n", deviceProp.major);
        printf("  CUDA Capability Minor revision number:         %d\n", deviceProp.minor);
        printf("  Maximum number of threads per block:           %d\n", deviceProp.maxThreadsPerBlock);
    }

}
