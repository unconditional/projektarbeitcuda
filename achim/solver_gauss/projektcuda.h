


#ifndef __PROJECTCUDAHEADER__
#define __PROJECTCUDAHEADER__


#define ab( r, s ) (s -1) *  N + r -1


#define a( r, s ) (s - 1 ) * N + r -1

#define CUDA_UTIL_ERRORCHECK(MSG)        if( e != cudaSuccess ) \
        {\
            fprintf(stderr, "*** Error on CUDA operation '%s': '%s'*** \n\n", MSG, cudaGetErrorString(e));\
            exit(-3);\
        }\


#define GAUSS_NMAX 22

#define BLOCK_EXP 9
#define DEF_BLOCKSIZE 1 << BLOCK_EXP

#define VECTOR_BLOCK_SIZE DEF_BLOCKSIZE

#ifndef PRJACUDADOUBLE
typedef float        t_ve; /* base type of Matrizes: 'float' or 'double' */
#endif

#ifdef PRJACUDADOUBLE
typedef double        t_ve; /* base type of Matrizes: 'float' or 'double' */
#endif


typedef t_ve*        pt_ve;

typedef unsigned int        t_mindex;


typedef struct Matrix{
    unsigned int m;
    unsigned int n;
    //size m*n
	t_ve* pElement;
} t_FullMatrix;



typedef struct SparseMatrix{
    t_mindex m;         /* count of rows  */
    t_mindex n;         /* count of columns. In case of square Matrix m and n are set by transformation code ( an m=n ;-) ) */
    t_mindex nzmax;     /* count of NZ elements, size of pCol and PnzElement */
	//size m+1
    t_mindex *pRow;    /* jc as in Matlab format, size is .m + 1 */
    //size nzmax
	t_mindex *pCol;    /* ir as in Matlab format,  size is nzmax */
	//size : nzmax
    t_ve* pNZElement;  /* same as pr in Matlab format, size is nzmax */
} t_SparseMatrix;


typedef int t_idrshandle;

#endif
