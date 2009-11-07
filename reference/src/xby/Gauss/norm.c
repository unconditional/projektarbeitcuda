double norm(const double *pV1, const int size)
{
 	   double result=0;
 	   int i;
 	   for(i = 0; i < size; i++)result += pV1[i]*pV1[i];
	   result = sqrt(result);
	   return result; 	    	   
}
