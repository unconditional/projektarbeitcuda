#include <stdio.h>
#include "matrixMul.h"
void initHostMatrix(float **phA,float **phB,float **phC)
{
     //float *h_A,*h_B,*h_C;
     int i = 0;
     float *hA,*hB,*hC;
     unsigned int size_A = WA*HA;
     unsigned int size_B = WB*HB;
     unsigned int size_C = WC*HC;
     
	 printf("initHostMatrix \n");
	 printf("size_A=%d,size_B=%d,size_C=%d \n",size_A,size_B,size_C);
     
     *phA=(float*)malloc(size_A*sizeof(float));
     *phB=(float*)malloc(size_B*sizeof(float));
     *phC=(float*)malloc(size_C*sizeof(float));
     
	 hA=*phA;
     hB=*phB;
     hC=*phC;
     
	 printf("finish malloc \n");
     
	 for(i=0;i<size_A;i++)
     {
	  hA[i]=1;
	  //printf("hA[%d]=%f \n",i,hA[i]);
     }
     printf("finish init A \n");
     for(i=0;i<size_B;i++)
     {
	  hB[i]=1;
	  //printf("hB[%d]=%f \n",i,hB[i]);
     }
     printf("finish init B \n");
     for(i=0;i<size_C;i++)
     {
	  
	  hC[i]=0;
	  //printf("hC[%d]=%f \n",i,hC[i]);
     }   
     printf("finish init C \n");
}
void outputMatrix(float *matrix,unsigned int size)
{	
	
 	 int i;	
 	 printf("outputMatrix \n"); 
 	 printf("size=%d \n",size);
 	 for(i = 0;i < size; i++)
 	 {
	  printf("matrix[%d]=%f \n",i,matrix[i]); 
 	 }
 	 	 
}

// there is problem by free memory 
void freeHostMatrix(float **phA,float **phB, float **phC)
{
 	 printf("freeHostMatrix \n"); 
 	 //float *hA,float *hB, float *hC
 	 int i;
   	 unsigned int size_A = WA*HA;
     unsigned int size_B = WB*HB;
     unsigned int size_C = WC*HC;

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
void freeMatrix(float *hA,float *hB, float *hC)
{
 	 printf("freeHostMatrix \n"); 
 	 //float *hA,float *hB, float *hC
 	 int i;
 	 for(i=0;i<WA*HA;i++)free(hA++);
 	 for(i=0;i<WB*HB;i++)free(hB++);
 	 for(i=0;i<WC*HC;i++)free(hC++);
 	 //free(hA);
 	 //free(hB);
 	 //free(hC);
}
