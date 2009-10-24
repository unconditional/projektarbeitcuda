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
  h_A=(float*)malloc(WA*HA*sizeof(float));
  h_B=(float*)malloc(WB*HB*sizeof(float));
  h_C=(float*)malloc(WC*HC*sizeof(float));
  initHostMatrix(&h_A,&h_B,&h_C);
  computeGold(h_C,h_A,h_B,HA,WA,WB);
  outputMatrix(h_C,WC*HC);
  freeHostMatrix(&h_A,&h_B,&h_C);
  //freeMatrix(h_A,h_B,h_C);
  int i;
  //for(i=0;i<WA*HA;i++)free(h_A++);
  printf("h_A[1] = %f \n",h_A[2]);
  printf("h_B[1] = %f \n",h_B[2]);
  printf("h_C[1] = %f \n",h_C[2]);
  
  system("PAUSE");
  return 0;
}

