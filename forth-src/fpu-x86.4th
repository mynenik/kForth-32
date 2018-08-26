\ fpu-x86.4th
\
\ Precision control of the x86 Floating Point Unit
\
\ Derived from C code by Kevin Egan, Brown University.
\ This code is published at:
\
\     http://www.stereopsis.com/FPU.html 
\
\ ----------------------------------------------------

\ bits to set the floating point control word register
\
\ Sections 4.9, 8.1.4, 10.2.2 and 11.5 in 
\ IA-32 Intel Architecture Software Developer's Manual
\   Volume 1: Basic Architecture
\
\ http://www.intel.com/design/pentium4/manuals/245471.htm
\
\ http://www.geisswerks.com/ryan/FAQS/fpu.html
\
\ precision control:
\ 00 : single precision
\ 01 : reserved
\ 10 : double precision
\ 11 : extended precision
\
\ rounding control:
\ 00 = Round to nearest whole number. (default)
\ 01 = Round down, toward -infinity.
\ 10 = Round up, toward +infinity.
\ 11 = Round toward zero (truncate).

BASE @
HEX
003f  constant  FPU_CW_EXCEPTION_MASK   
0001  constant  FPU_CW_INVALID          
0002  constant  FPU_CW_DENORMAL         
0004  constant  FPU_CW_ZERODIVIDE       
0008  constant  FPU_CW_OVERFLOW        
0010  constant  FPU_CW_UNDERFLOW        
0020  constant  FPU_CW_INEXACT         

0300  constant  FPU_CW_PREC_MASK        
0000  constant  FPU_CW_PREC_SINGLE     
0200  constant  FPU_CW_PREC_DOUBLE      
0300  constant  FPU_CW_PREC_EXTENDED    

0c00  constant  FPU_CW_ROUND_MASK      
0000  constant  FPU_CW_ROUND_NEAR       
0400  constant  FPU_CW_ROUND_DOWN      
0800  constant  FPU_CW_ROUND_UP         
0c00  constant  FPU_CW_ROUND_CHOP       

1f3f  constant  FPU_CW_MASK_ALL        

\ --------------------------------------------------------
variable fpu-control

\ The following CODE words are in kForth's asm-x86 style
\   Modify as needed for your Forth system.

CODE getFPUStateX86
       fpu-control #@ fnstcw,
END-CODE

CODE setFPUStateX86
       fpu-control #@ fldcw,
END-CODE 
\ --------------------------------------------------------

\ Modify the control bits of a given setting, e.g.
\
\   FPU_CW_PREC_DOUBLE  FPU_CW_PREC_MASK  modifyFPUStateX86
\
\ sets double precision mode.

: modifyFPUStateX86 ( control mask -- )
    dup >r and
    getFPUStateX86 
    fpu-control @ r> not and or fpu-control !
    setFPUStateX86
;

BASE !

