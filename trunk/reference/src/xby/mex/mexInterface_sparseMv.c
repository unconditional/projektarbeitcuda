#include <math.h> /* Needed for the ceil() prototype */
#include "mex.h"
#if defined(NAN_EQUALS_ZERO)
#define IsNonZero(d) ((d)!=0.0 || mxIsNaN(d))
#else
#define IsNonZero(d) ((d)!=0.0)
#endif
//typedef NULL 0;
typedef float t_ve;
typedef unsigned int mwSize;
typedef int mwIndex;

typedef struct DataTable{
       float * pBody; 
       struct DataTable * pHead;
       struct DataTable * pTail;
} aDataTable;

void freeDataTable( aDataTable * pTable){
     pTable->pTail = NULL;
     pTable->pHead = NULL;
     free(pTable->pBody);
     free(pTable);
}

void freeTable( aDataTable * pTable){
     aDataTable * pData;
     aDataTable * pData1=0;
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

typedef struct Matrix{
    unsigned int m;
    unsigned int n;
    t_ve* pElement;
} t_Matix;

typedef struct SparseMatrix{
    unsigned int m;
    unsigned int n;
    unsigned int nzmax;
    unsigned int *pRow;
    unsigned int *pCol;
    t_ve* pNZElement;
} t_SparseMatrix;

void initElement(t_Matix * pMatrix)
{
    int i;
    if (pMatrix != 0)
        for (i = 0; i < (pMatrix->m)*(pMatrix->n); i++){
            pMatrix->pElement[i] = 0;  
        }
}
void setElement(t_Matix * pMatrix, unsigned int row, unsigned int col, float val)
{
    if((row < pMatrix->m)&&(col < pMatrix->n)){
        printf("row=%d,col=%d,val=%lf,\n",row,col, val);
        pMatrix->pElement[(row)*(pMatrix->n) + col ] = val;
    }
}
/* Gateway function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    /* Declare variable */
    mwSize m,n;
    mwSize nzmax;
    mwIndex *ir,*jc;
    mwIndex *irs,*jcs,i;
    int cmplx,isfull;
    double *pr,*pi,*si,*sr;
    double percent_sparse;
    
     //double *pMatrix;
     t_SparseMatrix sparseMatrix;
     t_SparseMatrix *pSparseMatrix ; 
     pSparseMatrix = &sparseMatrix; 
     
    /* Check for proper number of input and output arguments */    
    if (nrhs < 2) {
	mexErrMsgTxt("Two input argument required. First Sparse Matrix, Second Vector");
    } 
    if(nlhs > 1){
	mexErrMsgTxt("Too many output arguments.");
    }
     
    if (mxGetNumberOfDimensions(prhs[0]) != 2){
	mexErrMsgTxt("Input argument must be two dimensional\n");
    } 
     
     
    /* Get the size and pointers to input data */
     
    //====get SparseMatrix============================================
    m  = mxGetM(prhs[0]);
    n  = mxGetN(prhs[0]);
    pr = mxGetPr(prhs[0]);
    pi = mxGetPi(prhs[0]);
    ir = mxGetIr(prhs[0]);
    jc = mxGetJc(prhs[0]);
    nzmax = mxGetNzmax(prhs[0]);
    //in c exchange m and n
    pSparseMatrix->m = n;
    pSparseMatrix->n = m;
    pSparseMatrix->nzmax = nzmax;
    printf("m=%d,n=%d,nzmax=%d, \n",m,n,nzmax);
    cmplx = (pi==NULL ? 0 : 1);
    pSparseMatrix->pNZElement = (t_ve *)mxMalloc(sizeof(t_ve)*nzmax);
    pSparseMatrix->pCol = (unsigned int*) mxMalloc(sizeof(unsigned int)*nzmax); 
    pSparseMatrix->pRow = (unsigned int*) mxMalloc(sizeof(unsigned int)*(n+1)); 
    for(i = 0; i < nzmax; i++){
        pSparseMatrix->pNZElement[i] =(t_ve) pr[i];
        pSparseMatrix->pCol[i] = ir[i];
    }
    for(i = 0; i < n+1; i++){  
        pSparseMatrix->pRow[i] = jc[i];
    }
    
    //=====get Vector==========================================================
    t_Matix Vector;
    t_Matix * pVector;
    pVector = &Vector;
    m  = mxGetM(prhs[1]);
    n  = mxGetN(prhs[1]);
    pr = mxGetPr(prhs[1]);
    pi = mxGetPi(prhs[1]);
    pVector->m=m;
    pVector->n=n;
    //ir = mxGetIr(prhs[0]);
    //jc = mxGetJc(prhs[0]);
    //nzmax = mxGetNzmax(prhs[0]);
    
    /* Allocate space for sparse matrix 
     * NOTE:  Assume at most 20% of the data is sparse.  Use ceil
     * to cause it to round up. 
     *
     *
     *
     *Nonzero elements
     *if(jc[i]!=jc[i+1]) for(int k = jc[i]; k<jc[i+1]; k++)A[ir[k][i]=pr[k]+pi[k]
     */
    /*
    percent_sparse = 0.2;
    nzmax=(mwSize)ceil((double)m*(double)n*percent_sparse);

    plhs[0] = mxCreateSparse(m,n,nzmax,cmplx);
    sr  = mxGetPr(plhs[0]);
    si  = mxGetPi(plhs[0]);
    irs = mxGetIr(plhs[0]);
    jcs = mxGetJc(plhs[0]);
    
    */
    
  
    /* Find the dimensions of the data */
        //pMatrix = mxGetPr(prhs[i]); 
       
        /*
        for(k=0; k < nzmax; k++){
            printf("ir[%d]=%d \n",k,ir[k]);

        }
        for(k=0; k < n+1; k++){
    
            printf("jc[%d]=%d \n",k,jc[k]);
        }
       */

        
        printf("printf full matrix \n");
        for(i=0; i < nzmax; i++){     
            printf("%f,k=%d ",pSparseMatrix->pNZElement[i],i);
            printf("%f \n");
        }
        /*
        for(k=0; k < m*n; k++){
            pIn[k] = (t_ve)pr[k];
            printf("%f \n",pIn[k]);
        }
         */
        mxFree( pSparseMatrix->pNZElement);
        mxFree( pSparseMatrix->pCol);
        mxFree( pSparseMatrix->pRow);
       
   
}
