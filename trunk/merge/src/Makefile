CFLAGS = $(PRJACUDACFLAGS)
CC = nvcc $(CFLAGS)
LD = nvcc $(CFLAGS)

OX = $(PRJACUDAOBJEXT)

showenvironment.$(PRJACUDAEXEEXT): showenvironment.$(OX)
	$(LD) -o showenvironment.$(PRJACUDAEXEEXT)  showenvironment.$(OX) > nul

showenvironment.$(OX): showenvironment/showenvironment.cu
	echo $(PRJACUDAOBJEXT)
	$(CC) -c showenvironment/showenvironment.cu -o showenvironment.$(OX) > nul
