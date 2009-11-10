
__global__ void summup(double* h, double* e, int N) 
{
    int idx = blockIdx.x*blockDim.x + threadIdx.x;
    if (idx<N)
       h[idx] += e[idx];
    // __syncthreads();
}
