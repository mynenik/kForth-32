\ asm-x86-examples.4th
\
\ Assorted programming examples using the asm-x86 assembler for kForth.
\
\ K. Myneni, 18 Oct 2001
\
\ Requires: ans-words.4th

include modules.fs
include syscalls.4th
include mc.4th
include asm-x86.4th
include dump

: SEE-CODE ( "name" -- ) ' >BODY a@ 256 DUMP ;

variable v

CODE adrop ( n -- | drop an item from the Forth stack using assembly code )
	TCELL # ebx add,
END-CODE

CODE add5  ( n -- m | add 5 to item on top of Forth stack)
	5 # 0 [ebx] add, 
END-CODE	
		
CODE add   ( n m -- sum | assembly code "+" )
        0 [ebx] eax mov,
	TCELL # ebx add,
	eax 0 [ebx] add,
	0 # eax mov,
END-CODE


\ Example of IF, ... THEN,  and  DO, ... LOOOP,

CODE add-loop  ( n -- m | increment n by using a loop v times)
	0 [ebx] eax mov,
	v #@ ecx mov,	\ set loop count from v
	CXNZ,
	IF,
	  DO,
	    eax inc,
	  LOOP,
	  eax 0 [ebx] mov,
	THEN,
	0 # eax mov,    \ error code for kForth VM (0 = no error)	
END-CODE


\ Example of BEGIN, ... WHILE, ... REPEAT,

CODE test1 ( -- | increment a counter 100 times and store in v)
         0 # ecx mov,
       100 # eax mov,
       BEGIN,
         eax ecx cmp,
         <,
       WHILE,
         ecx     inc,
       REPEAT,
       ecx v #@  mov,
       eax eax   xor,
END-CODE

\ Example of using a Label and JMP,

CODE test2 ( -- | same as above but with explicit JMP, to a label )
         0 # ecx mov,
       100 # eax mov,
Label: doagain
         eax ecx cmp,
	 <, IF,
	   ecx   inc,
	   doagain # jmp,
	 THEN,
	 ecx v #@    mov,
	 eax eax     xor,
END-CODE

CODE v> ( n -- flag | test n > v)
	0 [ebx] eax mov,
	v #@ eax cmp,
	>, IF,
	  TRUE # 0 [ebx] mov,
	ELSE,
	  FALSE # 0 [ebx] mov,
	THEN,
	0 # eax mov,
END-CODE 


CODE mul ( n m -- prod | assembly code "*" )
     0 [ebx] eax mov,
     TCELL # ebx add,
     D-PTR 0 [ebx] imul,
     eax 0 [ebx] mov,
         0 # eax mov,
END-CODE

\ -------------- CPU Info -------------------------------------
BASE @
HEX
\ data from call to the cpu info words is returned in cpuid_buf
create cpuid_buf 10 allot  

CODE cpu_vendor_id ( -- )
	0 # eax mov, 
	ebx push, 
	0f db, a2 db, 
	ebx cpuid_buf #@ mov,
	edx cpuid_buf TCELL + #@ mov,
	ecx cpuid_buf TCELL 2* + #@ mov,
	ebx pop, 
	0 # eax mov, 
END-CODE

CODE cpu_processor_info ( -- )
	1 # eax mov, 
	ebx push, 
	0f db, a2 db, 
	eax cpuid_buf #@ mov,             \ cpu family
	edx cpuid_buf TCELL + #@ mov,     \ feature flags 
	ecx cpuid_buf TCELL 2* +  #@ mov, \ feature flags
	ebx cpuid_buf TCELL 3 * + #@ mov, \ additional feature info     
	ebx pop, 
	0 # eax mov, 
END-CODE
BASE !
     
\ ----------- Floating Point Examples ---------------

fvariable f

CODE set-pi ( -- | set f to pi )
                fldpi,
	  f #@  fstp,
END-CODE


CODE fadd1 ( -- | add 1e to f )
	f # ecx mov,
	        fld1,
	0 [ecx] fadd,
	0 [ecx] fstp,
END-CODE


CODE add-f ( f1 -- f2 | add value of f to number on stack )
       f #@    fld,
       0 [ebx] fadd,
       0 [ebx] fstp,
END-CODE


CODE afmul ( f1 f2 -- f3 | multiply the two numbers on top of stack )
       0 [ebx] fld,
       1 DFLOATS # ebx add,
       0 [ebx] fld,
	       fmulp,
       0 [ebx] fstp,
END-CODE


CODE f-pi ( f1 -- f2 | f2 = f1 - pi )
     0 [ebx] fld,
     fldpi,
     fsubp,
     0 [ebx] fstp,
END-CODE

\ -------------- FPU Control, Environment, and Status -------

CREATE fpu-control       2 ALLOT
CREATE fpu-env          14 ALLOT
CREATE fpu-state       100 ALLOT

CODE save-fpu
	fpu-state #@  fsave,
	fpu-state #@  frstor,	
END-CODE

CODE test-fpu-control
	fpu-control #@ fstcw,
	fpu-control #@ fldcw,
END-CODE

CODE test-fpu-env
	fpu-env #@ fstenv,
	fpu-env #@ fldenv,
END-CODE

\ ------------ FP BCD Output -------------------------
	
CREATE fbcd 10 ALLOT  \ binary coded decimal rep of fp number

CODE save-bcd
	fbcd #@  fbstp,
	fbcd #@  fbld,
END-CODE


\ ----------- Complex Number Examples ---------------

\ hard-coded for 8-byte fp numbers (double precision).

CODE z+  ( z1 z2 -- z3 | add two complex numbers from top of Forth stack )
	 0 [ebx] fld,
	16 [ebx] fld,
	 8 [ebx] fld,
	24 [ebx] fld,
	16 # ebx add,
	         faddp,
	 8 [ebx] fstp,
    	         faddp,
	 0 [ebx] fstp,
END-CODE


MACRO: cmplx_mul, ( -- | multiply two complex numbers on the fpu stack)
	0 st fld,
	3 st fmul,
	     fchs,
	4 st fld,
	3 st fmul,
	     faddp,
	4 st fxch,	
	     fmulp,
	2 st fxch,
	     fmulp,
	     faddp,
END-MACRO


CODE z*  ( z1 z2 -- z3 | multiply two complex numbers from top of Forth stack )
	24 [ebx] fld,
	16 [ebx] fld,
	 8 [ebx] fld,
	 0 [ebx] fld,
	16 # ebx add,
	   cmplx_mul,
	0 [ebx] fstp,
	8 [ebx] fstp,
END-CODE


\ Following does not work yet. There is a problem in adding
\   new items to the top of the stack with the current interface
\   -- km 2004-10-20

CODE put-num ( ... -- ... 123 | put number 123 on stack)
	4 #  ebx sub,
	123 # 0 [ebx] mov,
END-CODE


