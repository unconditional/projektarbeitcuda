/*
mexUnitTestMain.cu
*/
#include <stdio.h>
#include "mex.h"
#define CPUPATH "..\\cpu\\"

#define DOTMUL_CPU CPUPATH "dotMul_cpu.c"
#define NORM_CPU CPUPATH "norm_cpu.c"
#define MATRIXMUL_CPU CPUPATH "matrixMul_cpu.c"
//#include DOTMUL_CPU


#include "..\cpu\dotMul_cpu.c"
#include "..\cpu\norm_cpu.c"
#include "..\cpu\matrixMul_cpu.c"
//#include NORM_CPU
//#include MATRIXMUL_CPU

#define dotMul 0


void callTestFunction(double** ppIn,int *pmIn,int *pnIn, int callFuncType,double** ppOut){
//call gpu
//testdotMul
	//printf("in callTestFunction \n");

	switch(callFuncType){
		case 0://dotMul
			if((pmIn[0]==pmIn[1])&&(pnIn[0]==pnIn[1])){
				if(1==pnIn[0])test_dotMul_cpu(ppIn[0],ppIn[1],ppOut[0],pmIn[0]);
			}
			break;
		case 1://norm
			printf("call norm \n");	
				if(1==pnIn[0])test_norm_cpu(ppIn[0],ppOut[0],pmIn[0]);
		break;
		case 2: //matrixMul
			//test matrixMul
			//ppIn[0]:matrix A, ppIn[1]: vector B
			//pmIn[0]=mA pmIn[1]=nB, pnIn[0]=nB,pnIn[1]=1
			if((pmIn[1]==pnIn[0])&&(1==pnIn[1])){
			//mexTest_matrixMul(double* pC, double *pA,double *pB, int mA, int nB);
				test_matrixMul_cpu(ppOut[0],ppIn[0],ppIn[1],pmIn[0], pmIn[1]);
			}
		default:  
			if((pmIn[0]==pmIn[1])&&(pnIn[0]==pnIn[1])){
				if(1==pnIn[0])test_dotMul_cpu(ppIn[0],ppIn[1],ppOut[0],pmIn[0]);
			}
	}

	//printf(DOTMUL_CPU);
	//printf("\n");
	//printf("pnIn[0]=%d,pmIn[0]=%d, \n",pnIn[0],pmIn[0]);
}

//??? how to specifine the ouput mxArray?
/* Gateway function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
     int inputArgNum;
     int outputArgNum;
     int i,j,k,m, n, retNum, outNum;
     double *pMatrix;
     double * pIn, *pOut;  
     double ** ppIn, **ppOut;
     int *pmIn;
     int *pnIn;
	 inputArgNum = nrhs;
	 outputArgNum = nlhs;
     pnIn = (int*)mxMalloc(sizeof(int)*nrhs);
     pmIn = (int*)mxMalloc(sizeof(int)*nrhs);
     ppIn = (double**)mxMalloc(sizeof(double*)*nrhs);
	 ppOut = (double**)mxMalloc(sizeof(double*)*1);
     //printf("nrhs = %d \n",nrhs);
     for (i = 0; i < nrhs; i++){
        /* Find the dimensions of the data */
        m = mxGetM(prhs[i]);
        n = mxGetN(prhs[i]);
        //printf("m = %d , n= %d \n",m,n);
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
	 
	 
	 if((nrhs > 0)){
		pMatrix = mxGetPr(prhs[nrhs-1]);
		retNum = (int)pMatrix[0];
		//printf("retNum = %d \n",retNum);
		switch (retNum){
			case 0://doutMul
				outNum = 1;
			break;
			case 1://norm
				outNum = 1;
			break;
			case 2://matrixMul
				outNum = pmIn[0];
			break;
			default://0
				outNum = 1;
		}
		if(outNum < 1) {
			printf("please define function Type! \ n");
			printf("0:dotMul,1:norm, 2: matrixMul \ n");
			return;
		}
		
		//printf("before mxCreateDoubleMatrix \n");
		plhs[0] = mxCreateDoubleMatrix(outNum,1,mxREAL);
		//printf("after mxCreateDoubleMatrix \n");
		pOut = mxGetPr(plhs[0]);
		ppOut[0] = pOut;

	 }//if nrhs>0
	 callTestFunction(ppIn,pmIn,pnIn, retNum, ppOut);
     for (i = 0; i < nrhs; i++){
        pIn=ppIn[i];
        mxFree(pIn);
     }
     
     mxFree(pnIn);
     mxFree(pmIn);
     mxFree(ppIn);
	 mxFree(ppOut);
}