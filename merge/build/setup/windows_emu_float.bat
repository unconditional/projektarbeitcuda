echo "setup for Geforce 9500 GT"

set DOUBLEDEFINE=


set DOUBLEFLAGS=%DOUBLEDEFINE%  -deviceemu


set PRJACUDACFLAGS=-I include/common -DPRJCUDAEMU %DOUBLEFLAGS%
set BLA="set by skript"
set PRJACUDAOBJEXT=obj
set PRJACUDAEXEEXT=exe

set PRJACUDAHOSTLD=link
set PRJACUDALIBEXT=lib
set PRJACUDAHOSCC=cl
