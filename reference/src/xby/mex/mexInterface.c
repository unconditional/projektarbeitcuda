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
     for (i = 0; i < nrhs; i++){
        /* Find the dimensions of the data */
        m = mxGetM(prhs[i]);
        n = mxGetN(prhs[i]);  
        pMatrix = mxGetPr(prhs[i]); 
        pIn = (float*)mxMalloc(sizeof(float)*m*n);       
        for(k=0; k < m*n; k++){
            pIn[k] = (float)pMatrix[k];
            printf("%f \n",pIn[k]);
        }
        mxFree(pIn);
     }  
}
