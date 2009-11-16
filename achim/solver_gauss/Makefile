CFLAGS = -deviceemu
CC = nvcc ${CFLAGS}

solver: gauss_plain.cu gausskernel.o
	${CC} gauss_plain.cu gausskernel.o

gausskernel.o: gausskernel.cu
	${CC} -c gausskernel.cu