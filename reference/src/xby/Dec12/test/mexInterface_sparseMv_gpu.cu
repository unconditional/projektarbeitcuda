#include <math.h> /* Needed for the ceil() prototype */
#include "mex.h"
#include "host_sparseMatrixMul01.cu"
#if defined(NAN_EQUALS_ZERO)
#define IsNonZero(d) ((d)!=0.0 || mxIsNaN(d))
#else
#define IsNonZero(d) ((d)!=0.0)
#endif
//typedef NULL 0;
typedef float t_ve;
typedef int mwIndex;


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
    printf("in calMV \n");
    for (i = 0; i < m; i++){
        colbegin = pRow[i];
        colend = pRow[i+1];
        for(j=colbegin;j<colend;j++)pResultElements[i] += pMatrixElements[j]*pVectorElements[pCol[j]];
    }  
}
/* Gateway function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    /* Declare variable */
    unsigned int m,n;
    unsigned int nzmax;
    int *ir,*jc,i;
    //unsigned int *irs,*jcs;
    //int cmplx,isfull;
    double *pr,*pi;//,*si,*sr;
    //double percent_sparse;
    //double *pMatrix;
    t_SparseMatrix sparseMatrix;
    t_SparseMatrix *pSparseMatrix ;     
    //declare Vector 
    t_FullMatrix fullVector, ResultVector;
    t_FullMatrix * pVector, *pResultVector;
    
	cudaError_t e;	
	float t_avg;
	t_avg = 0;
	
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

	
	//=========================================================================================
	

    pSparseMatrix->pNZElement = (t_ve *)mxMalloc(sizeof(t_ve)*nzmax);
    pSparseMatrix->pCol = (unsigned int*) mxMalloc(sizeof(unsigned int)*nzmax); 
    pSparseMatrix->pRow = (unsigned int*) mxMalloc(sizeof(unsigned int)*(pSparseMatrix->m+1)); 
    
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
    START_CUDA_TIMER;
	// call cpu
    calMV(pSparseMatrix, pVector, pResultVector);
    
	//call gpu
	//host_sparseMatrixMul(t_FullMatrix * pResultVector,t_SparseMatrix *pSparseMatrix, t_FullMatrix * pVector)
	//printf("call host \n");
	//host_sparseMatrixMul(pResultVector, pSparseMatrix, pVector);
    //printf("after host \n");
	STOP_CUDA_TIMER( &t_avg);
	printf("CPU runing time =%lf (ms) \n",t_avg);
	
	
	//ir = mxGetIr(prhs[0]);
    //jc = mxGetJc(prhs[0]);
    //nzmax = mxGetNzmax(prhs[0]);
    plhs[0] = mxCreateDoubleMatrix(pResultVector->m*pResultVector->n,1,mxREAL);
	pr = mxGetPr(plhs[0]);
    //for (i = 0; i<(pResultVector->m*pResultVector->n); i++)pr[i] = pResultVector->pElement[i];
    
    /* Allocate space for sparse matrix 
     * NOTE:  Assume at most 20% of the data is sparse.  Use ceil
     * to cause it to round up. 
     *Nonzero elements
     *if(jc[i]!=jc[i+1]) for(int k = jc[i]; k<jc[i+1]; k++)A[ir[k][i]=pr[k]+pi[k]
     */

       // printf("printf Result Vector \n");
       for(i=0; i < pResultVector->n*pResultVector->m; i++){  
			//copy result back to matlab;
			pr[i] = (double)pResultVector->pElement[i];
        }

        mxFree(pResultVector->pElement);
        mxFree(pVector->pElement);
        mxFree( pSparseMatrix->pNZElement);
        mxFree( pSparseMatrix->pCol);
        mxFree( pSparseMatrix->pRow);
       
   
}
