\ Double Double-precision floating point arithmetic
\
\ ---------------------------------------------------
\     (c) Copyright 2006  Julian V. Noble.          \
\       Permission is granted by the author to      \
\       use this software for any application pro-  \
\       vided this copyright notice is preserved.   \
\ ---------------------------------------------------

\ This is an ANS Forth program requiring the
\   FLOAT, FLOAT EXT, FILE and TOOLS EXT wordsets.
\
\ Environmental dependences:
\       Assumes independent floating point stack
\       the fpu must be set to 64-bit internal operations
\               ^^^^
\
\ Notes:
\
\   1. This version is for an integrated data/fp stack. 

\   2. Some word names have been changed from JVN's original[1]:
\
\     REAL*16 --> DDVARIABLE
\     R128@   --> DD@
\     R128!   --> DD!
\
\ References:
\
\   1.  Original sources may be found at
\         http://galileo.phys.virginia.edu/~jvn/
\
\   2.  For a description of double-double arithmetic, see
\         https://en.wikipedia.org/wiki/Quadruple-precision_\
\               floating-point_format#Double-double_arithmetic
\
\ GLOSSARY:
\
\    DDVARIABLE ( "name" -- )          create a double double variable
\    DDCONSTANT ( F: x xx "name" -- )  create a double double constant
\    DD@      ( a -- ) ( F: -- x xx )  fetch a dd number
\    DD!      ( a -- ) ( F: x xx -- )  store a dd number
\    DDPI     ( F: -- x xx )           place dd PI on stack
\    DD=1     ( F: -- x xx )           place dd 1 on stack
\    DD*      ( F: x xx y yy -- z zz ) multiply two dd numbers
\    DD/      ( F: x xx y yy -- z zz ) divide two dd numbers
\    DD+      ( F: x xx y yy -- z zz ) add two dd numbers
\    DDNEGATE ( F: x xx -- y yy )      negate a dd number
\    DDABS    ( F: x xx -- y yy )      absolute value of a dd number
\    DDSQRT   ( F: x xx -- y yy )      square root of a dd number
\    DD^2     ( F: x xx -- y yy )      square a dd number
\    DD^n     ( F: x xx -- y yy ) ( n -- ) raise dd number to integral power
\    DDDUP    ( F: x xx -- x xx x xx ) dup a dd number
\    DDSWAP   ( F: x xx y yy -- y yy x xx ) swap two dd numbers
\    DDOVER   ( F: x xx y yy -- x xx y yy x xx )
\    DDTUCK   ( F: x xx y yy -- y yy x xx y yy )
\
\ To output a dd number, see dd>$ and ddfs. in dd_io.4th
\
\ A double-double represents a fp number as 2 64-bit IEEE fp#'s. 
\ On the fp-stack we have ( f: x xx) which is written ( f: x+xx )
\ when we want to make explicit the fact that x is the more- and 
\ xx the less-significant part of x+xx.
\
\ There is no specific algorithm to convert d->dd, since one would
\ have to construct the appropriate xx part to add to x, and there 
\ is no recipe that can supply information that was not originally
\ present.


\ ---------------------------------------- LOAD, STORE
\ DD@ and DD! were originally called R128@ and R128! 
\ in JVN's version -- km 2020-09-27

: dd@  DUP >r    F@  r> FLOAT+  F@ ;
: dd!  DUP >r FLOAT+ F! r>  F! ;
\ ------------------------------------ END LOAD, STORE

\ ----------------------------------- data types ----
: ddvariable   \ create a double-double variable
    CREATE  2 DFLOATS ALLOT  ;

: ddconstant   CREATE 2 FLOATS ALLOT? dd!
               DOES>  dd@  ;
\ ---------------------------------------------------

3.1415926535897931e0  1.2246467991473532e-16  ddconstant ddpi

\    = 3.141592653589793238462643383279
\ pi = 3.1415926535897932384626433832795028841971693993751...


\ based on "Software for Doubled-Precision Floating-Point Computations"
\       by Seppo Linnainmaa
\       ACM Transactions on Mathematical Software,
\           Vol 7, No 3, September 1981, Pages 272-283

: fvariables:     0 DO  FVARIABLE  LOOP  ;


FALSE [IF]    \ determine base and precision of fpu

    4e0 3e0 F/  1e0 F-  3e0 F*  1e0  F-  FVALUE u
    u 2e0 F/  1e0 F+  1e0 F-  FVALUE r
    r F0=  NOT  [IF]  r FTO u  [THEN]
    2e0 3e0 F/ 0.5e0 F- 3e0 F* 0.5e0 F-  FVALUE uu
    uu 2e0 F/ 0.5e0 F+ 0.5e0 F-  FVALUE rr
    rr F0=  NOT  [IF]  rr FTO uu  [THEN]
    u uu F/     ( f: -- beta)
    uu  FLN  FOVER FLN  F/ FNEGATE  0.5e0 F+
    F>S  F>S  CR  CR .( base = ) .   .( precision = ) . FORGET u

[THEN]


\ Exact multiplication

134217729 S>F  FCONSTANT split




: ftuck  FSWAP  FOVER  ;
: f-rot    FROT  FROT  ;  

8 fvariables: q qq x xx y yy z1 z2

9 fvariables:  t a1 a2 b1 b2 b21 b22 xaa xbb

: exactmul  ( f: a  b -- x xx)   \ multiply 2 fp#'s to get ddfp#
    xaa F!  xbb F!
    xbb F@  split F*  t F!
    t F@  xbb F@  FOVER F-  F+  FDUP  a1 F!   ( f: a1)
    FNEGATE  xbb F@ F+  a2 F!
    xaa F@  FDUP  split F*  t F!              ( f: xaa)
    t F@  ftuck  F-  F+  b1 F!
    xaa F@  b1 F@  F-  FDUP  FDUP  b2 F!      ( f: b2 b2)
    split F*  t F!
    t F@   ftuck  F- F+  FDUP  b21 F!        ( f: b21)
    FNEGATE  b2 F@  F+   b22 F!
    xbb F@  xaa F@  F*  FDUP  t F!
    a1 F@  b1 F@  F*  t F@  F-  a1 F@  b2 F@  F*
    F+  b1 F@  a2 F@  F*  F+
    b21 F@  a2 F@  F*  F+  b22 F@  a2 F@  F*  F+
;


: dd/   ( f: x xx  y yy -- [x+xx]/[y+yy] )
    yy F!  y F!  xx F!  x F!
    y F@  FABS  F0= ABORT" Can't divide by 0!"
    x F@  y F@  F/  FDUP  z1 F!
    y F@  exactmul  qq F!  FDUP  q F!   ( f: q)
    FNEGATE  x F@  F+   qq F@   F-
        xx F@  F+   z1 F@  yy F@  F*  F-
        y F@  yy F@  F+  F/  FDUP  z2 F!
    z1 F@  F+  FDUP
    FNEGATE  z1 F@  F+  z2 F@  F+
;



: dd*   ( f: x xx  y yy -- [x+xx]*[y+yy] )
    yy F!  y F!  xx F!  x F!
    x F@  y F@  exactmul  qq F!  z1 F!
    x F@  xx F@  F+  yy F@  F*
        xx F@  y F@  F*  F+  qq F@  F+  FDUP  z2 F!
    z1 F@  F+  FDUP
    FNEGATE  z1 F@  F+  z2 F@  F+
;


: dd+   ( f: x xx  y yy -- [x+xx] + [y+yy] )
    yy F!  y F!  xx F!  x F!
    x F@  y F@  F+  z1 F!
    x F@  z1 F@  F-  FDUP  q F!
    y F@  F+                            ( f: q+y)
        x F@    q F@  z1 F@  F+   F-    ( f: q+y  x-[q+z1])
        F+  xx F@  F+  yy F@  F+  FDUP  z2 F!
        z1 F@  F+   FDUP                ( f: z1+z2  z1+z2)
        FNEGATE   z1 F@   F+   z2 F@  F+
;



: ddnegate  ( f: x xx -- -x -xx)
    FNEGATE  FSWAP  FNEGATE  FSWAP
;

: ddabs    ( f: x xx -- |x+xx|)
    FOVER  F0<   IF  ddnegate  THEN
;

: dd-   ( f: x xx y yy -- [x+xx] - [y+yy] )
    ddnegate    dd+
;



\ Square root based on T.J. Dekker,
\ "A Floating-Point Technique for Extending the Available Precision"
\ Numerische Mathematik 18 (1971) 224-242.

: ddsqrt    ( f: x xx -- ddsqrt[x+xx])
    xx F!  FDUP  x F!
    F0< ABORT" Can't take sqrt of negative number!"
    x F@  FSQRT   FDUP   q F!
    FDUP  exactmul   yy F!  FDUP  y F!
    FNEGATE  x F@  F+
    yy F@  F-   xx F@   F+
        0.5e0  F*   q F@  F/   FDUP  qq F!
    q F@   F+   FDUP
    FNEGATE  q F@  F+   qq F@   F+
;

1e0 0e0  ddconstant  dd=1

\ ----------------------------------- stack ops -----
fvariable dtemp

ddvariable  ddtemp   ddvariable  ddtemp1

: ddswap    ( f: x xx y yy -- y yy x xx )
    dtemp F!  F-ROT   dtemp F@  F-ROT  ;

: dddup     FOVER  FOVER  ;

: dddrop   FDROP  FDROP  ;

: ddover   ddtemp  dd!  dddup  ddtemp1 dd!
           ddtemp  dd@         ddtemp1 dd@  ;

: ddtuck   ddtemp  dd!  ddtemp1 dd!
           ddtemp  dd@  ddtemp1 dd@
           ddtemp  dd@  ;
\ ---------------------------------------------------

: dd^2     dddup  dd*  ;

variable temp
: dd^n  ( x xx n -- [x+xx]^n )    \ ( n -- ) ( f: x xx -- [x+xx]^n )
    \ raise dd to integer power
    \ return 1 if n=0, dd^{-|n|} if n<0
       >r dd=1   ddswap        ( f: 1e0 0e0 x xx )
       r> DUP  0=   IF  drop dddrop  EXIT  THEN
       DUP  0<   SWAP  ABS   ( -- 1e0 0e0 x xx sign |n| )
         BEGIN   DUP  0>  WHILE
                 2dup temp 2! nip 1 AND   IF ddtuck  dd*  ddswap THEN dd^2
                 temp 2@ 2/
         REPEAT  drop >r dddrop r>
       IF  dd=1  ddswap  dd/  THEN
;

