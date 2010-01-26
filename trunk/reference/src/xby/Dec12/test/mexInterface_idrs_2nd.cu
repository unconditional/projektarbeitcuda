/* matlab interface for 
__host__ void idrs(
                     SparseMatrix A, // size NxN
                     t_ve* b, // size N
                     unsigned int s,
                     t_ve  tol, // t_ve scalar 
                     unsigned int maxit, //int scalar
                     t_ve* x0, //size N

                     unsigned int N, //vector and matrix size

                     t_ve* x,  // output vector of size N
                     t_ve* resvec, // output vector of size ??????
                     unsigned int* piter //output int point 
                  );
	idrs2nd(
			t_fullMatrix P,
			t_ve tol,
			unsigned int s,
			unsigned int maxit,
			t_idrshandle  ih_in,
			
			t_ve* x,  // output vector of size N
            t_ve* resvec, // output vector of size ??????
            unsigned int* piter //output int point 
	)
				  */


#include <math.h> 
#include "mex.h"
#include "..\\gpu\\projektcuda.h"

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
	t_fullMatrix P;
	t_ve tol, *x0, *x, *resvec;
	unsigned int  maxit, N, *piter;
    unsigned int m,n;
    //unsigned int nzmax;
    //int *ir,*jc,i;
	int i;
    //unsigned int *irs,*jcs;
    //int cmplx,isfull;
    double *pr,*pi;//,*si,*sr;
    int size_resvec;
	int msize ;
	//void *devicemem;
	if( nrhs < 5 ) {
		printf("not enough input argument!\n");
		printf("[x,resvec,iter]=mexInterface_idrs_2nd(P, tol, s, maxit, ih_in);\n");
		return;
	}
    //=======read input===============================================================
	//read Matrix P
	printf("read  Matrix P!\n");
	inputIdx = 0;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);	
	// inupt matrix rotate
	P.m = m;
	P.n = n;
	msize = P.m*P.n;
	N = P.m; ///N is the size of Vector or m of P
	for(i = 0; i < msize; i++){
        P.pElement[i] =(t_ve)pr[i];
    }
	
	//read tol
	inputIdx = 1;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	tol = (unsigned int)pr[0];
	 
	//read s
	inputIdx = 2;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	s = (unsigned int)pr[0];
	//read maxit
	inputIdx = 3;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	maxit = (unsigned int)pr[0];
	
	//read ih_in
	inputIdx = 4;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	ih_in = pr[0];	
	
	
	printf("create output!\n");
	//create output vector x of size N
	x = (t_ve*)mxMalloc(sizeof(t_ve)*N);
	//create output vector resvec, size ??????
	resvec = (t_ve*)mxMalloc(sizeof(t_ve)*m*n); 
	//output piter
	piter = (unsigned int *)mxMalloc(sizeof(unsigned int)*1);
	//=======================================================================
	//call idrs interface 
	
	//idrs2(P, tol, s, maxit,ih_in, t_ve* x, resvec, piter );
	
	//=======================================================================
	//output x, resvec,piter in matlab
	outputIdx = 0;
    plhs[outputIdx] = mxCreateDoubleMatrix(N,1,mxREAL);
	pr = mxGetPr(plhs[outputIdx]);
	for(i = 0; i < N; i++){
		pr[i] = (double)x[i];
	}
	//output resvec
	outputIdx = 1;
    size_resvec =10;
    plhs[outputIdx] = mxCreateDoubleMatrix(size_resvec,1,mxREAL);
	pr = mxGetPr(plhs[outputIdx]);
	for(i = 0; i < size_resvec; i++){
		pr[i] = (double)resvec[i];
	}
	//output iter of scalar value
	outputIdx =2;
	plhs[outputIdx] = mxCreateNumericMatrix(1,1,mxUINT32_CLASS,mxREAL);
	pr = mxGetPr(plhs[outputIdx]);
	for(i = 0; i < 1; i++){
		pr[i] = piter[i];
	}
	//=======================================================================

	mxFree(x);
	mxFree(resvec);
	mxFree(piter);

	
	
}