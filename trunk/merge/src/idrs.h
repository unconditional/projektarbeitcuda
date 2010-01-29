
extern "C" size_t idrs_sizetve();

extern "C" void set_debuglevel( int debuglevel );


extern "C" void idrswhole(

    t_SparseMatrix A_in,    /* A Matrix in buyu-sparse-format */
    t_ve*          b_in,    /* b as in A * b = x */

    t_mindex s,
    t_ve tol,
    t_mindex maxit,

    t_ve*          x0_in,

    t_mindex N,

    t_ve* x_out,
    t_ve* resvec_out,
    unsigned int* piter

);

extern "C" void idrs_1st(

                     t_SparseMatrix A_in,    /* A Matrix in buyu-sparse-format */
                     t_ve*          b_in,    /* b as in A * b = x */
                     t_ve*          xe_in,

                     t_mindex N,

                     t_ve*          r_out,    /* the r from idrs.m line 6 : r = b - A*x; */

                     t_idrshandle*  ih_out  /* handle for haloding all the device pointers between matlab calls */

           );


extern "C" void idrs2nd(
    t_FullMatrix P_in,
    t_ve         tol,
    unsigned int s,
    unsigned int maxit,
    t_idrshandle ih_in, /* Context Handle we got from idrs_1st */
    t_ve*        x_out,
    t_ve*        resvec_out,
    unsigned int* piter
);


