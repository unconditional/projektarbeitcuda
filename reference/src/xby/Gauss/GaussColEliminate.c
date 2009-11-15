#include <stdio.h>
#include <math.h>
#include "mex.h"

/*
  pA: the pointer of the Matrix A|b
  rowMax,colMax:size of matirx
  row: begin row
  col: working col
  l: the row with the max value in the working col
*/
int findMax(double *pA, int rowMax,int colMax, int row, int col)
{
    double * pMatrix = pA;
    // element pMatrix[i*colMax+j]
    // col pMatrix[i*colMatrix]~~pMatrix[(i+1)*colMatrix-1]
    double MAX = pMatrix[row*colMax+col];
    int i;
    int l = row;
    for (i = row;i < rowMax;i++){
        if(MAX < pMatrix[i*colMax+col])
        {
         MAX=fabs(pMatrix[i*colMax+col]);
         l=i;
        }
    }
    return l;
}

/*
  pA: the pointer of the Matrix A|b
  rowMax,colMax:size of matirx
  row1,row2: indexes of the rows,which are exchanged with each other.

*/
void exchangeRow(double *pA, int rowMax,int colMax,int row1, int row2)
{   
    double * pMatrix = pA;
    double swap;
    int i;
    if(row1 != row2)
    {
     for(i = 0; i < colMax; i++)
     {
      swap=pMatrix[row1*colMax+i];
      pMatrix[row1*colMax+i] = pMatrix[row2*colMax+i];
      pMatrix[row2*colMax+i] = swap;
     }
    }
}
/*
  pA: the pointer of the Matrix A|b
  rowMax,colMax:size of matirx
  row: begin row
  col: working col
*/
int eliminate(double *pA, int rowMax,int colMax,int row, int col)
{
     double * pMatrix = pA;
     int i,j;
     double aii = pMatrix[row*colMax+col];
     if(0 == aii)return 0;
	 for(i = row+1; i < rowMax; i++)
     {
 	  	   double aji = pMatrix[i*colMax+col];  
	  	   for(j = row; j < colMax; j++)
	  	   {
	   	   		 pMatrix[i*colMax+j] -= pMatrix[row*colMax+j]*aji/aii;
	       }   
		   //printf("aii = %lf, aji = %lf, \n",aii,aji);   
     }
        
     return 1;  
}
/*
  pA: the pointer of the Matrix A|b
  rowMax,colMax:size of matirx
  pX: result X vector
*/
int solveX(double *pA, int rowMax,int colMax, double *pX)
{
 	double *pMatrix = pA;
 	int i,j;
 	
 	for(i = rowMax-1; i >= 0; i--)
 	{
	 	  double Sum = 0;
  	 	  for(j = i+1; j < rowMax; j++)
  	 	  {
  	  	   		Sum += pX[j]*pMatrix[i*colMax+j];
  	  	   		
  	 	  }
  	 	  
  	 	  pX[i]=(pMatrix[(i+1)*colMax-1]-Sum)/pMatrix[i*colMax+i];
  	 	  //printf("sum = %lf,b= %lf,aii= %lf, \n",Sum,pMatrix[(i+1)*colMax-1],pMatrix[i*colMax+i]);
  	 	  //printf("x=%lf,i=%d \n",pX[i],i);
  	}
 	return 1;
}
/*
  pA: the pointer of the Matrix A|b
  rowMax,colMax:size of matirx
*/
void outputMatrix(double *pA, int rowMax,int colMax)
{
 	double *pMatrix = pA;
	int i,j;
	for (i = 0; i < rowMax; i++)
	{
	 	for (j = 0; j < colMax; j++)
 		{
		 	printf("%lf, ,",pMatrix[i*colMax+j]);
   		}
		printf("\n");  	
	}
	
}
/*
  pA: the pointer of the Matrix A|b
  rowMax,colMax:size of matirx
  pX: solution vector
  return value: -1 solving equation failed
  		 		1 resolve result successfully
*/
int gaussLesung(double *pA, int rowMax,int colMax, double *pX)
{
 	 double *pMatrix = pA;
 	 int i;
 	 double product;
 	 product = 1;
 	 if((1+rowMax)!=colMax) return -1;
 	 
 	 for(i = 0; i < rowMax; i++)
 	 {
  	   int l;
 	   printf("%d,\n",i);
 	   
 	   l = findMax(pMatrix, rowMax, colMax, i,i);
 	   exchangeRow(pMatrix, rowMax, colMax, l, i);
 	   eliminate(pMatrix, rowMax, colMax, i, i);
       outputMatrix(pMatrix, rowMax, colMax);
     }
     
     
     for(i = 0; i < rowMax; i++)product = product * pMatrix[i*colMax+i];
     if(product==0)return -1;
 	 
	  solveX(pMatrix, rowMax,colMax, pX);
	  return 1;
}

/*
  matlabe interface 
  example:  
  A = [1,2,3;1,1,1;2,1,1]
  b=[14;6;7]
  M=[A,b]
  
  x=GaussColEliminate(M)
*/
void mexFunction(int outArraySize, mxArray *pOutArray[], int inArraySize, const mxArray *pInArray[])
{
 	 int i, j, m, n;
 	 double *data1, *data2;
 	 int rowMax, colMax;
 	 double *pMatrix, *pX;

 	 //if (intArraySize != outArraySize) mexErrMsgTxt("the number of input and output arguments must be same!");
 	 m = mxGetM(pInArray[0]);
 	 n = mxGetN(pInArray[0]);
 	 rowMax = m;
 	 colMax = n;
<<<<<<< .mine
     
=======
 	 
>>>>>>> .r51
     //pMatrix=malloc(rowMax*colMax*sizeof(double));
 	 //pX=malloc(rowMax*sizeof(double));
 	 pMatrix=mxMalloc(rowMax*colMax*sizeof(double));
 	 pX=mxMalloc(rowMax*sizeof(double));
 
 	 pOutArray[0] = mxCreateDoubleMatrix(rowMax, 1, mxREAL);
 	 
 	 data1 = mxGetPr(pInArray[0]);
 	 data2 = mxGetPr(pOutArray[0]);
     
 	 for(i = 0; i < rowMax; i++)
 	 {
	  	   for(j = 0; j < colMax; j++)
	  	   {
		   		pMatrix[i*colMax+j] = data1[j*rowMax+i];
		   	    printf("%lf,",data1[j*rowMax+i]);
		   		printf("%lf,",pMatrix[i*colMax+j]);
		   }
		   printf("\n");
   	 }
 	 
     gaussLesung(pMatrix, rowMax, colMax, pX);
   	 
   	// for(i = 0; i < rowMax; i++)data2[i] = pX[i];
		//outputMatrix(pX, rowMax, 1);
	 mxFree(pX);
   	 mxFree(pMatrix); 
   	 //free(pX);
   	 //free(pMatrix);
}
