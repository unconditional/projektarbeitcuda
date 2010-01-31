#include "cuda.h"
#include <stdio.h>
#include "projektcuda.h"

#define AZeile(i,j,w) A[i*w+j]
#define ASpalte(i,j,w) A[j*w+i]

__global__ void matrixMul(
                            t_ve* C_out,
                            t_ve* A,
                            t_ve* B,
                            int mA,
                            int mB
                           ) {

   // blockIdx.x is current row of C and B

    if ( threadIdx.x == 0 ) {
       t_ve c = 0;

       for ( int as = 0; as < mB; as++ ) {
            c += A[ blockIdx.x + as * mA] * B[as];
       }

       C_out[blockIdx.x] = c;
    }


}

/* Kernel to square elements of the array on the GPU */
/*
	Matrix A is mA x nB  , Vector B is nB
	Vector C output vector in size of mA
	C=A*B
	matrixMul_kernel03.cu
description:
	each row of A occuppy one block. if gridDim is smaller than the row number of A
*/

__global__ void matrixMul_long_mA( t_ve* C, t_ve* A, t_ve* B, int mA, int nB) {

	//define a Result Vector for each block
	__shared__ float Cs[VECTOR_BLOCK_SIZE];//VECTOR_BLOCK_SIZE shuld equal blockDim 512

	//define gridIndex, if gridDim < mA, gridIndex > 0;
	int gridIndex = 0;
	// get a thread indentifier
	//int idx = gridIndex*gridDim.x + blockIdx.x*blockDim.x+threadIdx.x;
	int aBegin = 0;
	int bBegin = 0;
	int aStep = gridDim.x;
	int bStep = VECTOR_BLOCK_SIZE; // blockDim.x
	int aEnd = mA;
	int bEnd = nB;
	int tx;
	tx = threadIdx.x;

		//initialise Cs
		Cs[tx] = 0;
		__syncthreads();
		//initialize output vector for each block
	if(tx==0){
		C[gridIndex*gridDim.x+blockIdx.x]=0;
	}
		__syncthreads();
	// if nB > gridDim???????
	//idx < (gridIndex*gridDim.x+mA%VECTOR_BLOCK_SIZE)*()
	for(int a = aBegin; (a < aEnd)&&((gridIndex*gridDim.x+blockIdx.x)<aEnd); a += aStep, gridIndex++){
		//initialize output vector for each block
		if(threadIdx.x==0){
			C[gridIndex*gridDim.x+blockIdx.x]=0;
		}
		__syncthreads();

		//following is operations within one block
		// initialize the dot product for each row in A and vector B
		t_ve blocksum = 0;
		//if nB> blockDim, split repeat the
		//for(int b = bBegin; (b < bEnd)&&((threadIdx.x+b) < bEnd); b += bStep ) {
		for(int b = bBegin; b < bEnd; b += bStep ) {

		//initialise Cs#include "project_comm.h"
			Cs[tx] = 0;
			__syncthreads();
			// compute scalar product
			if (( (gridIndex*gridDim.x+blockIdx.x)<aEnd)&&((b+tx) < bEnd)) {
				//Cs[threadIdx.x] = A[a + blockIdx.x ][b + threadIdx.x] * B[b + threadIdx.x ];
				//Cs[threadIdx.x] = A[(a + blockIdx.x)* nB+b + tx] * B[b + tx ];
				//30,Jan.2010
				Cs[threadIdx.x] = ASpalte(a + blockIdx.x,b + tx,mA) * B[b + tx ];
			}
			__syncthreads();

			if(tx == 0){
				//30.Nov.2009 fixeded for Cs summe
				int kEnd = bEnd-b;
				if(kEnd > VECTOR_BLOCK_SIZE)kEnd = VECTOR_BLOCK_SIZE;
				//Because I add Cs[0...k], if blockSize and Matrix does not fit, Parts of Cs[k] are not initialized as 0.

				for (int k = 1; k < kEnd; k++) Cs[0] += Cs[k];
				blocksum += Cs[0];
			}
			__syncthreads();
			/*
			int offset;
			offset = VECTOR_BLOCK_SIZE/2;
			while (offset > 0) {
				if(tx < offset) {
					Cs[tx] += Cs[tx + offset];
				}
				offset >>= 1;
				__syncthreads();
			}
			__syncthreads();
			if(threadIdx.x == 0)
			blocksum += Cs[0]; //??? blocksum = Cs[0];
		*/
		}//for b
		__syncthreads();

		if(threadIdx.x == 0) C[gridIndex*gridDim.x+blockIdx.x] = blocksum;
		__syncthreads();
		// summe all block, need test for mA bigger than one Grid
		//idx = gridIndex*gridDim.x + blockIdx.x*blockDim.x+threadIdx.x;

	}//for a


}

__host__ void dbg_matrixMul_checkresult(
                                          t_ve* C_in,
                                          t_ve* A_in,
                                          t_ve* B_in,
                                          t_mindex mA,
                                          t_mindex mB,
                                          char* debugname
                                        ) {
    cudaError_t e;

    t_ve* C = (t_ve*) malloc( sizeof( t_ve* ) * mA );
    if (  C == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you C"); exit( -1 ); }

    t_ve* Co = (t_ve*) malloc( sizeof( t_ve* ) * mA );
    if (  Co == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you C"); exit( -1 ); }

    t_ve* A = (t_ve*) malloc( sizeof( t_ve* ) * mA  * mB );
    if (  A == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you A"); exit( -1 ); }

    t_ve* B = (t_ve*) malloc( sizeof( t_ve* ) * mB );
    if (  B == NULL ) { fprintf(stderr, "sorry, can not allocate memory for you B"); exit( -1 ); }


    e = cudaMemcpy( A, A_in, sizeof(t_ve) * mA  * mB , cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");

    e = cudaMemcpy( C, C_in, sizeof(t_ve) * mA, cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");

    e = cudaMemcpy( B, B_in, sizeof(t_ve) * mB, cudaMemcpyDeviceToHost);
    CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");



    for ( t_mindex cr = 0; cr < mA; cr++ ) {
       t_ve Celement = 0;
       for ( t_mindex br = 0; br < mB; br++ ) {
           t_mindex as = br;
           Celement += A[ cr + as * mA ] * B[ br ];
       }
       Co[cr] = Celement;
//       t_ve tolerance = abs( Celement / 100 );
       t_ve tolerance;
       if ( abs(Celement) > 1 ) {
            tolerance = abs(  Celement / 10 * mA ) ;
       }
       else {
          tolerance = 0.05 * mA;
       }
      //t_ve tolerance = Celement = 0;
       t_ve diff = Celement - C[cr];
       if ( abs( Celement - C[cr] ) > tolerance ) {

           printf( "\n Matmul '%s' not OK ( sum is C[%u]%f, should be %f", debugname , cr, C[cr], Celement  );
           for ( t_mindex i = 0; i < mB; i++ ) {
              printf("\n C[%u]=%f", i, C[i] );
           }
           printf( "\n" );

           t_ve cumm = 0;
           for ( t_mindex i = 0; i < mB; i++ ) {
              t_mindex ai = i * mA ;
              t_ve prod = B[i] * A[ai];
              cumm += prod;
              printf("\n B[%u] = %f A[%u]= %f  .>  control calculation:  a*b = %f   -> c = %f ", i, B[i], ai, A[ai] , prod, cumm );
           }
           printf( "\n" );

           for ( t_mindex s = 0; s < mB ; s++ ) {
               for ( t_mindex r = 0; r < mA ; r++ ) {
                   t_mindex i = s * mA + r;
                   printf("\n A(%u,%u) = A[%u]=%f", r+1, s+1 , i, A[i] );
               }
           }
           printf( "\n Matmul '%s' not OK ( sum is C[%u]%f, should be %f (tolerance %f, diff %f)", debugname , cr, C[cr], Celement,tolerance, diff);
           printf( "\n mA = %u; mB = %u \n ", mA, mB );
           exit(-1);
       }

    }

//    e = cudaMemcpy( C_in, Co, sizeof(t_ve) * mA, cudaMemcpyHostToDevice);
//    CUDA_UTIL_ERRORCHECK(" cudaMemcpy debugbuffer");

    free(A);
    free(B);
    free(C);
    free(Co);




}
