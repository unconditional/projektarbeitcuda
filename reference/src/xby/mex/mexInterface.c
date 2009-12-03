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
// the last input argument should the type of call function 
// type: 0 for dotMul, 1 for norm, 3 for matrixMul

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
     int inputArgNum = nrhs;
     int outputArgNum = nlhs;
	 //define number of outputs 
	 int retNum;
     int i,j,k,m, n;
	 double *pOut;
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
		//get data from input
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
	 ///output
	 
	 if(nrhs > 0){
		pMatrix = mxGetPr(prhs[nrhs-1]);
		//m = mxGetM(prhs[nrhs-1]);
        //n = mxGetN(prhs[nrhs-1]);
		retNum = (int)pMatrix[0];
		plhs[0] = mxCreateDoubleMatrix(retNum,1,mxREAL);
		pOut = mxGetPr(plhs[0]);
		for (i = 0; i < retNum; i++) pOut[i] = 365 + i;
	 }
	 
	 	 
	 /*
	 //if(nlhs!=0){
		plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
		pOut = mxGetPr(plhs[0]);
		pOut[0] = 365;
		plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
		pOut = mxGetPr(plhs[1]);
		pOut[0] = 366;
	 //}
	 */
	 
	 
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
