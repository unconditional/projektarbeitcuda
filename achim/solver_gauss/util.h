#define GAUSS_SOLVE_OK 1
#define GAUSS_SOLVE_ERROR -1

#include "projektcuda.h"

typedef struct {

    unsigned int n;
    t_ve*    elements;
    t_ve*    orgelements;
    t_ve*    x;

    t_ve*    device_elements;
    t_ve*    device_x;

} t_matrix;

typedef t_matrix* t_pmatrix;



__host__ void dump_problem( t_ve* p_Ab, unsigned int N  );

__host__ void dump_x( t_ve* x, unsigned int N  );

__host__ void malloc_matrix( unsigned int size_n, t_pmatrix matrix );

__host__  int check_correctness(  t_ve* p_Ab, unsigned int N, t_ve* p_x );

__host__ void backup_problem ( t_pmatrix matrix );

__host__ void free_matrix( t_pmatrix matrix );
