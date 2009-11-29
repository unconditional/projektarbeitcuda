#include <math.h> /* Needed for the ceil() prototype */
#include "mex.h"
#if defined(NAN_EQUALS_ZERO)
#define IsNonZero(d) ((d)!=0.0 || mxIsNaN(d))
#else
#define IsNonZero(d) ((d)!=0.0)
#endif
//typedef NULL 0;
typedef float t_ve;

typedef struct DataTable{
       float * pBody; 
       struct DataTable * pHead;
       struct DataTable * pTail;
}mDataTable;

void freeDataTable(struct DataTable * pTable){
     pTable->pTail = NULL;
     pTable->pHead = NULL;
     free(pTable->pBody);
     free(pTable);
}

void freeTable(struct DataTable * pTable){
     mDataTable * pData;
     mDataTable * pData1=0;
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

typedef struct {
    unsigned int m = 0;
    unsigned int n = 0;
    t_ve* pElement = 0;

} t_Matix;
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
    if((row < pMatrix->m)&&(col < pMatrix->n){
        pMatrix->pElement[(row-1)*(pMatrix->n) + col -1] = val;
    }
}
/* Gateway function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    /* Declare variable */
    mwSize m,n;
    mwSize nzmax;
    mwIndex *ir,*jc;
    mwIndex *irs,*jcs,i,j,k;
    int cmplx,isfull;
    double *pr,*pi,*si,*sr;
    double percent_sparse;
    
     double *pMatrix;
     t_Matix *pFullMatrix = (t_Matix)malloc(sizeof(t_Matix));
     t_ve * pIn;       
    /* Get the size and pointers to input data */
    m  = mxGetM(prhs[0]);
    n  = mxGetN(prhs[0]);
    pr = mxGetPr(prhs[0]);
    pi = mxGetPi(prhs[0]);
    ir = mxGetIr(prhs[0]);
    jc = mxGetJc(prhs[0]);
    nzmax = mxGetNzmax(prhs[0]);
    pFullMatrix->m = m;
    pFullMatrix->n = n;
    
    cmplx = (pi==NULL ? 0 : 1);

    
    /* Allocate space for sparse matrix 
     * NOTE:  Assume at most 20% of the data is sparse.  Use ceil
     * to cause it to round up. 
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
    
     /* Check for proper number of input and output arguments */    
    if (nrhs != 1) {
	mexErrMsgTxt("One input argument required.");
    } 
    if(nlhs > 1){
	mexErrMsgTxt("Too many output arguments.");
    }
     
    if (mxGetNumberOfDimensions(prhs[0]) != 2){
	mexErrMsgTxt("Input argument must be two dimensional\n");
    }
        /* Find the dimensions of the data */
       
        //pMatrix = mxGetPr(prhs[i]); 
        pIn = (t_ve*)mxMalloc(sizeof(t_ve)*m*n);
        pFullMatrix->pElement = pIn;
        initElement(pFullMatrix);
        
        for(k=0; k < nzmax; k++){
            printf("ir[%d]=%d \n",k,ir[k]);

        }
        for(k=0; k < n+1; k++){
    
            printf("jc[%d]=%d \n",k,jc[k]);
        }
        /*
         //setElement(pFullMatrix,)
        for(i = 0; i < n; i++){
            if(jc[i]!=jc[i+1])
            for( k = jc[i] ; k < jc[i+1] ; i++){
                setElement(pFullMatrix,ir[k],i,pr[k]);
            }
        }
        */
        for(k=0; k < m*n; k++){
           
            pIn[k] = (t_ve)pr[k];
            printf("%f \n",pIn[k]);
        }
        mxFree(pIn);
        free(pFullMatrix);
   
}
