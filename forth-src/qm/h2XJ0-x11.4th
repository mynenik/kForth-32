\ h2XJ0-x11.4th
\
\ Compute the bound vibrational levels of the H_2 molecule
\ in its ground electronic state (see h2XJ0.4th) and provide
\ a graphical display of the computed energy levels and
\ probability densities obtained from the wavefunctions.
\
\ Copyright (c) 2011-2015 Krishna Myneni, http://ccreweb.org
\
\ This code may be used for any purpose as long as the copyright
\ notice above is preserved.
\
\ Requires:
\
\   simple-graphics-x11.4th
\   h2XJ0.4th
\
\ Revisions:
\   2011-08-28  km  first version
\   2012-04-08  km  revised to use modules version of simple-plot-x11;
\                   all scaling from user coords to window coords
\                   handled by plotting module.
\   2012-04-19  km  revised to use simple-graphics-x11 module.
\   2014-12-20  km  revised to use modular version of qm code.
\   2015-01-01  km  synced code for findlev2 with code in h2XJ0.4th.
\   2016-06-04  km  updated path to simple-graphics-x11.4th.
\   2017-07-26  km  modified include statements.

include qm/h2XJ0.4th
include lib-interface
include libs/x11/libX11
include x11/simple-graphics-x11

Also simple-graphics-x11

[undefined] fnip  [IF] : fnip  fswap fdrop ; [THEN]
[undefined] ftuck [IF] : ftuck fswap fover ; [THEN]

fvariable Rmin
fvariable Rmax
get-Rlims Rmax f! Rmin f!

\ Find the endpoints of r on the potential curve, corresponding to
\   specified energy.
: find-rlims ( F: e -- r1 r2 )
    Nmesh @ 0 DO
      fdup V_mesh{ I } f@ f> IF I leave THEN
    LOOP
    >r r_mesh{ r@ } f@ fswap 
    Nmesh @ r> 1+ DO
      fdup V_mesh{ I } f@ f< IF r_mesh{ I } f@ leave THEN
    LOOP
    fnip ;

variable Nlevels
Rmin f@ 0.25e f+ fconstant R_vlabel
    
: draw-levels ( -- )
    black foreground
    Nlevels @ 0 DO
      Ev{ I } f@  fdup find-rlims frot ftuck    put-line
      R_vlabel Ev{ I } f@ I 0 <# # # #> put-text
    LOOP
    R_vlabel Ev{ 12 } f@ 0.01e f+ s" v"  put-text
;

\ Set up storage for the wavefunctions
Nmesh @ FLOAT array P{
Nmesh @ MAX-LEVELS FLOAT matrix Ps{{
0 value vt
: save-soln ( v -- )
   to vt  P{ }get-P
   Nmesh @ 0 DO  P{ I } F@  Ps{{ I vt }} f!  LOOP
;

\ Draw the probability distributions for each wavefunction
Nmesh @ float array pd{ 

: calc-pd  ( v -- ) 
    to vt 
    Nmesh @ 0 DO  Ps{{ I vt }} f@ fsquare pd{ I } f!  LOOP
;

Nmesh @ float array spd{ 

: scale-pd ( v -- )
    Ev{ swap } f@
    Nmesh @ 0 DO  pd{ I } f@ 100e f/ fover f+ spd{ I } f!  LOOP  fdrop ;   

: draw-pd ( v -- )
    dup 2 mod IF blue ELSE red THEN foreground
    dup calc-pd
    scale-pd
    r_mesh{ 0 } spd{ 0 } Nmesh @ 2 / line-plot ;
        
\ Draw the potential curve

: draw-potnl ( -- )
    black foreground
    r_mesh{ 0 } V_mesh{ 0 } Nmesh @ line-plot
;

7e      fconstant  PL_Rmax
-0.95e  fconstant  PL_Vmax

: draw-h2X ( -- )
    \ get-window-size  s>f fheight f! s>f fwidth f!
    Rmin f@ Vmin f@ PL_Rmax PL_Vmax set-window-limits
    clear-window
    draw-potnl
    draw-levels
    Nlevels @ 0 DO  I draw-pd  LOOP
;

' draw-h2X IS redraw-window

\ A version of find-levels which saves the calculated wave 
\ functions, and does not deallocate arrays at the end of the calc.
: findlev2 ( -- )
    MAX-LEVELS Ev{ }fzero
    \ Find the energy of the lowest level (v=0)
    0 to v
    Vmin F@ start_dE solve ABORT" find-levels: Unable to find the lowest level!" 
    v save-soln
    fdrop fdup Ev{ v } F!
    fdup  Vmin F@ F- offset_E F! 
    BEGIN
      next-trial-E start_dE solve
      0= IF
	fover Ev{ v } F@ start_dE F~ IF  \ We found the previous level, increase offset
	   offset_E F@ 1.2e F* offset_E F! fdrop
	ELSE 
          v 1+ to v
          v save-soln
          \ The following energy increment works well to determine
          \   the trial value for the next eigenvalue
	  fdrop fdup Ev{ v } F! 
          fdup  Ev{ v 1- } F@ F- 2e F/ offset_E F!
        THEN
      ELSE
        fdrop
      THEN
      fdup V_inf F>
    UNTIL
    v 1+ Nlevels !
    fdrop
;

cr .( Finding bound levels of X state ... )
findlev2
2 1 simple-graphics
end-solve


