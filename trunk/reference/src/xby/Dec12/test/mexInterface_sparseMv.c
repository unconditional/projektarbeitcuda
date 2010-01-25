#include <math.h> /* Needed for the ceil() prototype */
#include "mex.h"
#if defined(NAN_EQUALS_ZERO)
#define IsNonZero(d) ((d)!=0.0 || mxIsNaN(d))
#else
#define IsNonZero(d) ((d)!=0.0)
#endif
//typedef NULL 0;
#define BASIC_DEBUG 1
#define EXTRA_DEBUG 2
#define SUPER_DEBUG 4
typedef float t_ve;
typedef unsigned int mwSize;
typedef int mwIndex;

typedef struct Matrix{
    unsigned int m;
    unsigned int n;
    t_ve* pElement;
} t_FullMatrix;
//} t_Matrix;

typedef struct SparseMatrix{
    unsigned int m;
    unsigned int n;
    unsigned int nzmax;
    unsigned int *pRow;
    unsigned int *pCol;
    t_ve* pNZElement;
} t_SparseMatrix;

void initElement(t_FullMatrix * pMatrix)
{
    int i;
    if (pMatrix != 0)
        for (i = 0; i < (pMatrix->m)*(pMatrix->n); i++){
            pMatrix->pElement[i] = 0;  
        }
}
void setElement(t_FullMatrix * pMatrix, unsigned int row, unsigned int col, float val)
{
    if((row < pMatrix->m)&&(col < pMatrix->n)){
        printf("row=%d,col=%d,val=%lf,\n",row,col, val);
        pMatrix->pElement[(row)*(pMatrix->n) + col ] = val;
    }
}
void calMV(t_SparseMatrix *pSparseMatrix, t_FullMatrix * pVector,t_FullMatrix * pResultVector)
{
    t_ve *pMatrixElements, *pVectorElements, *pResultElements;
    unsigned int m, n, i, j;
    unsigned int *pRow, *pCol;
    int colbegin, colend;
    pMatrixElements = pSparseMatrix->pNZElement;
    pVectorElements = pVector->pElement;
    pResultElements = pResultVector->pElement;
    m = pSparseMatrix->m;
    n = pSparseMatrix->n;
    //==check size of Arguments========================================================
    if(m != pResultVector->m*(pResultVector->n)){
        printf("Result Vector does not match the Matrix\n");
        return;
    }   
    if(n != pVector->m*(pVector->n)){
        printf("input Vector does not match the Matrix\n");
        return;
    }
    pRow = pSparseMatrix->pRow;
    pCol = pSparseMatrix->pCol;
    //cal
#if(DEBUG & BASIC_DEBUG)    
    printf("in calMV \n");
#endif
    for (i = 0; i < m; i++){
        colbegin = pRow[i];
        colend = pRow[i+1];
        printf("colbegin = %d \n",colbegin);
        printf("colend = %d \n",colend);
        for(j=colbegin;j<colend;j++)pResultElements[i] += pMatrixElements[j]*pVectorElements[pCol[j]];
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
    //declare Vector 
    t_FullMatrix fullVector, ResultVector;
    t_FullMatrix * pVector, *pResultVector;
    
    pSparseMatrix = &sparseMatrix; 
    pVector = &fullVector;
    pResultVector = &ResultVector;
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
    //prepare MV caculation
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
 //   t_Matrix fullVector;
 //   t_Matrix * pVector;

    m  = mxGetM(prhs[1]);
    n  = mxGetN(prhs[1]);
    pr = mxGetPr(prhs[1]);
    pi = mxGetPi(prhs[1]);
    pVector->m=m;
    pVector->n=n;
    if (!((m == 1)||(n==1))){
        mexErrMsgTxt("Second Argument must be Vector! \n");
    } 
    pVector->pElement = (t_ve*)mxMalloc(sizeof(t_ve)*m*n);
    for(i = 0; i < m*n; i++) pVector->pElement[i] = pr[i];
    //====create Result Vector==================================================================
    pResultVector->m = pSparseMatrix->m; 
    pResultVector->n = 1;
    pResultVector->pElement = (t_ve*)mxMalloc(sizeof(t_ve)*m*n);
    initElement(pResultVector);
    //======================================================================================
    // call cpu
    calMV(pSparseMatrix, pVector, pResultVector);
    
	//call gpu
	//host_sparseMatrixMul(t_FullMatrix * pResultVector,t_SparseMatrix *pSparseMatrix, t_FullMatrix * pVector)
	//host_sparseMatrixMul(pResultVector, pSparseMatrix, pVector);
    
	//ir = mxGetIr(prhs[0]);
    //jc = mxGetJc(prhs[0]);
    //nzmax = mxGetNzmax(prhs[0]);
    plhs[0] = mxCreateDoubleMatrix(pResultVector->m*pResultVector->n,1,mxREAL);
	pr = mxGetPr(plhs[0]);
    for (i = 0; i<(pResultVector->m*pResultVector->n); i++)pr[i] = pResultVector->pElement[i];
    
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
    #ifdef DEBUG  
        printf("printf Sparse matrix \n");
        for(i=0; i < pSparseMatrix->nzmax; i++){     
            printf("%f,k=%d ",pSparseMatrix->pNZElement[i],i);
            printf(" \n");
        }
         printf("printf Vector \n");
         for(i=0; i < pVector->n*pVector->m; i++){     
             printf("%f,i=%d ",pVector->pElement[i],i);
             printf("\n");
         }
    #endif
        printf("printf Result Vector \n");
       for(i=0; i < pResultVector->n*pResultVector->m; i++){     
            printf("%f,i=%d ",pResultVector->pElement[i],i);
            printf("\n");
        }
        /*
        for(k=0; k < m*n; k++){
            pIn[k] = (t_ve)pr[k];
            printf("%f \n",pIn[k]);
        }
         */
        mxFree(pResultVector->pElement);
        mxFree(pVector->pElement);
        mxFree( pSparseMatrix->pNZElement);
        mxFree( pSparseMatrix->pCol);
        mxFree( pSparseMatrix->pRow);
       
   
}
