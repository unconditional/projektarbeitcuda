
extern "C" size_t idrs_sizetve();

extern "C" void idrs_1st(

                     t_SparseMatrix A_in,    /* A Matrix in buyu-sparse-format */
                     t_ve*          b_in,    /* b as in A * b = x */
                     t_ve*          xe_in,

                     t_mindex N,

                     t_ve*          r_out,    /* the r from idrs.m line 6 : r = b - A*x; */

                     t_idrshandle*  ih_out  /* handle for haloding all the device pointers between matlab calls */

           );

extern "C" void idrs(

                     t_SparseMatrix A_h,

                     t_ve* b_h,

                     t_mindex s,
                     t_ve  tol,
                     t_mindex maxit,
                     t_ve* x0_h,
                     t_mindex N,


                     t_ve* x_h,  /* output vector */
                     t_ve* resvec_h,
                     t_mindex* piter
                  );







