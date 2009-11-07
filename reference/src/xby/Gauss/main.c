#include <stdio.h>
#include <stdlib.h>
void callMatrix();

int main(int argc, char *argv[])
{ 	
  callMatrix(); 
  system("PAUSE");	
  return 0;
}
void callMatrix()
{
 int rowMax = 3;
 int colMax = 4;
 int i;
 double *pMatrix=malloc(rowMax*colMax*sizeof(double));
 for(i = 0; i < rowMax*colMax; i++)pMatrix[i]=0; 	 
 pMatrix[0]=1;
 pMatrix[1]=2;
 pMatrix[2]=3;
 pMatrix[3]=14;
 pMatrix[4]=1;
 pMatrix[5]=1;
 pMatrix[6]=1;
 pMatrix[7]=6;
 pMatrix[8]=2;
 pMatrix[9]=1;
 pMatrix[10]=1;
 pMatrix[11]=7;
  double *pX=malloc(rowMax*sizeof(double));
 /*
 for(i = 0; i < rowMax; i++)
 {
  	   int l;
 	   printf("%d,\n",i);
 	   l = findMax(pMatrix, rowMax, colMax, i,i);
 	   exchangeRow(pMatrix, rowMax, colMax, l, i);
 	   eliminate(pMatrix, rowMax, colMax, i, i);
       outputMatrix(pMatrix, rowMax, colMax);
 }
 

 solveX(pMatrix, rowMax,colMax, pX);
 */
   gaussLesung(pMatrix, rowMax, colMax, pX);
   outputMatrix(pX, rowMax, 1);
   free(pX);
   free(pMatrix);
	  
}

