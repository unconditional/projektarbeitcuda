
#define ab( r, s ) (r -1 ) * ( N + 1 ) + s -1

#define a( r, s ) (r -1 ) * N  + s -1

#define CUDA_UTIL_ERRORCHECK(MSG)        if( e != cudaSuccess ) \
        {\
            fprintf(stderr, "*** Error on CUDA operation '%s': '%s'*** \n\n", MSG, cudaGetErrorString(e));\
            exit(-3);\
        }\


#define GAUSS_NMAX 22

# define BLOCK_EXP 9
# define DEF_BLOCKSIZE 1 << BLOCK_EXP

typedef float        t_ve; /* base type of Matrizes: 'float' or 'double' */
typedef t_ve*        pt_ve;


