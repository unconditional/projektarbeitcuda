#include <stdio.h>


/*
  pA: the pointer of the Matrix A|b
  rowMax,colMax:size of matirx
  row: begin row
  col: working col
*/
int findMax(double *pA, int rowMax,int colMax, int row, int col)
{
    double * pMatrix = pA;
    // element pMatrix[i*colMax+j]
    // col pMatrix[i*colMatrix]~~pMatrix[(i+1)*colMatrix-1]
    double MAX = pMatrix[row*colMatrix+col];
    int l = row;
    for (i=row;i<rowMax;i++){
        if(MAX<pMatrix[i*colMatrix+col])
        {
         MAX=pMatrix[i*colMatrix+col];
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
    if(row1!=row2)
    {
     for(int i = 0; i < colMax; i++)
     {
      swap=pMatrix[row1*colMax+i];
      pMatrix[row1*colMax+i]=pMatrix[row2*colMax+i];
      pMatrix[row2*colMax+i]=swap;
     }
    }
}
/*
  pA: the pointer of the Matrix A|b
  rowMax,colMax:size of matirx
  row: begin row
  //col: working col
*/
int eliminate(double *pA, int rowMax,int colMax,int row, int col)
{
     double * pMatrix = pA;
     int i,j;
     double aii = pMatrix[row*colMax];
     if(0 == aii)return 0;
	 for(i = row+1; i < rowMax; i++)
     {
 	  	   double aji = pMatrix[i*colMax+col];  
	  	   for(j = row; j < colMax; j++)
	  	   {
	   	   		 pMatrix[i*colMax+j]-=pMatrix[row*colMax+j]*aji/aii;
	       }      
     }
     return 1;  
}
/*
  pA: the pointer of the Matrix A|b
  rowMax,colMax:size of matirx
  pX: X vector
*/
int solveX(double *pA, int rowMax,int colMax, double *pX)
{
 	double *pMatrix = pA;
 	int i,j;
 	
 	for(i = rowMax-1; i >= 0; i--)
 	{
	 	  double Sum=0;
  	 	  for(j = i+1; j < rowMax; j++)
  	 	  {
  	  	   		Sum+=pX[j]*pMatrix[i*colMax+j];
  	 	  }
  	 	  pX[i]=(pMatrix[(i+1)*colMax-1]-Sum)/pMatrix[i*colMax+i];
  	}
 	return 1;
}
