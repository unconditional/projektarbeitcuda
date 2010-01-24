

extern "C" void idrs(
                     t_mindex N,
                     t_SparseMatrix A_h,

                     t_ve* b_h,
                     t_mindex s,
                     t_ve  tol,
                     t_mindex maxit,
                     t_ve* x0_h,



                     t_ve* x_h,  /* output vector */
                     t_ve* resvec_h,
                     t_mindex* piter
                  );







