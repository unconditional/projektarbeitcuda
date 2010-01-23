CFLAGS = $(PRJACUDACFLAGS)
CC = nvcc  $(CFLAGS)
#LD = nvcc $(CFLAGS)
LD = nvcc $(CFLAGS)

OX = $(PRJACUDAOBJEXT)
LIBX = a

all: showenvironment.$(PRJACUDAEXEEXT) idrs.$(OX) idrscli.$(OX) idrscli.$(PRJACUDAEXEEXT) libidrs.a

idrscli.$(PRJACUDAEXEEXT): idrs.$(OX) idrscli.$(OX)
	$(LD) idrscli.$(OX) idrs.$(OX) -o idrscli.$(PRJACUDAEXEEXT)

idrscli.$(OX): idrs/idrscli.cu
	$(CC) -c  -o idrscli.$(OX) idrs/idrscli.cu

showenvironment.$(PRJACUDAEXEEXT): showenvironment.$(OX)
	$(LD) -o showenvironment.$(PRJACUDAEXEEXT)  showenvironment.$(OX) > nul


libidrs.{LIBX}: idrs/idrs.cu
	$(CC) -lib idrs/idrs.cu -o .{LIBX}

idrs.$(OX): idrs/idrs.cu
	$(CC) -c idrs/idrs.cu -o idrs.$(OX) > nul
#	gcc -c -Iinclude/common -I./ idrs/idrs.cu -o idrs.$(OX) > nul

showenvironment.$(OX): showenvironment/showenvironment.cu
	$(CC) -c showenvironment/showenvironment.cu -o showenvironment.$(OX) > nul
