IDRS Algorithm implemenetd in CUDA

contact: "Bastian Bandlow" <bandlow@tet.upb.de>  (University of Paderborn)

achim@grolmsnet.de,
buyuxiao@mail.upb.de,
guanhua.bai@googlemail.com


Known problems:

* currently Multiplikation of non-square matrizes (full)
  does not work properly

* never get a real device to work properly with "double precision".




1. Building the idrs-library:


1.1 ensure CUDA-tools are properly installed

1.2  in  build/setup a set of configure-skripts per platform is located.
     use the skript matching your platform to configure the build system.

     to create your own configure skript the main differences are:
     * Platform (Windows/Unix)
     * precision (float/double)
     * Emulation-mode (on/off)

1.3  Build

    * on Windows

    1.3.1 start "MS Visual studio"-Shell (AKA "Eingabeaufforderung")
    1.3.2 run matching configure skript in build/setup
    1.3.3 cd into directoy 'src"
    1.3.4 run "nmake"
    1.3.5 check if 'libidrs.lib' is created
    1.3.6 run 'linkms.bat' to create file 'idrscli.exe'


   * on Unix

    1.3.1 cd into directoy 'src"
    1.3.2 run "make"
    1.3.3 check if 'libidrs.a' is created

1.4 the standalone tool

use idrscli.exe to start the standalone-checks of IDRS implementation

1.5 use 'idrs.h' for interfacing, for example by Mex-Function from Matlab
    ensure libidrs.lib/libidrs.a is added to your linker-configuration!


