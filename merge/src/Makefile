CFLAGS = $(PRJACUDACFLAGS)
CC = nvcc $(CFLAGS)
LD = nvcc $(CFLAGS)

OX = $(PRJACUDAOBJEXT)

all: showenvironment.$(PRJACUDAEXEEXT) idrs.$(OX)

showenvironment.$(PRJACUDAEXEEXT): showenvironment.$(OX)
	$(LD) -o showenvironment.$(PRJACUDAEXEEXT)  showenvironment.$(OX) > nul

idrs.$(OX): idrs/idrs.cu
	$(CC) -c idrs/idrs.cu -o idrs.$(OX) > nul

showenvironment.$(OX): showenvironment/showenvironment.cu
	$(CC) -c showenvironment/showenvironment.cu -o showenvironment.$(OX) > nul
