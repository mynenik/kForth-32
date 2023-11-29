\ sl.4th
\
\ Solve the semiconductor laser rate equations, given a current pulse 
\ profile. Output the time, intensity, phase, and current density.
\
\ Based on a C program by S.D. Pethel
\
\ Krishna Myneni, 1-26-2000
\
\
\ Revisions:
\
\   2007-10-19  modified to use complex library, and FSL ODE solver.
\               This version is about 20% slower than the original,
\               but the code simplifies greatly. KM
\
\   2002-10-27  changed all instances of dfloat to float for
\	        ANS Forth portability. Removed explicit fp
\	        number size dep. KM
\
\   2002-10-24  fixed problem with the main loop; prev. was not
\	        computing Vdot on every loop iteration. Also
\	        changed current pulse pos to 3 ns.  KM
\ 
\   2002-10-21  fixed time scale problem in sl after problem
\		was pointed out by Marcel Hendrix.    KM
\
\
\ -------------------------------------------------------------------
\
\ The normalized laser rate equations are given by
\   (cf D.W. Sukow, PhD Thesis: Experimental Control of
\   Instabilities and Chaos in Fast Dynamical Systems, 1997):
\
\	dY/ds =	(1 + i*alpha)Z(s)Y(s)
\	dZ/ds = 1/T (P(s) - Z(s) - (1 + 2Z(s))|Y(s)|^2)
\
\  obtained by the transformation
\
\	Y = (t_s*G_N/2)^0.5 * E		( note E is complex )
\
\	Z = (t_p*G_N/2)(N - N_th)
\
\	s = t/t_p			( time in units of photon lifetime )
\
\ and the parameters are given by:
\
\	P = (t_p*G_N*N_th/2)(I/I_th - 1)
\	T = t_s/t_p
\
\ The basic quantities are:
\
\	E 	( complex electric field in photons^0.5/cm^3 )
\	N 	( carrier density in cm^-3 )
\	N_th 	( carrier density at threshold for lasing )
\	I_th	( threshold current in mA )
\	t_p 	( photon lifetime in sec )
\	t_s 	( carrier lifetime in sec )
\	alpha 	( linewidth enhancement factor -- no dimensions )
\	G_N 	( differential gain at threshold in cm^3/s )
\	
\

include ans-words.4th
include fsl/fsl-util.4th
include fsl/dynmem.4th
include fsl/complex.4th
include fsl/runge4.4th


\ ===============================
\ Handy definitions
\ ===============================

: intensity ( 'a -- fI | compute intensity of state vector )
    0 } z@ |z|^2 ;

: phase ( 'a -- fphase | compute phase in radians of state vector )
    0 } z@ arg ;

\ ================
\ Laser parameters
\ ================

fvariable t_p			\ photon lifetime (sec)
4.5e-12 t_p F!

fvariable t_s			\ carrier lifetime (sec)
700e-12 t_s F!

fvariable G_N			\ differential gain (cm^3/s)
2.6e-6 G_N F!

fvariable N_th			\ threshold carrier density (cm^-3)
1.5e18 N_th F!		

fvariable I_th			\ threshold current through laser (mA)
20e I_th F!

fvariable alpha			\ linewidth enhancement factor
5.0e alpha F!


\ ========================
\ Dimensionless parameters
\ ========================

fvariable T_ratio		\ T_ratio = t_s/t_p
fvariable PumpFactor 		\ PumpFactor = (t_p*G_N*N_th/2)

\ =======================
\ Display all parameters
\ =======================

: init_params ( --  | compute the normalized parameters )
    t_s F@ t_p F@ F/ T_ratio F!
    t_p F@ G_N F@ F* N_th F@ F* 2e F/ PumpFactor F! ;

: separator ( -- ) ." ===================================================" ;
: tab 9 emit ;
	
: params. ( -- | display all of the parameters )
	cr 
	separator cr
	." Symbol" tab ." Parameter                     " tab ." Value"  cr
	separator cr cr
	."  t_p  " tab ." Photon lifetime  (s):         " tab  t_p   F@ F. cr
	."  t_s  " tab ." Carrier lifetime (s):         " tab  t_s   F@ F. cr
	."  G_N  " tab ." Differential gain (cm^3/s):   " tab  G_N   F@ F. cr
	."  N_th " tab ." Thr. carrier density (cm^-3): " tab  N_th  F@ F. cr
	."  I_th " tab ." Thr. current (mA):            " tab  I_th  F@ F. cr
	."  alpha" tab ." Linewidth enhancement factor: " tab  alpha F@ F. cr 
	separator cr
	." Derived Dimensionless Parameters " cr
	separator cr cr
	." t_s/t_p ratio: " tab T_ratio F@ F. cr
	." Pump factor: " tab PumpFactor F@ F. cr 
	separator cr 
;  


init_params
params.

\ ======================================================
\ The injection current profile and normalized pump rate
\ =======================================================
Defer I(t)              \ injection current function

fvariable fwhm		\ full-width at half-max for current pulse in ns
1e fwhm F!			( set to 1 ns )

fvariable pulse_amp	\ current pulse amplitude above d.c. level
20e pulse_amp F!		( set to 20 mA )

fvariable dc_current	\ d.c. current level
I_th f@ 10e F+ dc_current F!	( set to 10 mA above threshold )

fvariable peak_offset	\ offset in time for current peak
3e peak_offset F!		( set to 3 ns )

: GaussianPulse ( ft -- fc | compute current at real time ft )
    \ ft is in nano-seconds
    peak_offset F@ F- fwhm F@ F/
    FSQUARE -2.77066e F* FEXP
    pulse_amp F@ F* dc_current F@ F+ ;		


' GaussianPulse IS I(t)

\ You may use your own injection current word by typing
\
\	' yourword IS I(t)
\
\ The word should have the stack diagram ( ft -- fc ) where ft
\   is the time in nanoseconds, and fc is the current in mA.

: >ns ( fs -- ft | convert dimensionless time s to nanoseconds)
    t_p F@ F* 1e-9 F/ ;

: P(s) ( fs -- | compute the pump rate at time s )
    >ns I(t) I_th F@ F/ 1e F- PumpFactor F@ F* ;

\ ==============================================
\ Rate equations for solitary semiconductor laser
\ ==============================================

\ Data in 'u is ordered in the following way: Re{Y}, Im{Y}, Z

: derivs-sl() ( fs 'u 'dudt -- )
    >R >R
    \ dY/ds = (1 + i*alpha)*Z*Y
    R@ 0 } z@  R@ 2 } F@ z*f 1e alpha F@ z* 2R@ DROP 0 } z!  
    \ dZ/ds = (P(t) - Z - (1 + 2Z)|Y|^2)/T
    P(s) R@ 2 } F@ F-  R@ 0 } z@ |z|^2  R@ 2 } F@ 2e F* 1e F+ F* F-
    T_ratio F@ F/
    R> DROP R> 2 } F!
;


\ =============================
\ The rate equation solver
\ =============================

fvariable ds		\ dimensionless time step
0.1e ds F!		\ actual time step dt = t_p*ds

3 constant SVSIZE
SVSIZE FLOAT ARRAY  sv{

: sl ( -- )

    init_params		         \ compute all derived parameters
    2e fsqrt 0e 0e  3 sv{ }fput  \ initial values of Re(Y), Im(Y), Z 

    use( derivs-sl() 3 )runge_kutta4_init
    
    \ Compute 20000 normalized time steps

    0e
    20000 0 DO
	( s -- | s is the normalized time )
	FDUP >ns FDUP F. 2 spaces               \ output real-time in ns
	I(t) F. 2 spaces	                \ compute and output the injection current

	ds F@ sv{ 1 runge_kutta4_integrate()
	
	I 1 mod 0= IF
	    sv{ intensity   F. 2 spaces	\ output intensity
	    sv{ phase PI F/ F. 2 spaces	\ output normalized phase: 1.0 = pi radians
	    sv{ 2 } F@ F. cr            \ output normalized carrier density
	THEN
    LOOP
    FDROP  runge_kutta4_done
;
