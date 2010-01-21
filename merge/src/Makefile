CFLAGS = $(PRJACUDACFLAGS)
CC = nvcc $(CFLAGS)

OX = $(PRJACUDAOBJEXT)

showenvironment.$(PRJACUDAEXEEXT): showenvironment.$(OX)
	$(CC) -o showenvironment.$(PRJACUDAEXEEXT)  showenvironment.$(OX) > nul

showenvironment.$(OX): showenvironment/showenvironment.cu
	echo $(PRJACUDAOBJEXT)
	$(CC) -c showenvironment/showenvironment.cu -o showenvironment.$(OX) > nul
