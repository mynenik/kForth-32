\ lk.4th
\
\ Solve the Lang-Kobayashi equations describing a
\ semiconductor laser with delayed optical feedback:
\
\	dY/ds = (1 + i*alpha)Z(s)Y(s) + eta*exp(-i*phi)*Y(s-rho)
\	dZ/ds = (P(s) - Z(s) - (1 + 2Z(s))|Y(s)|^2)/T
\
\ See sl.4th for description of Y, Z, s, alpha, P, and T. 
\ The new quantities in the laser equations are rho, eta, and phi:
\
\	rho	normalized delay time for optical feedback
\	phi	feedback phase (0 to 2*pi)
\	eta	normalized feedback rate (typically 0 to 0.3)
\
\ The L-K equations represent the physical situation of a partially
\ reflecting mirror at some distance from the semiconductor laser, 
\ reflecting the beam back into the laser. The interference between
\ the laser field and the delayed feedback results in fast chaotic
\ dynamics for the state of the laser.
\
\ Copyright (c) 2002 Krishna Myneni
\
\ Requires:
\
\   ans-words
\   fsl-util
\   dynmem
\   complex
\   runge4
\   sl
\
\ Revisions:
\
\   2002-11-15  km;  first version
\   2003-05-13  km;  Replaced F>S with FROUND>S
\   2005-10-27  km;  removed lkparams. and use params.
\   2007-10-22  km;  revised to use FSL arrays and new version of sl.4th
\
\ Notes:
\
\  1.  Assumes feedback phase (phi) is 0.
\
\  2.  Default setting is for constant drive current (constant P(s)).
\
\  3.  To solve the L-K equations using the default parameters
\      for a fixed number of steps, execute "lk". The output
\      is time in ns, optical intensity, phase, and carrier density.
\      The output may be redirected to a file, e.g. lk.dat, by typing
\
\	  >file lk.dat lk console
\     

include sl
[undefined] verbose? [IF] 0 value verbose? [THEN]

: COMPLEX 2 FLOATS ;

COMPLEX DARRAY Epast{	\ past complex field

fvariable eta		\ normalized feedback rate
fvariable rho		\ normalized roundtrip time (real time = rho*t_p)

0.1e ds F!		\ use normalized time step of 0.1
588e rho F!		\ use whole number; rho*t_p is actual roundtrip time in sec
0.18e eta F!

fvariable I/I_th       \ constant value of drive current, as a fraction of threshold current
1.3e I/I_th F!

: ConstantCurrent ( ft -- fc | return a constant current )
    fdrop I_th F@ I/I_th F@ F* ;

' ConstantCurrent IS I(t)

1.8e-9 t_s F!		\ set t_s to give T_ratio = 400

0 value fidx
0 value max_idx

: }zzero ( 'array n -- | zero the n-element complex array)
    2* FLOATS erase ;

: !Epast ( re im -- | store the complex field )
    Epast{ fidx } z!
    fidx 1+ dup max_idx > IF drop 0 THEN TO fidx
; 

: @Epast ( -- re im | retrieve the delayed field )
    fidx 1+ dup max_idx > IF drop 0 THEN
    Epast{ SWAP } z@ ; 

: lk_init ( -- | initialize necessary params for L-K calculation)
    init_params		      \ from sl.4th
    0 TO fidx
    rho F@ ds F@ F/ fround>s  TO max_idx  \ ok if rho is whole number, since ds = 0.1
    & Epast{ max_idx 1+ }malloc
    Epast{ max_idx 1+ }zzero
;

: params. ( -- | print revised laser and new LK parameters )
        params.       \ print sl parameters (this is not a recursive call)
	." L-K parameters:" cr
	separator cr
	." I/I_th  = " I/I_th F@ F. cr
	." rho     = " rho    F@ F. cr
	." eta     = " eta    F@ F. cr
	." phi     = " 0         .  cr
;

: derivs-lk() ( fs 'u 'dudt -- )
    DUP >R
    derivs-sl()    \ derivatives for solitary laser 
    \ Add delay feedback term to dY/ds:  eta*exp(-i*phi)*Y(s-rho)
    R@ 0 } z@ @Epast eta F@ z*f z+ R> 0 } z!
;


: lksteps ( fs u -- fs_end | solve the L-K equations for u steps, from start time fs)

    0 ?DO
	verbose? IF  FDUP >ns F. THEN  \ output the time in ns
	
	ds F@ sv{ 1 runge_kutta4_integrate()
	sv{ 0 } z@ !Epast

	verbose? IF
	    2 spaces  sv{ intensity F.	 \ output intensity
	    2 spaces  sv{ phase PI F/ F. \ output normalized phase: 1.0 = pi radians
	    2 spaces  sv{ 2 } F@ F. cr   \ output normalized carrier density
	THEN
    LOOP
;

: lk ( -- | solve the L-K equations and show output )
    lk_init
    1.9e 1.1e 0.1e 3 sv{ }fput      \ initialize the state vector
    sv{ 0 } z@ !Epast
    use( derivs-lk() 3 )runge_kutta4_init
    true to verbose?
    0e 20000 lksteps
    FDROP runge_kutta4_done
    & Epast{ }free
;

lk_init
params.

