CFLAGS = -deviceemu
CC = nvcc $(CFLAGS)

solver: gauss_plain.cu gausskernel.o
	$(CC) gauss_plain.cu gausskernel.o > nul

# redirect to nul for tweaking nmake :-/
# see <http://forums.nvidia.com/index.php?showtopic=56803>

gausskernel.o: gausskernel.cu
	$(CC) -c gausskernel.cu -o gausskernel.o > nul