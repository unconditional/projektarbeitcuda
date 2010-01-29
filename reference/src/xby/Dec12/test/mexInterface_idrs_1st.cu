/* matlab interface for 
extern "C" void idrs_1st(

                     t_SparseMatrix A_in,    // A Matrix in buyu-sparse-format //0
                     t_ve*          b_in,    // b as in A * b = x //1
                     t_ve*          xe_in, //2

                     t_mindex N,	//3

                     t_ve*          r_out,    // the r from idrs.m line 6 : r = b - A*x; 

                     t_idrshandle*  ih_out  // handle for haloding all the device pointers between matlab calls 

           );
				  
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
	int inputIdx,outputIdx;
	t_SparseMatrix A_in;
	t_ve *b_in,tol, *xe_in, *r_out;
	t_idrshandle*  ih_out;
	unsigned int s, N;
    unsigned int m,n;
    unsigned int nzmax;
    int *ir,*jc,i;
    //unsigned int *irs,*jcs;
    //int cmplx,isfull;
    double *pr,*pi;//,*si,*sr;
    int size_resvec;
	int msize ;
	void *devicemem;
	
	if( nrhs < 4 ) {
		printf("not enough input argument!\n");
		printf("[r_out,ih_out]=mexInterface_idrs_1st(A_in, b_in, xe_in, N);\n");
		return;
	}
	
    //=======read input===============================================================
	//read spaser Matrix A_in
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
	A_in.m = n;
	A_in.n = m;
	A_in.nzmax = nzmax;
	msize = smat_size( A_in.nzmax, A_in.n );
	
	devicemem = mxMalloc ( msize );
	set_sparse_data(&A_in, devicemem);
	printf("ir0 = %d, pr0 = %lf\n",ir[0],pr[0]);
	for(i = 0; i < nzmax; i++){
        A_in.pNZElement[i] =(t_ve)pr[i];
        A_in.pCol[i] = ir[i];
		printf("ir = %d, pr = %lf\n",ir[i],pr[i]);
    }
    for(i = 0; i < n+1; i++){  
        A_in.pRow[i] = jc[i];
		
    }

	//read b_in size of N = m*n
	printf("read Vector b!\n");
	inputIdx = 1;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	b_in = (t_ve*)mxMalloc(sizeof(t_ve)*m*n);
	for(i = 0; i < m*n; i++){
		b_in[i] = (t_ve)pr[i];
	}
	
	
	//read xe_in size of N = m*n
	inputIdx = 2;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
    xe_in = (t_ve*)mxMalloc(sizeof(t_ve)*m*n);
	for(i = 0; i < m*n; i++){
		xe_in[i] = (t_ve)pr[i];
	}
	//read N
	inputIdx = 3;
	m  = mxGetM(prhs[inputIdx]);
    n  = mxGetN(prhs[inputIdx]);
    pr = mxGetPr(prhs[inputIdx]);
    pi = mxGetPi(prhs[inputIdx]);
	N = (unsigned int)pr[0];
	
	 printf("create output!\n");

	
	//create output vector r_out of size N
	r_out = (t_ve*)mxMalloc(sizeof(t_ve)*N);
	//output ih_out ???????
	ih_out = (t_idrshandle *)mxMalloc(sizeof(t_idrshandle)*1);
	//=======================================================================
	//call idrs interface 
	//idrs_1st(A_in, b_in, xe_in, N, r_out, ih_out);
	/*
	extern "C" void idrs_1st(
                     t_SparseMatrix A_in,   //A Matrix in buyu-sparse-format 
                     t_ve*          b_in,   // b as in A * b = x 
                     t_ve*          xe_in,

                     t_mindex N,

                     t_ve*          r_out,    // the r from idrs.m line 6 : r = b - A*x; 

                     t_idrshandle*  ih_out  // handle for haloding all the device pointers between matlab calls 
           );
	*/
	//=======================================================================
	//output r_out,t_idrshandle in matlab
	outputIdx = 0; //r_out
    plhs[outputIdx] = mxCreateDoubleMatrix(N,1,mxREAL);
	pr = mxGetPr(plhs[outputIdx]);
	for(i = 0; i < N; i++){
		//r_out[i] = 1;
		pr[i] = (double)r_out[i];
	}
	//output t_idrshandle
	outputIdx = 1; //t_idrshandle
	//plhs[outputIdx] = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
	plhs[outputIdx] = mxCreateDoubleMatrix(1,1,mxREAL);;
	pr = mxGetPr(plhs[outputIdx]);
	
	for(i = 0; i < 1; i++){
		printf("output ihout");
		pr[i] = (int)ih_out[0];
	}
	//=======================================================================
	mxFree(devicemem);
	mxFree(b_in); 
	mxFree(xe_in); 
	mxFree(r_out);
	mxFree(ih_out);
	
	
	
}