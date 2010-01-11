#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

typedef int        t_mindex;

typedef struct SparseMatrix{

    t_mindex  cnt_elements;
    t_mindex  cnt_colums;

    t_mindex* ir;
    t_ve*     pr;
    t_mindex* jc;

} t_SparseMatrix;

// ---------------------------------------------------------------------
__global__ void kernel_sparse( t_SparseMatrix m ) {


    t_ve sum = 0;
    if ( threadIdx.x ==  0) {
       for ( int i = 0; i < m.cnt_elements; i++ ) {
          sum += m.pr[i];
       }
       printf("got sum: %f",  sum);
    }
}
// ---------------------------------------------------------------------
__host__ void set_sparse_data( t_SparseMatrix* m, void* mv ) {

   m->ir = (t_mindex *) mv;
   m->pr = (t_ve *) (&m->ir[m->cnt_elements] ) ;
   m->jc = (t_mindex *) (&m->pr[m->cnt_elements]);

}
// ---------------------------------------------------------------------
__host__ void dump_sparse_matrix( t_SparseMatrix m ) {

    printf( "\n cols: %u elements: %u \n",  m.cnt_colums, m.cnt_elements );

//    for ( t_mindex i = 0; i <= m.cnt_colums; i++ ) {
//        printf("\n %u\t%u", i, m.jc[i] );
//    }
    for ( t_mindex i = 0; i < m.cnt_elements; i++ ) {
        printf("\n%u\t%f", m.ir[i], m.pr[i] );
        if ( i <= m.cnt_colums ) {
            printf("\t %u", m.jc[i] );
        }
    }
    printf("\n\n");
}
// ---------------------------------------------------------------------
__host__ int smat_size( int cnt_elements, int cnt_cols ) {

    return   ( sizeof(t_ve) + sizeof(t_mindex) ) * cnt_elements
           + sizeof(t_mindex)  * (cnt_cols + 1);
}
// ---------------------------------------------------------------------
int main()

{

    t_SparseMatrix host_m, device_m;

    host_m.cnt_elements = 6;
    host_m.cnt_colums   = 3;

    device_m.cnt_elements = host_m.cnt_elements;
    device_m.cnt_colums   = host_m.cnt_colums;

    printf("\n Testting sparse basics \n");

    int msize = smat_size( host_m.cnt_elements, host_m.cnt_colums );

    printf(" got result %u \n", msize);

    void *hostmem =   malloc( msize );
    if ( hostmem == NULL) {
           fprintf(stderr, "sorry, can not allocate memory for you");
           exit( -1 );
    }

   /* ---------------------------------- */



//   host_m.ir = (t_mindex *) hostmem;
//   host_m.pr = (t_ve *) (&host_m.ir[6]);
//   host_m.jc  = (t_mindex *) (&host_m.pr[6]);

   set_sparse_data( &host_m, hostmem);

   host_m.jc[0] = 0;
   host_m.jc[1] = 2;
   host_m.jc[2] = 3;
   host_m.jc[3] = 6;

   host_m.ir[0] = 1;
   host_m.ir[1] = 4;
   host_m.ir[2] = 2;
   host_m.ir[3] = 1;
   host_m.ir[4] = 4;
   host_m.ir[5] = 5;

   host_m.pr[0] = 1;
   host_m.pr[1] = 1;
   host_m.pr[2] = 1;
   host_m.pr[3] = 2;
   host_m.pr[4] = 1;
   host_m.pr[5] = 1;


   dump_sparse_matrix( host_m );


   void *devicemem;
   cudaError_t e;

   e = cudaMalloc ( &devicemem, msize );
   CUDA_UTIL_ERRORCHECK("cudaMalloc")

   e = cudaMemcpy(  devicemem, hostmem, msize , cudaMemcpyHostToDevice);
   CUDA_UTIL_ERRORCHECK("cudaMemcpy")

   set_sparse_data( &device_m, devicemem);

   dim3 dimGrid ( 1 );
   dim3 dimBlock(32);


   kernel_sparse<<<dimGrid,dimBlock>>>( device_m );
   e = cudaGetLastError();
   CUDA_UTIL_ERRORCHECK("summup_kernel_kernel_dotmul");


}

