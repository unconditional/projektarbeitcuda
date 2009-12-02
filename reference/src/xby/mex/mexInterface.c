#include "mex.h"
//typedef NULL 0;
typedef struct DataTable{
       float * pBody; 
       struct DataTable * pHead;
       struct DataTable * pTail;
} ;

void freeDataTable(struct DataTable * pTable){
     pTable->pTail = NULL;
     pTable->pHead = NULL;
     free(pTable->pBody);
     free(pTable);
}

void freeTable(struct DataTable * pTable){
     struct DataTable * pData;
     pData = NULL;
     if(pTable->pTail != NULL){
        pData = pTable->pTail;
        freeTable(pTable);
     }else {
            pData = pTable;
            if(pData->pHead!=NULL){
               pData = pData->pHead;
               freeDataTable(pData->pTail);
               pData->pTail=NULL;
               freeTable(pData);
           }

           return;
     }
}

/* Gateway function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
     int inputArgNum = nrhs;
     int outputArgNum = nlhs;
     int i,j,k,m, n;
     double *pMatrix;
     float * pIn;  
     float ** ppIn;
     int *pmIn;
     int *pnIn;
     pnIn = (int*)mxMalloc(sizeof(int)*nrhs);
     pmIn = (int*)mxMalloc(sizeof(int)*nrhs);
     ppIn = (float**)mxMalloc(sizeof(float*)*nrhs);
     printf("nrhs = %d \n",nrhs);
     for (i = 0; i < nrhs; i++){
        /* Find the dimensions of the data */
        m = mxGetM(prhs[i]);
        n = mxGetN(prhs[i]);
        printf("m = %d , n= %d \n",m,n);
        pmIn[i] = (int)m;
        pnIn[i] = (int)n;
        pMatrix = mxGetPr(prhs[i]); 
        pIn = (float*)mxMalloc(sizeof(float)*m*n);       
        ppIn[i]=pIn;
        
        for( k = 0; k < m; k++)
            for( j = 0; j < n; j++){
                pIn[k*n+j] = (float)pMatrix[j*m+k];
            }
        for(k=0; k < m*n; k++){
            //pIn[k] = (float)pMatrix[k];
            printf("%f \n",pIn[k]);
        }
        //mxFree(pIn);
     }
     for (i = 0; i < nrhs; i++){
        pIn=ppIn[i];
        printf("m = %d , n= %d \n",pmIn[i],pnIn[i]);
        for(j = 0; j < pnIn[i]*pmIn[i]; j++)printf("%f ,",pIn[j]);
        printf("\n");
        mxFree(pIn);
     }
     
     mxFree(pnIn);
     mxFree(pmIn);
     mxFree(ppIn);
}
