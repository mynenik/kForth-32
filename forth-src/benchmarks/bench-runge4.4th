\ bench-runge4.4th
\
\ Compare execution times for pure Forth version of Lorenz ODE solver
\ with hybrid Forth-Assembly version of Lorenz ODE solver
\
\ K. Myneni, 2020-09-18
\

include ans-words
include modules.fs
include syscalls
include mc
include asm
include strings
include fsl/fsl-util
include fsl/dynmem

\  Integrate the Lorenz equations,
\
\       dx/dt = sig * (y - x)
\       dy/dt = r * x - y - x * z
\       dz/dt = -bp * z + x * y
\
\  with the following parameters,
\
\       sig = 16, r = 45.92, bp = 4
\
\  and the following initial values,
\
\      x(t = 0) = 0
\      y(t = 0) = 1
\      z(t = 0) = 0

1000000 value nsteps
17 set-precision

cr .( Benchmark: Integrate the Lorenz equations with combination of Forth/Assembly )
cr .( using ) nsteps . .( steps and fixed-step RK4 integrator ) 
cr

\ Forth source derivatives

16.0E0  FCONSTANT sig
45.92E0 FCONSTANT r
4.0E0   FCONSTANT bp

: derivs() ( ft 'u 'dudt -- )

       2SWAP FDROP     \ does not use t

       >R       \ 'u
       DUP DUP 1 } F@ ROT 0 } F@ F- sig F*
       R@ 0 } F!

       DUP 2DUP 2 } F@ FNEGATE r F+
       ROT      0 } F@ F*
       ROT      1 } F@ F-
       R@ 1 } F!

       DUP 2DUP 0 } F@ ROT 1 } F@ F* ROT 2 } F@ bp F* F-
       R> 2 } F!
       DROP
;

\ Assembler source derivatives

fvariable FC_sig  sig FC_sig f!
fvariable FC_r      r FC_r   f!
fvariable FC_bp    bp FC_bp  f!

CODE derivs_c ( t 'u 'dudt -- )
     0 [ebx]  edx mov,   \ edx = 'dudt
     TCELL #  ebx add,
     0 [ebx]  ecx mov,   \ ecx = 'u
     TCELL #  ebx add,
     DFLOAT # ebx add,   \ drop t; equations do not use t
     DFLOAT [ecx] fld,   \ st0 = y
     0      [ecx] fld,   \ st0 = x; st1 = y
     1 st         fld,   \ st0 = y; st1 = x; st2 = y
     1 st         fld,   \ st0 = x; st1 = y; st2 = x; st3 = y
                  fsubp, \ st0 = y-x; st1 = x; st2 = y
     FC_sig #@    fld,
                  fmulp,
     0 [edx]      fstp,  \ dxdt{0} = sig*(y - x); st0 = x; st1 = y
  2 DFLOATS [ecx] fld,   \ st0 = z; st1 = x; st2 = y
     FC_r #@      fld,
     1 st         fld,
                  fsubp,  \ st0 = r-z; st1 = z; st2 = x; st3 = y
     2 st         fld,
                  fmulp,  \ st0 = (r-z)*x; st1 = z; st2 = x; st3 = y
     3 st         fld,
                  fsubp,  \ st0 = (r-z)*x-y; st1 = z; st2 = x; st3 = y
  DFLOAT [edx]    fstp,   \ dudt{1} = (r-z)*x-y; st0 = z; st1 = x; st2 = y
     FC_bp #@     fld,
                  fmulp,  \ st0 = bp*z; st1 = x; st2 = y
      2 st        fxch,
                  fmulp,
                  fsubp,
                  fchs,
  2 DFLOATS [edx] fstp,   \ dudt{2} = y*x - bp*z
END-CODE

3 float array x{

: print-x ( -- ) 
    x{ 0 } f@ fs. 2 spaces x{ 1 } f@ fs. 2 spaces x{ 2 } f@ fs. ;

FVARIABLE  _dt
1e-4 _dt F!

: dt   _dt F@ ;
: dt!  _dt F! ;

defer rk4_init
defer rk4_integrate
defer rk4_done

: lorenz ( nsteps xt -- )
     0e x{ 0 } F!   1e x{ 1 } F!   0e x{ 2 } F!  \ initial conditions
     3 rk4_init
     >r
     0e       \ t0
     r> 0 DO
        dt x{ 1 rk4_integrate
     LOOP
     FDROP
     rk4_done ;

cr .( Case 1: Forth Source Only: Derivatives and RK4 Integrator )
cr .( Loading the Forth-source RK4 integrator )
>file /dev/null
include fsl/runge4
console
cr
' )runge_kutta4_init is rk4_init
' runge_kutta4_integrate() is rk4_integrate
' runge_kutta4_done is rk4_done
ms@ nsteps ' derivs() lorenz ms@ swap - . .(  ms ) cr
.( x_final = { ) print-x .(  } ) cr

cr .( Case 2: Forth Derivatives and Hybrid RK4 Integrator )
cr .( Loading Hybrid RK4 integrator )
>file /dev/null 
include fsl/extras/runge4-x86
console
cr
' )runge_kutta4_init is rk4_init
' runge_kutta4_integrate() is rk4_integrate
' runge_kutta4_done is rk4_done
ms@ nsteps ' derivs() lorenz ms@ swap - . .(  ms ) cr
.( x_final = { ) print-x .(  } ) cr

cr .( Case 3: Assembler Derivatives and Hybrid RK4 Integrator )
cr
: derivs() derivs_c ;
ms@ nsteps ' derivs() lorenz ms@ swap - . .(  ms ) cr
.( x_final = { ) print-x .(  } ) cr





