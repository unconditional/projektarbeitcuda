/* matlab interface for 

				  */


#include <math.h> 
#include "mex.h"

typedef unsigned int t_mindex;
typedef float t_ve;

typedef struct SparseMatrix{
    t_mindex m;
    t_mindex n;
    t_mindex nzmax;
	//size m+1
    t_mindex *pRow;
    //size nzmax
	t_mindex *pCol;
	//size : nzmax
    t_ve* pNZElement;
} t_SparseMatrix;

int smat_size( int count_nzmax, int cunt_rows ) {

    return   ( sizeof(t_ve) + sizeof(t_mindex) ) * count_nzmax
           + sizeof(t_mindex)  * (cunt_rows + 1);
}

// ---------------------------------------------------------------------
 void set_sparse_data( t_SparseMatrix* m, void* mv ) {

   m->pCol = (t_mindex *) mv;
   m->pNZElement = (t_ve *) (&m->pCol[m->nzmax] ) ;
   m->pRow = (t_mindex *) (&m->pNZElement[m->nzmax]);

}
/* Gateway function */
//[x,resvec,iter]=mexInterface_idrs(A,b,s,tol,maxit,x0);
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
	int inputIdx;
	t_SparseMatrix A;
	t_ve *b,tol, *x0, *x, *resvec;
	unsigned int s, maxit, N, *piter;
    unsigned int m,n;
    unsigned int nzmax;
    int *ir,*jc,i;
    //unsigned int *irs,*jcs;
    //int cmplx,isfull;
    double *pr,*pi;//,*si,*sr;
    int size_resvec;
	int msize ;
	void *devicemem;
    //=======read input===============================================================
	//read spaser Matrix A
	printf("read spaser Matrix A!\n");
	inputIdx = 0;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
    ir = mxGetIr(prhs[inputIdx]);
    jc = mxGetJc(prhs[inputIdx]);
    nzmax = mxGetNzmax(prhs[inputIdx]);
	
	// inupt matrix rotate
	A.m = n;
	A.n = m;
	A.nzmax = nzmax;
	msize = smat_size( A.nzmax, A.n );
	
	devicemem = mxMalloc ( msize );
	set_sparse_data(&A, devicemem);
	printf("ir0 = %d, pr0 = %lf\n",ir[0],pr[0]);
	for(i = 0; i < nzmax; i++){
        A.pNZElement[i] =(t_ve)pr[i];
        A.pCol[i] = ir[i];
		printf("ir = %d, pr = %lf\n",ir[i],pr[i]);
    }
    for(i = 0; i < n+1; i++){  
        A.pRow[i] = jc[i];
		
    }

	//read b size of N = m*n
	printf("read Vector b!\n");
	inputIdx = 1;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	b = (t_ve*)mxMalloc(sizeof(t_ve)*m*n);
	for(i = 0; i < m*n; i++){
		b[i] = (t_ve)pr[i];
	}
	
	//read s
	printf("read s!\n");
	inputIdx = 2;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	s = (unsigned int)pr[0];
	
	//read tol
	inputIdx = 3;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	tol = (unsigned int)pr[0];
	 
	//read maxit
	inputIdx = 4;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	maxit = (unsigned int)pr[0];
	
	//read x0 size of N = m*n
	inputIdx = 5;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
    x0 = (t_ve*)mxMalloc(sizeof(t_ve)*m*n);
	for(i = 0; i < m*n; i++){
		x0[i] = (t_ve)pr[i];
	}
	//read N
	inputIdx = 6;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	N = (unsigned int)pr[0];
	
	 printf("create output!\n");

	
	//create output vector x of size N
	x = (t_ve*)mxMalloc(sizeof(t_ve)*N);
	//create output vector resvec, size ??????
	resvec = (t_ve*)mxMalloc(sizeof(t_ve)*m*n); 
	//output piter
	piter = (unsigned int *)mxMalloc(sizeof(unsigned int)*1);
	//=======================================================================
	//call idrs interface 
	//idrs(A,b,s,tol,maxit,x0,N,x,resvec,piter);
	
	/*
	extern "C" void idrswhole(
    t_SparseMatrix A_in,    // A Matrix in buyu-sparse-format 
    t_ve*          b_in,    // b as in A * b = x 
    t_mindex s,
    t_ve tol,
    t_mindex maxit,
    t_ve*          x0_in,

    t_mindex N,

    t_ve* x_out,
    t_ve* resvec_out,
    unsigned int* piter
	);
	*/
	//=======================================================================
	//output x, resvec,piter in matlab
	int outPutIdx;
	//x
	outPutIdx = 0;
    plhs[outPutIdx] = mxCreateDoubleMatrix(N,1,mxREAL);
	pr = mxGetPr(plhs[outPutIdx]);
	for(i = 0; i < N; i++){
		pr[i] = (double)x[i];
	}
	//output resvec
	outPutIdx = 1;
    size_resvec =10;
    plhs[outPutIdx] = mxCreateDoubleMatrix(size_resvec,1,mxREAL);
	pr = mxGetPr(plhs[outPutIdx]);
	for(i = 0; i < size_resvec; i++){
		pr[i] = (double)resvec[i];
	}
	//output iter of scalar value
	outPutIdx = 2;
	//plhs[outPutIdx] = mxCreateNumericMatrix(1,1,mxUINT32_CLASS,mxREAL);
	plhs[outPutIdx] = mxCreateDoubleMatrix(1,1,mxREAL);
	pr = mxGetPr(plhs[outPutIdx]);
	for(i = 0; i < 1; i++){
		pr[i] = piter[i];
	}
	//=======================================================================
	mxFree(b);
	mxFree(x);
	mxFree(resvec);
	mxFree(piter);
	mxFree(devicemem);
	
	
}