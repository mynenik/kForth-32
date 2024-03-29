\ runge4-x86.4th    Runge-Kutta ODE Solver for systems of ODEs
\
\ Forth Scientific Library Algorithm #29
\   Adapted for integrated fp/data stack Forths (km 2003-03-18)
\
\ )runge_kutta4_init ( 'dsdt n -- )
\               Initialize to use function dsdt() for n equations,
\               its stack diagram is:
\                      dsdt() ( ft 'u 'dudt -- ) 
\               (the values in the array dudt get changed)
\
\ runge_kutta4_integrate() ( t dt 'u steps -- t' )
\               Integrate the equations STEPS time steps of size DT,
\               starting at time T and ending at time T'.  U is the
\               initial condition on input and the new state of the 
\               system on output.

\ runge_kutta4_done  ( -- )
\               Release previously allocated space.

\ )rk4qc_init ( maxstep eps 'dsdt n 's -- )
\               Initialize to use function dsdt() for n equations.
\               The initial function values are in s{. The output is also
\		in s{. The result is computed with a 5th-order Runge-Kutta
\ 		routine with adaptive step size control. The step size 
\		controller tries to keep the fractional error of any s{ 
\		component below eps. The maximum step size is limited to 
\		maxstep .
\
\ rk4qc_done  ( -- )
\               Release previously allocated space.
\
\ rk4qc_step ( step t -- step' t' flag )
\		Do one Runge-Kutta step, using adaptive step size control.
\		The flag is FALSE if the routine succeeds, else the step size
\		has become too small. The current step size and time are on 
\		the stack and will be updated by the routine.

\ This is an ANS Forth program requiring:
\      1. The Floating-Point word set
\      2. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control visibility of internal code
\      3. The word 'v:' to define function vectors and the
\         immediate 'defines' to set them.
\      4. The immediate words 'use(' and '&' to get function addresses
\      5. The words 'DARRAY' and '&!' to alias arrays.
\      6. Uses '}malloc' and '}free' to allocate and release memory
\         for dynamic arrays ( 'DARRAY' ).
\      7. The compilation of the test code is controlled by the VALUE
\         TEST-CODE? and the conditional compilation words in the
\          Programming-Tools wordset.
\      8. To run the code the fp stack needs to be at least 5 deep.
\	  To run all examples you need 7 positions on the fp stack.
\
\     (c) Copyright 1994  Everett F. Carter.     Permission is granted
\     by the author to use this software for any application provided
\     this copyright notice is preserved.

\  Revisions:
\     ?           mh; adaptive code was contributed by Marcel Hendrix
\
\     2007-09-23  km; added automated testing and a few of the Enright
\                     and Pryce test cases (see notes in test sec.).
\     2007-09-24  km; changed some "}t" to "r}t" tests for consistency with
\                     unified stack systems.
\     2007-09-27  km; cleaned up the test code, using a consistent format for
\                     both the E&P and non E&P tests; renamed rksolve1 and
\                     rksolve2 to )rksolve1 and )rksolve2 for better syntax,
\                     and added )rk_fixed1 and )rk_fixed2 wrappers for the
\                     fixed step size tests.
\     2007-10-27  km; save base, switch to decimal, and restore base
\     2011-09-16  km; use Neal Bridges' anonymous modules.
\     2012-02-19  km; use KM/DNW's modules library
CR .( RUNGE4            V1.2f         19 February  2012   EFC )
BEGIN-MODULE

BASE @ DECIMAL

Private:

Defer dsdt()                     \ pointer to user function t, u, dudt

FLOAT DARRAY dum{             \ scratch space
FLOAT DARRAY dut{
FLOAT DARRAY ut{
FLOAT DARRAY dudt{

FVARIABLE h

FLOAT DARRAY u{               \ pointer to user array

0 VALUE dim


Public:


: )runge_kutta4_init ( &dsdt n -- )
     TO dim
     is dsdt()


     & dum{ dim }malloc
     malloc-fail? ABORT" runge_init failure (1) "

     & dut{ dim }malloc
     malloc-fail? ABORT" runge_init failure (2) "

     & ut{ dim }malloc
     malloc-fail? ABORT" runge_init failure (3) "

     & dudt{ dim }malloc
     malloc-fail? ABORT" runge_init failure (4) "

;

: runge_kutta4_done ( -- )

     & dum{ }free
     & dut{ }free
     & ut{ }free
     & dudt{ }free
;

Private:

0 [IF]

: runge4_step ( t -- t' )

     FDUP u{ dudt{ dsdt()         \ -- t

     h F@ F2/                     \ -- t h/2
     dim 0 DO
             dudt{ I } F@ FOVER F* u{ I } F@ F+
             ut{ I } F!
            LOOP                  \ -- t h/2

     FOVER F+ ut{ dut{ dsdt()     \ -- t

     h F@ F2/                     \ -- t h/2
     dim 0 DO
             dut{ I } F@ FOVER F* u{ I } F@ F+
             ut{ I } F!
            LOOP                  \ -- t h/2

     FOVER F+ ut{ dum{ dsdt()     \ -- t

     h F@                         \ -- t h
     dim 0 DO
             dum{ I } F@ FOVER F* u{ I } F@ F+
             ut{ I } F!

             dum{ I } DUP F@ dut{ I } F@ F+ ROT F!             

           LOOP                  \ -- t h

     F+                          \ -- t+h

     FDUP ut{ dut{ dsdt()        \ -- t+h

     h F@ 6.0E0 F/               \ -- t+h h/6
     dim 0 DO
              dudt{ I } F@ dut{ I } F@ F+
              dum{ I } F@ F2* F+
              FOVER F*
              u{ I } DUP >R F@ F+ R> F!
           LOOP                 \ -- t+h h/6

     FDROP                      \ -- t+h
;

[ELSE]

fvariable temph

CODE runge4_step_l1 ( h/2 dim ut{ du{ u{ -- )
                 ebp push,
         0 [ebx] edx mov,   \ edx = u{
         TCELL # ebx add,   
         0 [ebx] eax mov,   \ eax = du{
         TCELL # ebx add,
         0 [ebx] ebp mov,   \ ebp = ut{
         TCELL # ebx add,
         0 [ebx] ecx mov,   \ ecx = dim
         TCELL # ebx add,
         0 [ebx]     fld,   \ st0 = h/2
       DFLOAT #  ebx add,
                 ebx push,
         ebp     ebx mov,
         DO,
           0 [eax]   fld,  \ st0 = du{I}; st1 = h/2   
           1 st      fld,
                     fmulp,
           0 [edx]   fld,
                     faddp,
           0 [ebx]   fstp,
           DFLOAT # eax add,
           DFLOAT # edx add,
           DFLOAT # ebx add,
         LOOP,
         temph #@    fstp,  \ pop the h/2 off fpu stack                 
                 ebx pop,
                 ebp pop,
         eax     eax xor,
END-CODE

CODE runge4_step_l2 ( h dim ut{ dut{ dum{ u{ -- )
                 ebp push,
                 esi push,
         0 [ebx] edx mov,   \ edx = u{
         TCELL # ebx add,
         0 [ebx] eax mov,   \ eax = dum{
         TCELL # ebx add,
         0 [ebx] esi mov,
         TCELL # ebx add,
         0 [ebx] ebp mov,   \ ebp = ut{
         TCELL # ebx add,
         0 [ebx] ecx mov,   \ ecx = dim
         TCELL # ebx add,
         0 [ebx]     fld,   \ st0 = h
       DFLOAT #  ebx add,
                 ebx push,
         esi     ebx mov,   \ ebx = dut{
         DO,
            0 [eax] fld,  \ st0 = dum{I}; st1 = h
            1 st    fld,  \ st0 = h; st1 = dum{I}; st2 = h
            1 st    fld,
                    fmulp,
            0 [edx] fld,
                    faddp,
            0 [ebp] fstp,  \ st0 = dum{I}; st1 = h
            0 [ebx] fld,
                    faddp,
            0 [eax] fstp,
            DFLOAT # eax add,
            DFLOAT # ebx add,
            DFLOAT # ebp add,
            DFLOAT # edx add,
          LOOP,
          temph #@   fstp,
                 ebx pop,
                 esi pop,
                 ebp pop,
          eax    eax xor,
END-CODE

CODE runge4_step_l3 ( h/6 dim dudt{ dut{ dum{ u{ -- )
                 ebp push,
                 esi push,
         0 [ebx] edx mov,   \ edx = u{
         TCELL # ebx add,
         0 [ebx] eax mov,   \ eax = dum{
         TCELL # ebx add,
         0 [ebx] esi mov,
         TCELL # ebx add,
         0 [ebx] ebp mov,   \ ebp = dudt{
         TCELL # ebx add,
         0 [ebx] ecx mov,   \ ecx = dim
         TCELL # ebx add,
         0 [ebx]     fld,   \ st0 = h/6
       DFLOAT #  ebx add,
                 ebx push,
         esi     ebx mov,   \ ebx = dut{
         DO,
           0 [ebp]   fld,
           0 [ebx]   fld,
                     faddp,
           0 [eax]   fld,
                     fld1,
                     fld1,
                     faddp,
                     fmulp,
                     faddp,
           1 st      fld,
                     fmulp,
           0 [edx]   fld,
                     faddp,
           0 [edx]   fstp,
           DFLOAT # eax add,
           DFLOAT # ebx add,
           DFLOAT # ebp add,
           DFLOAT # edx add,
         LOOP,
         temph #@  fstp,
                   ebx pop,
                   esi pop,
                   ebp pop,
         eax       eax xor,
END-CODE

: runge4_step ( t -- t' )
     FDUP u{ dudt{ dsdt()                  \ t
     h F@ F2/                              \ t h/2
     fdup dim ut{ dudt{ u{ runge4_step_l1  \ t h/2
     FOVER F+ ut{ dut{ dsdt()              \ t
     h F@ F2/                              \ t h/2
     fdup dim ut{ dut{ u{ runge4_step_l1   \ t h/2
     FOVER F+ ut{ dum{ dsdt()              \ t
     h F@                                  \ t h
     fdup dim ut{ dut{ dum{ u{ runge4_step_l2  \ t h
     F+                                    \ t+h 
     FDUP ut{ dut{ dsdt()                  \ t+h
     h F@ 6.0E0 F/                         \ t+h h/6
     fdup dim dudt{ dut{ dum{ u{ runge4_step_l3 
     FDROP                                 \ t+h
;

[THEN]


Public:


: runge_kutta4_integrate() ( t dt &u steps -- t')
     SWAP & u{ &!
     >R h F! R>
     0 ?DO runge4_step LOOP
;



Private:
	 1E-30 	   FCONSTANT tiny
	-0.20E0    FCONSTANT pgrow
	-0.25E0    FCONSTANT pshrink
	1e 15E0 F/ FCONSTANT fcor
	  0.9E0    FCONSTANT safety

4E0 safety F/  
1E0 pgrow  F/ F**  FCONSTANT errcon

FVARIABLE eps
FVARIABLE step
FVARIABLE tstart
FVARIABLE maxstep

FLOAT DARRAY uorig{
FLOAT DARRAY u1{
FLOAT DARRAY u2{
FLOAT DARRAY uscal{


\ Find reasonable scaling values to decide when to shrink step size.
: scale'm ( -- )
	tstart F@ uorig{ uscal{ dsdt()	
	dim 0 ?DO uscal{ I } DUP F@ step F@ F* FABS
		  uorig{ I }     F@ FABS F+ tiny F+
		  ROT F!		 
	    LOOP ;

\ With a trick the result of a step can be made accurate to 5th order.
: 4th->5th ( -- )
	dim 0 DO 		\ get 5th order truncation error
		 uorig{ I } DUP F@  FDUP  
	         u1{ I }    F@ F-  fcor F* 
		 F+  ROT F! 
	    LOOP ;

\ Test if the step size needs shrinking
: shrink? ( -- diff bool )
	0.0E0 ( errmax )
	dim 0 DO  
		uorig{ I } F@  u1{ I } F@  F-  
		uscal{ I } F@  F/  FABS FMAX  
	    LOOP  
	eps F@ F/  FDUP 1e F> ;

Public:

\ Initialize to use function dsdt() for n equations. The initial function 
\ values are in s{. The output is also in s{. The result is computed with a 
\ 5th-order Runge-Kutta routine with adaptive step size control. The step size 
\ controller tries to keep the fractional error of any s{ component below eps.
\ The maximum step size is limited to maxstep .
: )rk4qc_init	   ( maxstep eps 'dsdt n 'u -- )
	& uorig{ &! 
	)runge_kutta4_init
	& u1{    dim }malloc malloc-fail? ABORT" )rk4qc_init :: malloc (1)" 
	& u2{    dim }malloc malloc-fail? ABORT" )rk4qc_init :: malloc (2)" 
	& uscal{ dim }malloc malloc-fail? ABORT" )rk4qc_init :: malloc (3)" 
	eps F! maxstep F! ;

\ Release previously allocated space.
: rk4qc_done  ( -- )
	runge_kutta4_done
	& u1{    }free 
	& u2{    }free 
	& uscal{ }free ;
\ Do one Runge-Kutta step, using adaptive step size control. The flag is 
\ FALSE if the routine succeeds, else the step size has become too small. 
\ The current step size and time are on the stack and will
\ be updated by the routine.

: rk4qc_step ( step t -- step' t' flag )
	tstart F!  step F!  scale'm
	uorig{ u1{ dim }fcopy	\ we need a fresh start after a shrink
	uorig{ u2{ dim }fcopy
   BEGIN	
	tstart F@ step F@ F2/ uorig{ 2 runge_kutta4_integrate() FDROP
	tstart F@ step F@ u1{    1     runge_kutta4_integrate() (  -- t' )
	FDUP tstart F@ 0.0E0 F~ IF 0.0E0 FSWAP FALSE EXIT THEN
	shrink?			\ maximum difference between these two tries
   WHILE			\ too large, shrink step size
	FLN pshrink F* FEXP step F@ F* safety F* step F!  FDROP
	u2{ uorig{ dim }fcopy	\ a fresh start after a shrink...
	u2{ u1{    dim }fcopy

  REPEAT			\ ok, grow step size for next time
	FDUP errcon F< IF  FDROP step F@ 4e F* 
		     ELSE  FLN pgrow F* FEXP step F@ F* safety F*
		     THEN 
	maxstep F@ FMIN		\ but don't grow excessively!
	FSWAP TRUE 4th->5th ;

BASE !
END-MODULE
    
TEST-CODE? [IF]     \ test code ==========================================
[undefined] T{      [IF]  include ttester.4th  [THEN]
BASE @ DECIMAL

\ Generic Test Wrappers for the Adaptive and Fixed Step Solvers

3 FLOAT ARRAY x{

FVARIABLE  _dt
FVARIABLE  t_end
FVARIABLE  t_final

\ Generic one equation ODE solver (adaptive step size)
FVARIABLE t_start
: )rksolve1 ( 'dsdt tstart tend y0 -- r )
    x{ 0 } F! t_end F! t_start F! >R
    _dt F@ rel-near F@ R> 1 x{ )rk4qc_init
    _dt F@ t_start F@ BEGIN  rk4qc_step 0= >R FDUP t_end F@ F>= R> OR UNTIL
    t_final F! FDROP  rk4qc_done  x{ 0 } F@   
;

\ Generic two equations ODE solver (adaptive step size)
: )rksolve2 ( 'dsdt tstart tend x0 y0 -- r )
    x{ 1 } F! x{ 0 } F! t_end F! t_start F! >R
    _dt F@ rel-near F@ R> 2 x{ )rk4qc_init
    _dt F@ t_start F@ BEGIN  rk4qc_step 0= >R FDUP t_end F@ F>= R> OR UNTIL
    t_final F! FDROP  rk4qc_done  x{ 0 } F@   
;

\ Generic one equation ODE solver (fixed step size)
: )rk_fixed1 ( 'dsdt nsteps tstart y0 -- r ) 
    x{ 0 } F! t_start F!
    SWAP 1 )runge_kutta4_init >R
    t_start F@ _dt F@ x{ R> runge_kutta4_integrate()
    t_final F! runge_kutta4_done  x{ 0 } F@   
;

\ Generic two equations ODE solver (fixed step size)
: )rk_fixed2 ( 'dsdt nsteps tstart x0 y0 -- r )
    x{ 1 } F! x{ 0 } F! t_start F!
    SWAP 2 )runge_kutta4_init >R
    t_start F@ _dt F@ x{ R> runge_kutta4_integrate()
    t_final F! runge_kutta4_done  x{ 0 } F@   
;

\ The test cases here were originally given by Wayne Enright and John Pryce,
\ Algorithm 648, ACM Transactions on Mathematical Software, volume 13, no. 1,
\ pp 28--34, 1987.
\
\ Also, see
\
\ http://people.scs.fsu.edu/~burkardt/f_src/test_ode/test_ode.html

\ E & P nonstiff problem #A1:
\ dy/dt = -y
\ y(0) = 1
\ Exact solution is y(t) = exp(-t)
\ : derivs-A1() ( t 'y 'dydt -- )
\   >R 0 } F@  FNEGATE R> 0 } F! FDROP ;

CODE derivs-A1c  ( t 'y 'dydt -- )
    0 [ebx]  ecx mov,  \ ecx = 'dydt
    TCELL #  ebx add,
    0 [ebx]  edx mov,  \ edx = 'y
    TCELL #  ebx add,
    DFLOAT # ebx add,
    0 [edx]      fld,  \ st0 = y
                 fchs,
    0 [ecx]      fstp, \ dy/dt{ 0 } = -y
END-CODE

: derivs-A1() derivs-A1c ;
: A1 ( t -- r ) FNEGATE FEXP ;

\ E & P nonstiff problem #A2:
\ dy/dt = -(y^3)/2
\ y(0) = 1
\ Exact solution is y(t) = 1 / sqrt(t + 1)
\ : derivs-A2() ( t 'y 'dydt -- )
\    >R 0 } F@ FDUP FSQUARE F* FNEGATE 2e F/ R> 0 } F! FDROP ;

CODE derivs-A2c ( t 'y 'dydt -- )
    0 [ebx]  ecx mov,  \ ecx = 'dydt
    TCELL #  ebx add,
    0 [ebx]  edx mov,  \ edx = 'y
    TCELL #  ebx add,
    DFLOAT # ebx add,
    0 [edx]      fld,  \ st0 = y
    0 st         fld,
    0 st         fld,
                 fmulp,
                 fmulp, 
                 fchs,  \ st0 = -y^3 
                 fld1,
                 fld1,
                 faddp,
                 fdivp, 
    0 [ecx]      fstp,  \ dydt{ 0 } = -y^3/2
END-CODE

: derivs-A2() derivs-A2c ;
: A2 ( t -- r )  1e F+ FSQRT 1e FSWAP F/ ;

\ E & P nonstiff problem #A3:
\ dy/dt = cos(t) * y
\ y(0) = 1
\ Exact solution is y(t) = exp( sin( t ) )
\ : derivs-A3() ( t 'u 'dudt -- )
\    >R 0 } F@ FSWAP FCOS F* R> 0 } F! ;

CODE derivs-A3c  ( t 'y 'dydt -- )
    0 [ebx]  ecx mov,  \ ecx = 'dydt
    TCELL #  ebx add,
    0 [ebx]  edx mov,  \ edx = 'y
    TCELL #  ebx add,
    0 [ebx]      fld,  \ st0 = t
    DFLOAT # ebx add,
                 fcos,
    0 [edx]      fld,
                 fmulp,
    0 [ecx]      fstp, \ dydt{ 0 } = y*cos(t)
END-CODE

: derivs-A3() derivs-A3c ;
: A3 ( t -- r )  FSIN FEXP ;

\ E & P nonstiff problem #A4:
\ dy/dt = y*(20 - y)/80
\ y(0) = 1
\ Exact solution is y(t) = 20 / ( 1 + 19*exp( -t / 4 ) )

false [IF]

: derivs-A4() ( t 'y 'dydt -- ) 
    >R 0 } F@ FDUP 20e FSWAP F- F* 80e F/ R> 0 } F! FDROP ;

[ELSE]

variable IC_20  20 IC_20 !
variable IC_80  80 IC_80 !

CODE derivs-A4c ( t 'y 'dydt -- )
    0 [ebx]  ecx  mov,  \ ecx = 'dydt
    TCELL #  ebx  add,
    0 [ebx]  edx  mov,  \ edx = 'y
    TCELL #  ebx  add,
    DFLOAT # ebx  add,
    0 [edx]       fld,
    IC_20 #@      fild,
    1 st          fld,
                  fsubp,
                  fmulp,
    IC_80 #@      fild,
                  fdivp,
    0 [ecx]       fstp,  \ dydt{ 0 } = (20 - y)*y/80
END-CODE
: derivs-A4()  derivs-A4c ;

[THEN]

: A4 ( t -- r )  FNEGATE 4e F/ FEXP 19e F* 1e F+ 20e FSWAP F/ ;

\ E & P nonstiff problem #A5:
\ dy/dt = (y - t)/(y + t)
\ y(0) = 1
\ Exact solution is
\      r = sqrt ( t + y(t)**2 )
\      theta = atan ( y(t) / t )
\
\      r = 4 * exp ( pi/2 - theta )

: derivs-A5() ( t 'u 'dudt -- )
    >R >R FDUP R> 0 } F@ FDUP FROT F- 2>R F+ 2R> F/ R> 0 } F! ;

FVARIABLE r
FVARIABLE theta
: A5 ( t -- r )
    ;

\ ------- Other test cases (not from E & P) ------------
    
\ The RC discharge equation:
\ dVc/dt = (1/tau)*(Vin-Vc)
\ Vc(0) = 0
\ Exact solution is Vc(t) = Vin*( 1 - exp( -t/tau ) )
\ Comments: Don't use the long-time limit solution for accuracy
\   testing, since there is an attracting fixed-point at Vc = Vin.
100E-3  FCONSTANT tau ( tau = R*C; 100 ms for this example)
10E     FCONSTANT Vin ( charging voltage source is 10 Volts)	

false [IF]

: derivs-Vc() ( t 'u 'dudt -- ) 
     >R >R FDROP
     Vin  R> 0 } F@ F-   tau F/  R>  0 } F! ;

[ELSE]

fvariable FC_tau  tau FC_tau f!
fvariable FC_Vin  Vin FC_Vin f!

CODE derivs-Vcc ( t 'Vc 'dVc/dt -- )
    0 [ebx]  ecx mov,  \ ecx = 'dVc/dt
    TCELL #  ebx add,
    0 [ebx]  edx mov,  \ edx = 'Vc
    TCELL #  ebx add,
    DFLOAT # ebx add,
    FC_Vin #@    fld,
    0 [edx]      fld,
                 fsubp,
    FC_tau #@    fld,
                 fdivp,
    0 [ecx]      fstp,
END-CODE
: derivs-Vc()  derivs-Vcc ;

[THEN]

: VC ( t -- v )  1e  FSWAP FNEGATE tau F/ FEXP  F-  Vin F* ; 

\ Damped vibrations:
\ u'' + cm*u' + km*u = 0
\ or  du/dt = v,  dv/dt = -cm*v - km*u
\ u(0) = 1/{2*pi}
\ v(0) = -cm/{4*pi}
\ Exact solution for u(t) is:
\ u(t) = (1/2pi)*exp{-cm*t/2}*cos(sqrt{km - cm^2/4}*t)
\ Comments: Don't use the long-time limit solution for accuracy
\   testing, since there is an attracting fixed-point at u = 0.
1.0E0 FATAN 8.0E0 F* FCONSTANT PI*2

1.92E0  FCONSTANT cm
960.0E0 FCONSTANT km
    
1e PI*2 F/ FCONSTANT u0
cm FNEGATE F2/ PI*2 F/ FCONSTANT v0

0 [IF]

: derivs-DV() ( t 'u 'dudt -- ) 
    >R >R FDROP     \ does not use t
    R@ 1 } F@ 2R@ DROP 0 } F!
    R@ 1 } F@ cm  F*
    R> 0 } F@ km  F* F+ FNEGATE
    R> 1 } F!   
;

[ELSE]

fvariable FC_cm  cm FC_cm f!
fvariable FC_km  km FC_km f!

CODE derivs-DVc  ( t 'x  'dx/dt -- )
    0 [ebx]   ecx  mov,  \ ecx = 'dx/dt
    TCELL #   ebx  add,
    0 [ebx]   edx  mov,  \ edx = 'x
    TCELL #   ebx  add,
    DFLOAT #  ebx  add,
    DFLOAT [edx]   fld,
    0 st           fld,
    0 [ecx]        fstp, \ dx{0}/dt = x{1}
    FC_cm #@       fld,
                   fmulp,
    0 [edx]        fld,
    FC_km #@       fld,
                   fmulp,
                   faddp,
                   fchs,
    DFLOAT [ecx]   fstp, \ dx{1}/dt = -(cm*x{1} + km*x{0})
END-CODE
: derivs-DV()  derivs-DVc ;

[THEN]
: DV ( t -- a )             \ just the U value not V for damped vib.
    cm FOVER F* F2/ FNEGATE FEXP
    FSWAP
    cm cm F* 4.0E0 F/ FNEGATE km F+ FSQRT
    F* FCOS
    F* PI*2 F/
;

\ Lorenz equations for chaos:
\ dx/dt = sig * (y - x)
\ dy/dt = r * x - y - x * z
\ dz/dt = -bp * z + x * y
\ Exact solution: NONE
\ Comments: Since chaotic equations are extremely sensitive to
\   initial conditions, the result after integration will
\   depend very sensitively on the precision of the input values
\   x(t0), y(t0), and z(t0), and on the precision with which
\   floating point calculations are performed. Such sensitivity is
\   not useful for directly testing the accuracy of a portable ODE
\   solver; however, some invariant properties of the attractor can
\   be computed from the solution, and may possibly serve as suitable
\   tests of the ODE solver. 
16.0E0  FCONSTANT sig
45.92E0 FCONSTANT r
4.0E0   FCONSTANT bp

: derivs-LE() ( t 'u 'dudt -- ) 
       2SWAP FDROP     \ does not use t

       >R	\ 'u
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


\ ----- Begin Testing --------------------

1.0E-2 _dt F!


1e-13 rel-near F!  \ <-- tests pass at 1e-14 in Gforth
1e-13 abs-near F!
set-near    

CR
TESTING E&P Non-Stiff ODE Problems A1 to A4 (Adaptive Step)
t{ use( derivs-A1() 0e 20e 1e )rksolve1  ->  t_final F@ A1  r}t
t{ use( derivs-A2() 0e 20e 1e )rksolve1  ->  t_final F@ A2  r}t
t{ use( derivs-A3() 0e 20e 1e )rksolve1  ->  t_final F@ A3  r}t
t{ use( derivs-A4() 0e 20e 1e )rksolve1  ->  t_final F@ A4  r}t
\ t{ use( derivs-A5() 0e 20e 1e )rksolve1  ->  t_final F@ A5  r}t

\ Non E&P Problems
TESTING Damped Vibration (Adaptive Step)
t{ use( derivs-DV() 0e 0.8e u0 v0  )rksolve2  ->  t_final F@ DV  r}t

TESTING Charging Capacitor (Adaptive Step)
t{ use(  derivs-Vc() 0e 200e-3 0e  )rksolve1  ->  t_final F@ Vc  r}t


\ Tests Using Fixed Step Solver
\ Set relatively low accuracy since our time step _dt is coarse.
1e-4 rel-near F!   
1e-4 abs-near F!

TESTING Damped Vibration (Fixed Step)
t{ use(  derivs-DV() 80 0e u0 v0  )rk_fixed2  ->  t_final F@ DV  r}t

TESTING Charging Capacitor (Fixed Step)
t{ use(  derivs-Vc() 4  0e 0e  )rk_fixed1  ->  t_final F@ Vc  r}t


0 [IF]
\ see comments for the Lorenz equations, above -- km 2007-09-27
    
: lorenz_test ( n -- )               \ n is the number of time steps to run

    0.0E0 x{ 0 } F!   1.0E0 x{ 1 } F!   0.0E0 x{ 2 } F!     
    use( derivs-LE() 3 )runge_kutta4_init
    0.0E0       \ initial time
          
    ROT 0 DO
	x{ 1 dt runge_kutta4_integrate()      
    LOOP

    FDROP runge_kutta4_done
;
[THEN]

BASE !
[THEN]

