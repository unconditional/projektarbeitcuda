CFLAGS = $(PRJACUDACFLAGS)
CC = nvcc  $(CFLAGS)
#LD = nvcc $(CFLAGS)
LD = nvcc $(CFLAGS)

#HOSTLD = $(PRJACUDAHOSTLD) # linker from host system (gcc on GNU, 'link' on MS visual studio,  ...
HOSTLD = $(PRJACUDAHOSTLD) # linker from host system (gcc on GNU, 'link' on MS visual studio,  ...
#HOSTCC = $(PRJACUDAHOSCC)
HOSTCC = $(PRJACUDAHOSCC)

OX = $(PRJACUDAOBJEXT)
LIBX = $(PRJACUDALIBEXT)

all: showenvironment.$(PRJACUDAEXEEXT) idrs.$(OX) idrscli.$(OX) idrscli.$(PRJACUDAEXEEXT) libidrs.a

idrscli.$(PRJACUDAEXEEXT): idrs/idrscli.c libidrs.$(LIBX) idrscli.$(OX)
	$(HOSTLD) idrscli.$(OX)  -lidrs  -lcudart -L./ -o idrscli.$(PRJACUDAEXEEXT) -L/usr/local/cuda/lib

idrscli.$(OX): idrs/idrscli.c
	nvcc -Iinclude/common -I./  -c  -o idrscli.$(OX) idrs/idrscli.c > nul

showenvironment.$(PRJACUDAEXEEXT): showenvironment.$(OX)
	$(LD) -o showenvironment.$(PRJACUDAEXEEXT)  showenvironment.$(OX) > nul


libidrs.$(LIBX): idrs.$(OX)
	$(CC) -lib idrs.$(OX) -o libidrs.$(LIBX) >nul

idrs.$(OX): idrs/idrs.cu
	$(CC) -c idrs/idrs.cu -o idrs.$(OX) > nul
#	gcc -c -Iinclude/common -I./ idrs/idrs.cu -o idrs.$(OX) > nul

showenvironment.$(OX): showenvironment/showenvironment.cu
	$(CC) -c showenvironment/showenvironment.cu -o showenvironment.$(OX) > nul
