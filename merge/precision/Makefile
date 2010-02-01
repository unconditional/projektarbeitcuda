DOUBLEFLAGS = -DPRJACUDADOUBLE -arch=sm_13

all: precision_float_emu.exe precision_double_emu.exe precision_float_device.exe precision_double_device.exe

precision_float_emu.exe: precision.cu
	nvcc -deviceemu precision.cu -o precision_float_emu.exe > nul

precision_float_device.exe: precision.cu
	nvcc  precision.cu -o precision_float_device.exe > nul

precision_double_emu.exe: precision.cu
	nvcc -deviceemu $(DOUBLEFLAGS) precision.cu -o precision_double_emu.exe > nul

precision_double_device.exe: precision.cu
	nvcc $(DOUBLEFLAGS) precision.cu -o precision_double_device.exe > nul
