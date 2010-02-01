#! /bin/sh

DOUBLEDEFINE="-DPRJACUDADOUBLE"

export DOUBLEDEFINE

DOUBLEFLAGS="$DOUBLEDEFINE -arch=sm_13" # as describe in https://www.cs.virginia.edu/~csadmin/wiki/index.php/CUDA_Support/Enabling_double-precision


PRJACUDACFLAGS="-deviceemu -DPRJCUDAEMU -I include/common -I include $DOUBLEFLAGS"
export PRJACUDACFLAGS

PRJACUDAOBJEXT=o
export PRJACUDAOBJEXT

PRJACUDAEXEEXT=exe
export PRJACUDAEXEEXT

PRJACUDAHOSTLD=gcc
export PRJACUDAHOSTLD

PRJACUDALIBEXT=a
export PRJACUDALIBEXT

PRJACUDAHOSCC=gcc
export PRJACUDAHOSCC