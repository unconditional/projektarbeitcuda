#define START_CUDA_TIMER         cudaEvent_t start,stop; \
        e = cudaEventCreate( &stop ); \
        CUDA_UTIL_ERRORCHECK("cudaEventCreate"); \
        e = cudaEventCreate( &start ); \
        CUDA_UTIL_ERRORCHECK("cudaEventCreate"); \
        e= cudaEventRecord(start,0); \
        CUDA_UTIL_ERRORCHECK("cudaEventRecord"); \

#define STOP_CUDA_TIMER( TARGET )       e= cudaEventRecord(stop,0 ); \
        CUDA_UTIL_ERRORCHECK("cudaEventRecord"); \
        e = cudaEventSynchronize(stop); \
        CUDA_UTIL_ERRORCHECK("cudaEventSynchronize"); \
        e = cudaEventElapsedTime( TARGET, start, stop ); \

