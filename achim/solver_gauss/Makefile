CFLAGS = -deviceemu
CC = nvcc $(CFLAGS)

##solver: gauss_plain.o gausskernel.o util.o problemsamples.o idrs.o idrsdriver 
#	$(CC)  -o gauss_plain gauss_plain.o gausskernel.o util.o problemsamples.o idrs.o > nul

#gauss_plain.o: gauss_plain.cu util.h projektcuda.h
#	$(CC)  -c gauss_plain.cu -o gauss_plain.o  > nul

# redirect to nul for tweaking nmake :-/
# see <http://forums.nvidia.com/index.php?showtopic=56803>

measuredotmul: measuredotmul.o dotMul_cuda_gpu02.o dotMul_cpu.o
	$(CC) -o measuredotmul measuredotmul.o dotMul_cuda_gpu02.o dotMul_cpu.o > nul

idrsdriver: idrsdriver.o idrs.o dotMul_cuda_gpu02.o
	$(CC) -o idrsdriver idrsdriver.o idrs.o dotMul_cuda_gpu02.o > nul
	
idrsdriver.o: idrs_driver.cu idrs.o
	$(CC) -o idrsdriver.o  -c idrs_driver.cu > nul

gausskernel.o: gausskernel.cu projektcuda.h
	$(CC) -c gausskernel.cu -o gausskernel.o > nul

util.o: util.cu util.h projektcuda.h
	$(CC) -c util.cu -o util.o  > nul

problemsamples.o: problemsamples.cu projektcuda.h
	$(CC) -c problemsamples.cu -o problemsamples.o  > nul

idrs.o: idrs.cu idrs.h projektcuda.h
	$(CC) -c idrs.cu -o idrs.o > nul

dotMul_cuda_gpu02.o: dotMul_cuda_gpu02.cu projektcuda.h 
	$(CC) -c dotMul_cuda_gpu02.cu -o dotMul_cuda_gpu02.o > nul
	
measuredotmul.o: measuredotmul.cu projektcuda.h
	$(CC) -c measuredotmul.cu -o measuredotmul.o > nul
	
dotMul_cpu.o: dotMul_cpu.cu projektcuda.h
	$(CC) -c dotMul_cpu.cu -o dotMul_cpu.o > nul