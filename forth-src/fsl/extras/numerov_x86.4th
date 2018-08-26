\ numerov_x86.4th
\
\ Double/Extended-precision Numerov integrator in asm-x86 assembler.
\
\ Copyright (c) 2015 Krishna Myneni, http://ccreweb.org
\
\ This module may be used as a drop-in replacement for numerov.4th.
\
\ Requires:
\   asm-x86.4th
\   fpu-x86.4th
\
\ Revisions:
\   2015-02-10  km; created.

BEGIN-MODULE

Private:

4 constant WSIZE
8 constant DSIZE

variable IC_TWO   2 IC_TWO !
variable IC_TEN  10 IC_TEN !

variable Q[
variable P[
variable Npts
fvariable f

CODE numerov_x86_integrate ( aP aQ n h -- )
          0 [ebx]  fld,
          0 st     fld,
                   fmulp,
     12 # 0 [ebx]  mov,
          0 [ebx]  fidiv,   \ st(0) = h^2/12   
     DSIZE #  ebx  add,
      0 [ebx] ecx  mov,
      ecx Npts #@  mov,
     WSIZE #  ebx  add,
      0 [ebx] ecx  mov,
       ecx  Q[ #@  mov,
     WSIZE #  ebx  add,
      0 [ebx] edx  mov,
       edx  P[ #@  mov,
     WSIZE #  ebx  add,
                   fld1,   \ st(0)=1, st(1)=h^2/12
          1 st     fld,
          0 [ecx]  fld,
                   fmulp,
                   fsubp,
          0 [edx]  fld,
                   fmulp,   \ st(0)=F_n-2, st(1)=h^2/12
      DSIZE [ecx]  fld,
          2 st     fld,
                   fmulp,   \ st(0)=T_n
                   fld1,
          1 st     fld,
                   fsubp,
      DSIZE [edx]  fld,
                   fmulp, \ st(0)=F_n-1, st(1)=T_n, st(2)=F_n-2, st(3)=h^2/12
              ebx  push,
      Npts #@ ecx  mov,
         2 #  ecx  sub,
        Q[ #@ ebx  mov,  \ current Q element addr in ebx
   DSIZE 2* # ebx  add,
        P[ #@ edx  mov,
   DSIZE 2* # edx  add,  \ current P element addr in edx

               DO,
                 3 st    fld,
                 0 [ebx] fmul,  \ st(0)=T_n+1, st(1)=F_n-1, st(2)=T_n, st(3)=F_n-2,  
                                \ st(4)=h^2/12                
                 1 st   fxch,
                 2 st    fld,
            IC_TEN #@  fimul,
            IC_TWO #@  fiadd,  \ st(0)=q3,    st(1)=F_n-1, st(2)=T_n+1, st(3)=T_n,
                               \ st(4)=F_n-2, st(5)=h^2/12
                  1 st  fmul,  \ st(0) = q4,    st(1) = F_n-1, st(2)=T_n+1, st(3)=T_n,
                               \ st(4) = F_n-2, st(5) = h^2/12
                        fld1,  
                  4 st  fsub,  \ st(0)=1-T_n, st(1)=q4, st(2)=F_n-1, st(3)=T_n+1,
                               \ st(4)=T_n,   st(5)=F_n-2, st(6)=h^2/12
                       fdivp,
                  4 st  fsub,  \ st(0)=F_n,   st(1)=F_n-1, st(2)=T_n+1, st(3)=T_n,   
                               \ st(4)=F_n-2, st(5)=h^2/12
                        fld1,
                  3 st  fld,
                        fsubp, \ st(0)=1-T_n+1, st(1)=F_n,   st(2)=F_n-1, st(3)=T_n+1, 
                               \ st(4)=T_n,     st(5)=F_n-2, st(6)=h^2/12
                  1 st   fld, 
                      fdivrp,  \ st(0)=new P, st(1)=F_n,   st(2)=F_n-1, st(3)=T_n+1, 
                               \ st(4)=T_n,   st(5)=F_n-2, st(6)= h^2/12
                0 [edx] fstp,  \ st(0) = F_n, st(1) = F_n-1, st(2) = T_n+1, st(3) = T_n,
                               \ st(4) = F_n-2, st(5) = h^2/12
                3 st    fxch,
                   f #@ fstp,  \ remove T_n from stack
                3 st    fxch,   
                   f #@ fstp,  \ remove F_n-2 from stack
                1 st    fxch,  \ st(0)=F_n, st(1)=T_n+1, st(2)=F_n-1, st(3)=h^2/12
                DSIZE # ebx add,
                DSIZE # edx add,
              LOOP,

             faddp,
             faddp,
             faddp,
             f #@  fstp,
             ebx pop,
END-CODE

Public:

: numerov_integrate ( 'P 'Q n h -- )
    2>r >r 0 } swap 0 } swap r> 2r>

    \ set extended precision
    FPU_CW_PREC_EXTENDED  FPU_CW_PREC_MASK modifyFPUStateX86

    numerov_x86_integrate

    \ restore double precision
    FPU_CW_PREC_DOUBLE   FPU_CW_PREC_MASK  modifyFPUStateX86
;

END-MODULE

