#include <stdlib.h>
// #include <stdio.h>
#include "projektcuda.h"
#include "mex.h"
#include <math.h>

t_ve norm(t_ve *pV, int N, int col) {
    int i;
    t_ve psum=0;
    for (i=1;i<=N;i++) {
        psum+=pV[a(i, col)]*pV[a(i, col)];
    }
    psum=(t_ve) sqrt(psum);
    return psum;
}

// v=v-V*y;
void sub_MVP(t_ve* py, t_ve* A, int N, int col) {
    int i, j;
    t_ve sum;
    
    for (j = 1; j <= N; j++) {
        sum=0;
        for (i = 1; i < col; i++) {
            sum += A[a(j, i)] * py[i-1];
        }
        A[a(j, col)] = A[a(j, col)] - sum;
//             mexPrintf("sum %e ",sum);
            }
}

// y=V'*v;
void MVP_t(t_ve* py, t_ve* A, int N, int col) {
    int i, j;
    t_ve sum;
    
    for (i = 1; i < col; i++) {
        sum=0;
        for (j = 1; j <= N; j++) {
            sum += A[a(j, i)] * A[a(j, col)];
        }
        py[i-1] = (t_ve) sum;
    }
}

void divbyfac(t_ve *pV, t_ve fac, int N, int col) {
    int i;
    for (i=1;i<=N;i++)
        pV[a(i, col)]= (pV[a(i, col)] / fac);
    
}


void orthogonalize(t_ve *pMatrix, t_ve *pRes, int N, int s) {
// Gram-Schmidt-Orthogonalization
    t_ve * py;
    t_ve psum=0;
    t_ve nr_n=0;
//     t_ve eps;
//     t_ve nr, nr_o;
    int i, j, k;
    
//     if (sizeof(t_ve)<5)
//         eps=(t_ve) 1.1920929E-7; //single
//     else
//         eps=(t_ve) 2.220446049250313E-16; //double
    
    
    // set r as 1st column
    for (i=1;i<=N;i++) {
        pMatrix[a(i, 1)]= pRes[i-1];
    }
    // normalize 1st column
    nr_n=norm(pMatrix, N, 1);
    divbyfac(pMatrix, nr_n, N, 1);

    // set random values for 2nd-s'th column
    for (i=1;i<=N;i++)
        for (j=2;j<=N;j++) {
            {
                pMatrix[a(i, j)]= (t_ve) rand();
            }
        }
    
    py=mxMalloc(s*sizeof(t_ve));
    for (i=0; i<s; i++)
        py[i]=0;
    for (k=2;k<=s;k++) {
//         nr_o=norm(pMatrix, N, k);
//         nr=eps*nr_o;
        MVP_t(py, pMatrix, N, k); //y=V'*v;
        sub_MVP(py, pMatrix, N, k); //v=v-V*y;
        nr_n=norm(pMatrix, N, k);
        divbyfac(pMatrix, nr_n, N, k);
//          mexPrintf("%e\n",nr_n);
    }
    mxFree(py);
    return;
}


void mexFunction(int outArraySize, mxArray *pOutArray[], int inArraySize, const mxArray *pInArray[]) {
    int i, j, s, N;
    double *data1, *data2;
   
    t_ve *pMatrix, *pR;
       
    //if (intArraySize != outArraySize) mexErrMsgTxt("the number of input and output arguments must be same!");
    s =(int) mxGetM(pInArray[0]);
    N =(int) mxGetN(pInArray[0]);


    pMatrix=mxMalloc(N*s*sizeof(t_ve));
    pR=mxMalloc(N*sizeof(t_ve));
    pOutArray[0] = mxCreateDoubleMatrix(N, s, mxREAL);
    
    data1 = mxGetPr(pInArray[0]);
    data2 = mxGetPr(pOutArray[0]);
    
    // switch from column-based to row-based notation for Matlab input
    for(i = 1; i <= N; i++) {
        for(j = 1; j <= s; j++) {
            pMatrix[a(i, j)] = (t_ve) data1[a(j, i)];
        }
    }
    // invent an r...
    for(i = 0; i < N; i++) {
        pR[i] = (t_ve) (sqrt(i+1));
    }

    //*****************************************************************
    // Call orthogonalization
    //*****************************************************************
    // pMatrix has to be preallocated
    // pR should obtain values of vector r
    // N dimensional system matrix
    // s parameter of IDR(s) (subspace dimension)
    orthogonalize(pMatrix, pR, N, s);
    // resulting pMatrix is NOT transposed as is should be cf. idrs.m!!!
    //*****************************************************************
    

    // switch from row-based to column-based notation for Matlab output
    for(i = 1; i <= N; i++) {
        for(j = 1; j <= s; j++) {
            data2[a(i, j)]=(double) pMatrix[a(j, i)];
        }
    }

    mxFree(pMatrix);
    mxFree(pR);
}

