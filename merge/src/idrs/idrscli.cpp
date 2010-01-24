#include <stdlib.h>
#include <stdio.h>

#include "projektcuda.h"
#include "idrs.h"

int main()
{
   printf("manual IDRS driver");

   t_SparseMatrix a;
   t_ve bla;
   t_mindex blai;



   idrs(
         a,
         &bla,
         10,
         bla,
         20,
         &bla,

         30,

         &bla,
         &bla,
         &blai
     );

}

