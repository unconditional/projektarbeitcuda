#include <stdio.h>
//extern "C" void ext_function();

void ext_function()
{
 	printf("extern function. \n"); 
}
void asignSingleMemory(int **ppSingle)
{
 	 int i;
 	 *ppSingle=(int*)malloc(sizeof(int));
 	 **ppSingle=1;
}
void asignArryMemory(int **ppArry)
{
 	 int i;
 	 int *pArry;
 	 *ppArry=(int*)malloc(3*sizeof(int));
 	 pArry=*ppArry;
	 pArry[0]=1;
	 pArry[2]=1;
	 pArry[3]=1;
}
