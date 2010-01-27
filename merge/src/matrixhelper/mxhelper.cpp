#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"

 void debug_dump_sparse(  t_SparseMatrix sm_in  ) {

   if ( sm_in.m < 30 ) {
       printf("\n *** MXhelper inimplemented unimplemented *** \n ");
   }
   else {
      printf(" Matrixsize %u too big for dump", sm_in.m );
   }
}

