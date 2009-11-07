#include "mex.h"

void mexFunction(int outArraySize, mxArray *pOutArray[], int inArraySize, const mxArray *pInArray[])
{
 	 int i, j, m, n;
 	 double *data1, *data2;
 	 //if (intArraySize != outArraySize) mexErrMsgTxt("the number of input and output arguments must be same!");
 	 int rowMax;
	 int colMax;

 	 double *pMatrix;
 	 double *pX;
 	 
 	 m = mxGetM(pInArray[0]);
 	 n = mxGetN(pInArray[0]);
 	 rowMax = m;
 	 colMax = n;
 	 pMatrix=malloc(rowMax*colMax*sizeof(double));
 	 pX=malloc(rowMax*sizeof(double));
 	 
 	 pOutArray[0] = mxCreateDoubleMatrix(rowMax, 1, mxREAL);
 	 
 	 data1 = mxGetPr(pInArray[0]);
 	 data2 = mxGetPr(pOutArray[0]);
 	 
 	 for(i = 0; i < rowMax; i++)
 	 {
	  	   for(j = 0; j < colMax; j++)
	  	   {
		   		 pMatrix[i*colMax+j] = data1[i*colMax+j];
		   }
   	 }
 	 
    // gaussLesung(pMatrix, rowMax, colMax, pX);
   	 
   	 for(i = 0; i < rowMax; i++)data2[i] = pX[i];
		//outputMatrix(pX, rowMax, 1);
   	 
   	 free(pX);
   	 free(pMatrix);
}
