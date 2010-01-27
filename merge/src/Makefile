CFLAGS = $(PRJACUDACFLAGS) -I include
CC = nvcc  $(CFLAGS)
#LD = nvcc $(CFLAGS)
LD = nvcc $(CFLAGS)

#HOSTLD = $(PRJACUDAHOSTLD) # linker from host system (gcc on GNU, 'link' on MS visual studio,  ...
HOSTLD = $(PRJACUDAHOSTLD) # linker from host system (gcc on GNU, 'link' on MS visual studio,  ...
#HOSTCC = $(PRJACUDAHOSCC)
HOSTCC = $(PRJACUDAHOSCC)

OX = $(PRJACUDAOBJEXT)
LIBX = $(PRJACUDALIBEXT)


all: showenvironment.$(PRJACUDAEXEEXT) idrs.$(OX) idrscli.$(OX) idrscli.$(PRJACUDAEXEEXT) libidrs.$(LIBX)

idrscli.$(PRJACUDAEXEEXT):  libidrs.$(LIBX) idrscli.$(OX)
	$(HOSTLD) idrscli.$(OX)  -lidrs  -lcudart -L./ -o idrscli.$(PRJACUDAEXEEXT) -L/usr/local/cuda/lib

idrscli.$(OX): idrs/idrscli.cpp idrs.h
	nvcc $(DOUBLEDEFINE) -Iinclude/common -I./  -c  -o idrscli.$(OX) idrs/idrscli.cpp > nul

showenvironment.$(PRJACUDAEXEEXT): showenvironment.$(OX)
	$(LD) -o showenvironment.$(PRJACUDAEXEEXT)  showenvironment.$(OX) > nul


libidrs.$(LIBX): idrs.$(OX) kernelsparsemul.$(OX) kerneldotmul.$(OX) mxhelper.$(OX)
	$(CC) -lib idrs.$(OX) kernelsparsemul.$(OX) kerneldotmul.$(OX) mxhelper.$(OX) -o libidrs.$(LIBX) >nul

kerneldotmul.$(OX): kernels/dotmul/dotMul_cuda_gpu.cu
	$(CC) -c kernels/dotmul/dotMul_cuda_gpu.cu -o kerneldotmul.$(OX) > nul

mxhelper.$(OX): matrixhelper/mxhelper.cpp
	$(CC) -c matrixhelper/mxhelper.cpp -o mxhelper.$(OX) > nul

kernelsparsemul.$(OX): kernels/sparsematrixmulvector/sparseMatrixMul_kernel.cu
	$(CC) -c kernels/sparsematrixmulvector/sparseMatrixMul_kernel.cu -o kernelsparsemul.$(OX) > nul

idrs.$(OX): idrs/idrs.cu
	$(CC) -c idrs/idrs.cu -o idrs.$(OX) > nul
#	gcc -c -Iinclude/common -I./ idrs/idrs.cu -o idrs.$(OX) > nul

showenvironment.$(OX): showenvironment/showenvironment.cu
	$(CC) -c showenvironment/showenvironment.cu -o showenvironment.$(OX) > nul
