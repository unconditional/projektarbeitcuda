/* matlab interface for 

	idrs2nd(
			t_FullMatrix P,
			t_ve tol,
			unsigned int s,
			unsigned int maxit,
			t_idrshandle  ih_in,
			
			t_ve* x,  // output vector of size N
            t_ve* resvec, // output vector of size ??????
            unsigned int* piter //output int point 
	)

);
*/

#include <math.h> 
#include "mex.h"
#include "..\\gpu\\projektcuda.h"



/* Gateway function */
//[x,resvec,iter]=mexInterface_idrs_2nd(P, tol, s, maxit, ih_in);
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{

	int inputIdx, outputIdx;
	t_ve tol;
	t_ve *x0, *x, *resvec;
	t_mindex  maxit, N, *piter;
    t_mindex m,n;
	t_SparseMatrix A;
	//struct FullMatrix P_in;
	t_FullMatrix P_in;
	int i, s,ih_in;
    double *pr,*pi;
    int size_resvec;
	int msize ;
	//void *devicemem;
	if( nrhs < 5 ) {
		printf("not enough input argument!\n");
		printf("[x,resvec,iter]=mexInterface_idrs_2nd(P, tol, s, maxit, ih_in);\n");
		return;
	}
    //=======read input===============================================================
	//read Matrix P_in
	printf("read  Matrix P!\n");
	inputIdx = 0;
	//printf("inputIdx=%d\n",inputIdx);
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);	
	// inupt matrix rotate
	P_in.m = m;
	P_in.n = n;
	msize = P_in.m*P_in.n;
	N = P_in.m; ///N is the size of Vector or m of P
	//printf("N=%d\n",N);
	P_in.pElement = (t_ve*)mxMalloc(sizeof(t_ve)*msize);
	for(i = 0; i < msize; i++){
        P_in.pElement[i] =(t_ve)pr[i];
    }
	
	//read tol
	inputIdx = 1;
	//printf("inputIdx=%d\n",inputIdx);
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	tol = (unsigned int)pr[0];
	 
	//read s
	inputIdx = 2;
	//printf("inputIdx=%d\n",inputIdx);
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	s = (unsigned int)pr[0];
	//read maxit
	inputIdx = 3;
	//printf("inputIdx=%d\n",inputIdx);
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	maxit = (unsigned int)pr[0];
	
	//read ih_in
	inputIdx = 4;
	//printf("inputIdx=%d\n",inputIdx);
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	ih_in = pr[0];	
	
	
	printf("create output!\n");
	//create output vector x of size N
	x = (t_ve*)mxMalloc(sizeof(t_ve)*N);
	//create output vector resvec, size ??????
	resvec = (t_ve*)mxMalloc(sizeof(t_ve)*N); 
	//output piter
	piter = (unsigned int *)mxMalloc(sizeof(unsigned int)*1);
	//=======================================================================
	//call idrs interface 
	
	//idrs2(P_in, tol, s, maxit,ih_in, t_ve* x, resvec, piter );
	
	//=======================================================================
	//output x, resvec,piter in matlab
	outputIdx = 0;
	//printf("outputIdx=%d\n",outputIdx);
    plhs[outputIdx] = mxCreateDoubleMatrix(N,1,mxREAL);
	pr = mxGetPr(plhs[outputIdx]);
	for(i = 0; i < N; i++){
		//x[i]=1;
		pr[i] = (double)x[i];
	}
	//output resvec
	outputIdx = 1;
	//printf("outputIdx=%d\n",outputIdx);
    size_resvec = N;
    plhs[outputIdx] = mxCreateDoubleMatrix(size_resvec,1,mxREAL);
	pr = mxGetPr(plhs[outputIdx]);
	for(i = 0; i < size_resvec; i++){
		//resvec[i]=2;
		pr[i] = (double)resvec[i];
	}
	//output iter of scalar value
	
	outputIdx =2;
	//printf("outputIdx=%d\n",outputIdx);
	//plhs[outputIdx] = mxCreateNumericMatrix(1,1,mxUINT32_CLASS,mxREAL);
	plhs[outputIdx] = mxCreateDoubleMatrix(1,1,mxREAL);
	pr = mxGetPr(plhs[outputIdx]);
	for(i = 0; i < 1; i++){
		//piter[i] = 3;
		pr[i] = (unsigned int) piter[i];
	}
	//=======================================================================
	mxFree(P_in.pElement);
	mxFree(x);
	mxFree(resvec);
	mxFree(piter);
}