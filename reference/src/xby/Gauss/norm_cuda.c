#include "cuda.h"
#include "mex.h"
_global_ void norm_elements(float* pIn, float* pOut, int N)
{
 		 int idx = blockIdx.x*blockDim.x+threadIdx.x;
 		 if(idx < N)
		 {
		  		*pOut += pIn[idx]*pIn[idx];
 		 }
		   
}

void mexFunction(int outArraySize, mxArray *pOutArray, int inArraySize, const mxArray *pInArray)
{

}
