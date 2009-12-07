/*
UnitTestMain
*/

#include <stdio.h>
#include "host_dotMul.cu"
#include "host_norm.cu"
#include "host_matrixMul.cu"

#include "..\cpu\dotMul_cpu.c"
#include "..\cpu\norm_cpu.c"
#include "..\cpu\matrixMul_cpu.c"
/*
int main()
{
	 //test_matrixMul();
     test_dotMul();
	 //test_norm();
	 return 0;
}
*/
void callTestFunction(double** ppIn,int *pmIn,int *pnIn, int callFuncType,double** ppOut)
{
	//call cpu
	//printf("in callTestFunction \n");
	switch(callFuncType){
		case 0://dotMul
			if((pmIn[0]==pmIn[1])&&(pnIn[0]==pnIn[1])){
				//if(1==pnIn[0])test_dotMul_cpu(ppIn[0],ppIn[1],ppOut[0],pmIn[0]);
				if(1==pnIn[0]){
					host_dotMul(ppIn[0],ppIn[1],ppOut[0],pmIn[0],pnIn[0]);
					test_dotMul_cpu(ppIn[0],ppIn[1],ppOut[0],pmIn[0]);
				}
			}
			break;
		case 1://norm	
				//if(1==pnIn[0])test_norm_cpu(ppIn[0],ppOut[0],pmIn[0]);
				if(1==pnIn[0]){
					host_norm(ppIn[0],ppOut[0],pmIn[0], pnIn[0]);
					test_norm_cpu(ppIn[0],ppOut[0],pmIn[0]);
				}
		break;
		case 2: //matrixMul
			//test matrixMul A*B = C
			//ppIn[0]:matrix A, ppIn[1]: vector B, ppOut[0]: result verctor C
			//pmIn[0]=mA pmIn[1]=nB, pnIn[0]=nB,pnIn[1]=1
			if((pmIn[1]==pnIn[0])&&(1==pnIn[1])){
				//host_matrixMul(ppOut[0],ppIn[0],ppIn[1],pmIn[0], pmIn[1]);
				test_matrixMul_cpu(ppOut[0],ppIn[0],ppIn[1],pmIn[0], pmIn[1]);
			}
			
		default:  
			if((pmIn[0]==pmIn[1])&&(pnIn[0]==pnIn[1])){
				if(1==pnIn[0])host_dotMul(ppIn[0],ppIn[1],ppOut[0],pmIn[0],pnIn[0]);
			}
	}
}
void createMatrix(double **ppMatrix, unsigned int m, unsigned n,double val)
{
	double *pMatrix;
	int i;
	pMatrix = (double *)malloc(sizeof(double)*m*n);
	ppMatrix[0] = pMatrix;
	for (i = 0; i < m*n; i++){
		pMatrix[i] = val;
	}
}

int main()
{
	double** ppIn,**ppOut;
	double *pIn,*pOut;
	int *pmIn, *pnIn;
	int i, j, argInNum, argOutNum;
	int funcType,vectorSize;
	//0 dotMul
	//1 norm
	//2 matrixMul
	funcType = 2;
	vectorSize = 5000;
	switch(funcType){
		case 0://dotMul
			argInNum = 2;
			argOutNum = 1;
			
			ppOut = (double **)malloc(sizeof(double *)*argOutNum);
			ppIn = (double **)malloc(sizeof(double *)*argInNum);			
			pmIn = (int *) malloc(sizeof(int)*argInNum);			
			pnIn = (int *) malloc(sizeof(int)*argInNum);
			for(i = 0; i < argInNum ; i++){
				pmIn[i] =  vectorSize;
				pnIn[i] = 1;
				pIn = (double *)malloc(sizeof(double)*pmIn[i]*pnIn[i]);
				for(j = 0; j < pmIn[i]*pnIn[i]; j++)pIn[j] = 1;
				ppIn[i] = pIn;
			}		
			for(i = 0; i < argOutNum ; i++){
				pOut = (double *)malloc(sizeof(double)*1);
				pOut[i] = 0;
				ppOut[i] = pOut;
			}
		break;
		case 1:// norm
			argInNum = 1;
			argOutNum = 1;
			
			ppOut = (double **)malloc(sizeof(double *)*argOutNum);
			ppIn = (double **)malloc(sizeof(double *)*argInNum);			
			pmIn = (int *) malloc(sizeof(int)*argInNum);			
			pnIn = (int *) malloc(sizeof(int)*argInNum);
			for(i = 0; i < argInNum; i++){
				pmIn[i] =  vectorSize;
				pnIn[i] = 1;
				pIn = (double *)malloc(sizeof(double)*pmIn[i]*pnIn[i]);
				for(j = 0; j < pmIn[i]*pnIn[i]; j++)pIn[j] = 1;
				ppIn[i] = pIn;
			}		
			for(i = 0; i < argOutNum; i++){
				pOut = (double *)malloc(sizeof(double)*1);
				pOut[i] = 0;
				ppOut[i] = pOut;
			}
		break;
		case 2: //matrixMul
			argInNum = 2;
			argOutNum = 1;
			
			ppOut = (double **)malloc(sizeof(double *)*argOutNum);
			ppIn = (double **)malloc(sizeof(double *)*argInNum);			
			pmIn = (int *) malloc(sizeof(int)*argInNum);			
			pnIn = (int *) malloc(sizeof(int)*argInNum);
			
			pmIn[0] = vectorSize;
			pnIn[0] = vectorSize;
			pmIn[1] = vectorSize;
			pnIn[1] = 1;
			createMatrix(&(ppIn[0]),pmIn[0],pnIn[0],1);
			createMatrix(&(ppIn[1]),pmIn[1],pnIn[1],1);
			createMatrix(&(ppOut[0]),pmIn[0],pnIn[1],0);

		break;
		default:
		return 1;
		
	}

	callTestFunction(ppIn,pmIn,pnIn,funcType,ppOut);

	for ( i = 0; i < argInNum; i++){
		pIn = ppIn[i];
		//for(j = 0; j < pmIn[i]*pnIn[i]; j ++)printf("pIn[j] = %lf ,", pIn[j]);
		//printf("\n");
		free(pIn);
	}
	for ( i = 0; i < argOutNum; i++){
		pOut = ppOut[i];
		
        for(j = 0; j<pnIn[0];j++)printf("pOut[%d] = %lf \n", j,pOut[j]);
        
		free(pOut);
	}
	free(ppIn);
	free(ppOut);
	free(pmIn);
	free(pnIn);
	return 0;
}