\ bifurc-logmap.4th 
\
\  Display the bifurcation diagram for a logistic map.
\
\ Copyright (c) 2011--2012 Krishna Myneni, Creative Consulting for
\   Research & Education, krishna.myneni@ccreweb.org
\
\ This code is released under the GNU Lesser GPL (LGPL).
\
\ Revisions:
\   2011-08-26  km  first version.
\   2011-08-27  km  fixed vertical inversion
\   2012-04-09  km  revised to use with modules version of simple-plot
\   2012-04-19  km  revised to use simple-graphics-x11 module
\   2012-05-04  km  revised to add statement: Also X11
\
\ References:
\
\ 1. E. Ott, Chaos in Dynamical Systems, 1994, Cambridge Univ. Press,
\    see sec. 2.2, p. 32 ;

include ans-words
include modules
include syscalls
include mc
include asm
include strings
include lib-interface
include libs/x11/libX11
include x11/simple-graphics-x11.4th

Also X11
Also simple-graphics-x11

 500 constant Ntr      \ number of transient values
1000 constant Nseq     \ number of values in sequence to plot

2.5e fconstant rmin
4.0e fconstant rmax
rmax rmin f- fconstant delr
0.001e fconstant rdelta

\ logistic map
fvariable r
: L ( F: x -- x' ) 1e fover f- f* r f@ f* ;

\ Generate L map sequence for current r, discarding transient 
create L_s Nseq FLOATS allot

: gen-L_s ( -- )
      0.5e Ntr  0 DO  L  LOOP  \ first Ntr iterations are discarded
      L_s  Nseq 0 DO  >r L fdup r@ f! r> FLOAT+  LOOP
      drop fdrop ;

XPoint% %size constant XPT_SIZE
create xp XPT_SIZE Nseq * allot

: XPoint! ( nx ny apoint -- )  rot over XPoint->x w! XPoint->y w! ;

fvariable fheight
fvariable fwidth

: scale-point ( F: r x -- ) ( -- ux uy )
	1e f- fnegate fheight f@ f* fround>s >r
	rmin f- delr f/ fwidth f@ f* fround>s r> ;
 
: scale-L_s ( -- )
	L_s xp Nseq 0 DO
	   >r dup >r r f@ r> f@ scale-point r@ Xpoint!
	   FLOAT+ r> XPT_SIZE +
        LOOP
        2drop ;

: draw-bifurc ( -- )
    get-window-size  s>f fheight f! s>f fwidth f!
    clear-window
    blue foreground

    \ Sweep r from rmin to rmax
    delr rdelta f/ fround>s 0 DO
	rmin I s>f rdelta f* f+ r f!
	gen-L_s
	scale-L_s
	xp Nseq draw-points
    LOOP
;

' draw-bifurc IS redraw-window

2 2 simple-graphics



