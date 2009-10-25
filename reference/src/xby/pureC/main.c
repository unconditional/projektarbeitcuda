#include <stdio.h>
#include "matrixMul.h"
//#include "matrixMul_gold.c"
//#include "extTest.c"
#define VECTORSIZE 8
long N=1000;
float *h_A,*h_B,*h_C;
//extern void computeGold( float*, const float*, const float*, unsigned int, unsigned int, unsigned int);
//void initHostMatrix();
//void freeHostMatrix();
//void outputMatrix(float* matrix,unsigned int size);
void freeMemory();
int main(int argc, char *argv[])
{
 	/*
  float * h_A,*h_B;
  long size = VECTORSIZE;
  h_B=(float*)malloc(sizeof(float));
  printf("size of A=%d,size of B= %d \n",sizeof(h_A),sizeof(*h_B));
  printf("pure c project %d \n",N);
  printf("vector size = %d \n",size);
  system("PAUSE");	
  free(h_B);
  */
  
  /*
  h_A=(float*)malloc(WA*HA*sizeof(float));
  h_B=(float*)malloc(WB*HB*sizeof(float));
  h_C=(float*)malloc(WC*HC*sizeof(float));
  */
  initHostMatrix(&h_A,&h_B,&h_C);
  computeGold(h_C,h_A,h_B,HA,WA,WB);
  outputMatrix(h_C,WC*HC);
  freeHostMatrix(&h_A,&h_B,&h_C);
  //freeMatrix(h_A,h_B,h_C);
  //freeMemory();
  int i;
  //for(i=0;i<WA*HA;i++)free(h_A++);
  //for(i=0;i<WB*HB;i++)free(h_B++);
  //for(i=0;i<WC*HC;i++)free(h_C++);
  printf("h_A[1] = %f \n",h_A[5]);
  printf("h_B[1] = %f \n",h_B[5]);
  printf("h_C[1] = %f \n",h_C[5]);
  
  system("PAUSE");
  return 0;
}
void freeMemory()
{
 	 printf("freeHostMatrix \n"); 
 	 //float *hA,float *hB, float *hC
 	 int i;
   	 unsigned int size_A = WA*HA;
     unsigned int size_B = WB*HB;
     unsigned int size_C = WC*HC;
	 float **phA;
	 float **phB;
	 float **phC;
	 phA=&h_A;
	 phB=&h_B;
	 phC=&h_C;
   	 for(i=0;i<size_A;i++)
     {
	  free((*phA)++);	  
     }
     printf("finish init A \n");
     for(i=0;i<size_B;i++)
     {
	  free((*phB)++);
	  //printf("hB[%d]=%f \n",i,hB[i]);
     }
     printf("finish init B \n");
     for(i=0;i<size_C;i++)
     {
	  free((*phC)++);
	  //printf("hC[%d]=%f \n",i,hC[i]);
     }
}
