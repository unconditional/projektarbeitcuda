/* matlab interface for 
__host__ void idrs(
                     t_ve* A_h,
                     t_ve* b_h,
                     unsigned int s,
                     t_ve  tol,
                     unsigned int maxit,
                     t_ve* x0_h,

                     unsigned int N,

                     t_ve* x_h,  //output vector 
                     t_ve* resvec_h,
                     unsigned int* piter
                  )
				  
				  */


#include <math.h> 
#include "mex.h"

/* Gateway function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
	int inputIdx;
	A_h;????
	t_ve *b_h,tol, *x0_h, *x_h, *resvec_h;
	unsigned int s, maxit, N, *piter;
	//=======read input===============================================================
	//read spaser Matrix A_h
	inputIdx = 0;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
    ir = mxGetIr(prhs[inputIdx]);
    jc = mxGetJc(prhs[inputIdx]);
    nzmax = mxGetNzmax(prhs[inputIdx]);
	A_h[i] = (t_ve)pr[i];
	=ir[i];
	=jc[i];
	//read b_h
	inputIdx = 1;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	b_h = (t_ve*)mxMalloc(sizeof(t_ve)*m*n);
	for()
	
	//read s
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
	 
	//read N
	inputIdx = 5;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	N = (unsigned int)pr[0];
	
	//
	x_h = (t_ve*)mxMalloc(sizeof(t_ve)*m*n)?????
	resvec_h = (t_ve*)mxMalloc(sizeof(t_ve)*m*n) ???
	piter = (unsigned int *)mxMalloc(sizeof(unsigned int)*m*n)????
	//
	idrs(A_h,b_h,s,tol,maxit,N,x_h,resvec_h,piter);
	//=======================================================================
	//output x_h
    plhs[0] = mxCreateDoubleMatrix(......,1,mxREAL);
	pr = mxGetPr(plhs[0]);
	for(i = 0; i < max...; i++){
		pr[i] = (double)x_h;
	}
	//output resvec_h
    plhs[1] = mxCreateDoubleMatrix(......,1,mxREAL);
	pr = mxGetPr(plhs[1]);
	for(i = 0; i < max...; i++){
		pr[i] = (double)resvec_h;
	}
	//output iter
	plhs[2] = mxCreateNumericMatrix(......,1,mxUINT32_CLASS,mxREAL);
	pr = mxGetPr(plhs[1]);
	for(i = 0; i < max...; i++){
		pr[i] = piter[i];
	}
	
	
	//=======================================================================
	
	
	
}