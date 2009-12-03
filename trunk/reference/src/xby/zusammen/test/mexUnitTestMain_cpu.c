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
//#include NORM_CPU
//#include MATRIXMUL_CPU



void callTestFunction(double** ppIn,int *pmIn,int *pnIn, int InputArgNum){
//call gpu
//testdotMul
printf(DOTMUL_CPU);
printf("\n");
printf("pnIn[0]=%d,pmIn[0]=%d, \n",pnIn[0],pmIn[0]);
if(InputArgNum ==2){
	if((pmIn[0]==pmIn[1])&&(pnIn[0]==pnIn[1])){
		if(1==pnIn[0])test_dotMul_cpu(ppIn[0],ppIn[1],pmIn[0]);
	}
}
/*
//test norm
if(InputArgNum ==1){
	if((pmIn[0]==pmIn[1])&&(pnIn[0]==pnIn[1])){
		if(1==pnIn[0])mexTest_norm(ppIn[0],pmIn[0]);
	}
}
//test matrixMul
//ppIn[0]:matrix A, ppIn[1]: vector B
if(InputArgNum ==2){
	//pmIn[0]=mA pmIn[1]=nB, pnIn[0]=nB,pnIn[1]=1
	if((pmIn[1]==pnIn[0])&&(1==pnIn[1])){
		//mexTest_matrixMul(double *pA,double *pB,int mA, int nB);
		mexTest_matrixMul(ppIn[0],ppIn[1],pmIn[0], pmIn[1]);
	}
}
*/

}

//??? how to specifine the ouput mxArray?
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
	 for(i = 0; i < outputArgNum; i++){
		plhs[i]=mxCreateDoubleMatrix(m, n, mxREAL);
	 }
	 //
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