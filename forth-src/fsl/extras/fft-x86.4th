\ fft-x86.4th
\
\ Compute the Fourier transform of a 1 dimensional array of complex numbers.
\ The FFT routine is hand-coded in assembly as a CODE word callable from
\ Forth. This implementation is based on the routine four1() from Numerical Recipes 
\ in C, 2nd ed., by W.H. Press, S. A. Teukolsky, W. T. Vetterling, and
\ B. P. Flannery, Cambridge University Press, 1992.
\
\ Copyright (c) 2001,2006 Krishna Myneni
\ Original code Copyright (c) Numerical Recipes Software
\
\ Notes:
\
\ (0) Uses the assembler syntax for asm-x86 (see asm-x86.4th).
\
\ (1) The arguments to FFT are the number of points, i.e. the number of 
\       complex numbers, and the address of the first element in the
\       array. The arguments are passed of the Forth stack.
\
\ (2) The transformed data is ordered in the manner described in Press, et.
\       al.
\
\ Revisions:
\
\  2001-08-07  original version written for GNU assembler  km
\  2006-03-16  ported to asm-x86 for use with kForth.  km
\
4 constant WSIZE
8 constant DSIZE

fvariable Wpr
fvariable Wpi
fvariable Wr
fvariable Wi

variable ICONST_TWO  2 ICONST_TWO !
variable  Npts
variable  Nvals
variable  Mmax
variable  Istep


CODE cmplx_mul
	  0  st   fld,
	  3  st   fmul,
	          fchs,
	  4  st   fld,
	  3  st   fmul,
	          faddp,
	  4  st   fxch,	
	          fmulp,
	  2  st   fxch,
	          fmulp,
	          faddp,
END-CODE


CODE store_new
	edx  edi  mov,
	     edi  inc,		
	3 #  edi  shl,
	ebx  edi  add,		\ edi has address of data[i+1]
	  0 [edi] fld,		\ load data[i+1] into co-processor
	  0  st   fld,
	  2  st   fld,		
	          fsubrp,
	  0 [eax] fstp,		\ store new data[j+1]	
	          faddp,
	  0 [edi] fstp,		\ store new data[i+1]
	DSIZE # edi sub,	\ edi has address of data[i]
	DSIZE # eax sub,	\ ebp has address of data[j] 
	  0 [edi] fld,
	  0  st   fld,
	  2  st   fld,
	          fsubrp,
	  0 [eax] fstp,		\ store new data[j]
	          faddp,
	  0 [edi] fstp,		\ store new data[i]
END-CODE     
     

MEDIUM-CODE fft  ( npts addr -- )
	     ebp  push,
             edi  push,
	     esi  push,
     0 [ebx] ecx  mov,    
     WSIZE # ebx  add,
     0 [ebx] eax  mov,    \ Npts in eax
     WSIZE # ebx  add,
             ebx  push,
     ecx     ebx  mov,    \ data address in ebx 
     eax Npts #@  mov,
     1 # eax      shl,
     eax Nvals #@ mov,
     0 # edi      mov,
     Nvals #@ ecx mov,
     esi esi      xor,

     DO,
       esi edi     cmp,
       >, IF,      
         esi eax     mov,
         edi edx     mov,
         3 # eax     shl,
         3 # edx     shl,
         ebx eax     add,
         ebx edx     add,
         0 [edx] ebp mov,
         ebp 0 [eax] xchg,
         ebp 0 [edx] mov,
         WSIZE # eax add,
         WSIZE # edx add,
         0 [edx] ebp mov,
         ebp 0 [eax] xchg,
         ebp 0 [edx] mov,
         WSIZE # eax add,
         WSIZE # edx add,
         0 [edx] ebp mov,
         ebp 0 [eax] xchg,
         ebp 0 [edx] mov,
         WSIZE # eax add,
         WSIZE # edx add,
         0 [edx] ebp mov,
         ebp 0 [eax] xchg,
         ebp 0 [edx] mov,
       THEN,

       Npts #@ eax   mov,

Label: bl2

       2 # eax cmp,
       <, IF,
         jmp-from bl3
       THEN,
       eax edi cmp,
       <, IF,
         jmp-from bl3b
       THEN,
       eax edi sub,
       1 # eax shr,        
       bl2     jmp,       
bl3    jmp-to
bl3b   jmp-to
       eax edi add,
       esi     inc,
       esi     inc,
       ecx     dec,
     LOOP,

\ End of bit-reversal section

     2 # Mmax #@ mov,

Label: dl_outerloop
     Mmax #@ eax mov,
     Nvals #@ eax cmp,
     <, IF,
       jmp-from dl2
     THEN,
     jmp-from end_fft

dl2  jmp-to

     1 # eax shl,
     eax Istep #@ mov,

	    fldpi,
     0 st   fld,
	    faddp,
     Mmax #@ fidiv,
     0 st   fld,
     ICONST_TWO #@ fidiv,
            fsin,
     0 st   fld,
            fmulp,
     0 st   fld,
	    faddp,
            fchs,
     Wpr #@ fstp,
	    fsin,
     Wpi #@ fstp,

     Wr # ecx mov,
	    fld1,
     0 [ecx] fstp,
     Wi # ecx mov,
	    fldz,
     0 [ecx] fstp,
	 
     Mmax #@ ecx mov,
     eax eax xor,
  
   
     DO,
       eax edx mov,  \ eax is index of first loop (m), edx is index of 2nd loop (i)
       Wr #@ fld,
       Wi #@ fld,
         eax push,

Label: dl_secondloop

       edx eax mov,   
       Mmax #@ eax add,
       3 # eax shl,
       ebx eax add,
	   
       1 st  fld,
       1 st  fld,

       0 [eax] fld,
       DSIZE # eax add,
       0 [eax] fld,

       call-code cmplx_mul
       call-code store_new 

       Istep #@ edx add,
       Nvals #@ edx cmp,
       <, IF,
         dl_secondloop # jmp,
       THEN,

       eax pop,

       1 st  fld,
       1 st  fld,
       Wpr #@ fld,
       Wpi #@ fld,

       call-code cmplx_mul 

       3 st  fxch,
	     faddp,
       Wr #@ fstp,
             faddp,
       Wi #@ fstp,

       2 # eax add,
       ecx     dec,
     LOOP,

     Istep #@ eax mov,
     eax Mmax #@  mov,
	 
     dl_outerloop # jmp,

end_fft  jmp-to       
     eax eax xor,
     ebx     pop,
     esi     pop,
     edi     pop,
     ebp     pop,
END-CODE
