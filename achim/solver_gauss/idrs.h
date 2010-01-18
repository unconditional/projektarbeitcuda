

__host__ void idrs(
                     SparseMatrix A,
                     t_ve* b,
                     unsigned int s,
                     t_ve  tol,
                     unsigned int maxit,
                     t_ve* x0,

                     unsigned int N,

                     t_ve* x,  /* output vector */
                     t_ve* resvec,
                     unsigned int* piter
                  );

