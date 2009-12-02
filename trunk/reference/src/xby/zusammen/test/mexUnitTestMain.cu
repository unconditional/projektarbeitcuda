/*
mexUnitTestMain.cu
*/
#include <stdio.h>
#include "mex.h"
#include "host_dotMul.cu"
#include "host_norm.cu"
#include "host_matrixMul.cu"



void callTestFunction(double** ppIn,int *pmIn,int *pnIn, int ArgNum){
//call gpu
//testdotMul
printf("pnIn[0]=%d,pmIn[0]=%d, \n",pnIn[0],pmIn[0]);
if(ArgNum ==2){
	if((pmIn[0]==pmIn[1])&&(pnIn[0]==pnIn[1])){
		if(1==pnIn[0])mexTest_dotMul(ppIn[0],ppIn[1],pmIn[0]);
	}
}

//call cpu

}


/* Gateway function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
     int inputArgNum = nrhs;
     int outputArgNum = nlhs;
     int i,j,k,m, n;
     double *pMatrix;
     double * pIn;  
     double ** ppIn;
     int *pmIn;
     int *pnIn;
     pnIn = (int*)mxMalloc(sizeof(int)*nrhs);
     pmIn = (int*)mxMalloc(sizeof(int)*nrhs);
     ppIn = (double**)mxMalloc(sizeof(double*)*nrhs);
     //printf("nrhs = %d \n",nrhs);
     for (i = 0; i < nrhs; i++){
        /* Find the dimensions of the data */
        m = mxGetM(prhs[i]);
        n = mxGetN(prhs[i]);
        printf("m = %d , n= %d \n",m,n);
        pmIn[i] = (int)m;
        pnIn[i] = (int)n;
        pMatrix = mxGetPr(prhs[i]); 
        pIn = (double*)mxMalloc(sizeof(double)*m*n);       
        ppIn[i]=pIn;
        
        for( k = 0; k < m; k++)
            for( j = 0; j < n; j++){
                pIn[k*n+j] = (double)pMatrix[j*m+k];
			//	printf("%f \n",pIn[k*n+j]);
            }
       
     }// for i
	 
	 //
	 callTestFunction(ppIn,pmIn,pnIn, inputArgNum);
	 
     for (i = 0; i < nrhs; i++){
        pIn=ppIn[i];
        //printf("m = %d , n= %d \n",pmIn[i],pnIn[i]);
        //for(j = 0; j < pnIn[i]*pmIn[i]; j++)printf("%f ,",pIn[j]);
        //printf("\n");
        mxFree(pIn);
     }
     
     mxFree(pnIn);
     mxFree(pmIn);
     mxFree(ppIn);
}