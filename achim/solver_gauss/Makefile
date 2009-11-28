CFLAGS = -deviceemu
CC = nvcc $(CFLAGS)

solver: gauss_plain.o gausskernel.o util.o problemsamples.o idrs.o
	$(CC)  -o gauss_plain gauss_plain.o gausskernel.o util.o problemsamples.o idrs.o > nul

gauss_plain.o: gauss_plain.cu util.h
	$(CC)  -c gauss_plain.cu -o gauss_plain.o  > nul

# redirect to nul for tweaking nmake :-/
# see <http://forums.nvidia.com/index.php?showtopic=56803>

gausskernel.o: gausskernel.cu
	$(CC) -c gausskernel.cu -o gausskernel.o > nul

util.o: util.cu util.h
	$(CC) -c util.cu -o util.o  > nul

problemsamples.o: problemsamples.cu
	$(CC) -c problemsamples.cu -o problemsamples.o  > nul

idrs.o: idrs.cu idrs.h
	$(CC) -c idrs.cu -o idrs.o > nul