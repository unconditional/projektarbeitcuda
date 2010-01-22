echo "setup for Geforce 9500 GT"

set DOUBLEFLAGS=-DPRJACUDADOUBLE --gpu-architecture sm_13
set PRJACUDACFLAGS=-I include/common %DOUBLEFLAGS%
set BLA="set by skript"
set PRJACUDAOBJEXT=obj
set PRJACUDAEXEEXT=exe
