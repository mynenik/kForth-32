\ riccati.4th
\
\ Demonstrate use of IEEE 754 arithmetic to integrate through 
\ poles in a function, y(t), by integrating the particular 
\ Riccati differential equation [1],
\
\    dy/dt = t + y^2 ; t >= 0, y(0) = 0
\
\ Compute y(t = 10).
\ 
\ Infinities occurring in the second R-K update formula, Q2,
\ do not cause the integral to "blow up" owing to IEEE 754 
\ arithmetic rules for infinity.
\
\ Krishna Myneni, 2020-08-22
\
\ References:
\
\ 1. W. Kahan, Lecture Notes on the Status of IEEE Standard 754
\    for Binary Floating-Point Arithmetic, 1997.
\    https://people.eecs.berkeley.edu/~wkahan/ieee754status/IEEE754.PDF

include ans-words
include asm-x86
include fpu-x86
include ieee-754

[UNDEFINED] ptr [IF] : ptr create 1 cells ?allot ! does> a@ ; [THEN]

[UNDEFINED] fsquare  [IF] : fsquare fdup f* ;      [THEN]
[UNDEFINED] f2dup    [IF] : f2dup   fover fover ;  [THEN]
[UNDEFINED] fround>s [IF] : fround>s fround f>s ;  [THEN]

1e-6 fconstant DEF_THETA

\ Generic integrator with xt to update formula

0 ptr Q 
fvariable theta
fvariable Yn

: integrate ( F: y0 tfinal theta -- y[tfinal] ) ( xt -- flag )
    to Q
    clearFPUexceptionsX86  
    fdup theta f!
    f/ fround>s >r
    Yn f!  
    r> 0 ?DO 
      theta f@ 
      fdup I s>f f* 
      Yn f@ Q execute Yn f!
    LOOP 
    Yn f@ 
    FDIVBYZERO GET-FFLAGS 0<> dup IF
      ." WARNING: Possible reduced accuracy due to +/-INF!" cr
    THEN ;


\ Heun's second-order Runge-Kutta update formula. In this
\ formula, infinities may occur within a sum.

fvariable rf
fvariable rq
fvariable ry

: Q_Heun ( F: theta t Y -- Y[t+theta] )
   f2dup fsquare f+ rf  f! ry f!  \ F: theta t
   fover rf f@ f* ry f@ f+ rq f!  \ F: theta t 
   fover f+ rq f@ fsquare f+ rf f@ f+
   f* 2e f/ ry f@ f+ ;


\ Another update formula, which pushes infinities into the
\ denominator of a division operation.

: num ( F: theta t Y -- num )
    fsquare f+ fover 2e f/ f+ f* ; 

: den ( F: theta Y -- den )
    f* fnegate 1e f+ ;

fvariable rt
fvariable ry2

: Q2 ( F: theta t Y -- Y[t+theta] )
   ry f! rt f!             \ F: theta 
   fdup ry f@ f* fabs 0.5e f< IF
     \ F: theta 
     fdup  rt f@ ry f@ num
     fswap ry f@ den f/
     ry f@ f+ 
   ELSE
     \ F: theta
     1e fover f/ fnegate ry2 f!
     fdup  rt f@ ry2 f@ num  
     fswap ry f@ den f/
     ry2 f@ f+ 
   THEN
;

1e 0e f/ fconstant +Inf
: Q3 ( F: theta t Y -- Y[t+theta] )
    fdup +Inf f= IF fover fs. 2 spaces fdup f. cr THEN
    ry f! rt f!
    ry f@ 1e6 f>  ry f@ +Inf f<  and IF
      fdrop 1e ry f@ fabs f/    \ replace theta with 1/Y
    THEN
    rt f@ ry f@ Q2 ;

cr .( Integrate the Riccati equation: ) cr
cr .(    dy/dt = t + y^2 ; t >= 0; y0 = 0 ) cr
cr .( Compute y at t = 10. ) cr
cr .( Integrating with conventional update formula... ) cr
0e 10e DEF_THETA ' Q_Heun integrate drop
.( Result = ) fs. cr 
cr .( Integrating with unconventional update formula... ) cr
0e 10e DEF_THETA ' Q2 integrate drop
.( Result = ) fs. cr
cr .( Integrating with infinities in iterates.... ) cr
0e 10e DEF_THETA ' Q3 integrate drop
.( Result = ) fs. cr

