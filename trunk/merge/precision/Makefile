DOUBLEFLAGS = -DPRJACUDADOUBLE -arch=sm_13

all: precision_float_emu.exe precision_double_emu.exe

precision_float_emu.exe: precision.cu
	nvcc -deviceemu precision.cu -o precision_float_emu.exe

precision_double_emu.exe: precision.cu
	nvcc -deviceemu $(DOUBLEFLAGS) precision.cu -o precision_double_emu.exe
