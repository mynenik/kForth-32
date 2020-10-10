(         Title:  System FP Parameters
            File:  machar.4th
         Version:  0.9.5 [integrated stack]
Original Author:  W. J. Cody, 1987
       Ported by:  David N. Williams
         License:  ACM noncommercial use
   Last revision:  April 9, 2003

Version 0.9.5
  9Apr03  * Modified the integrated stack, kForth version to
            define constants instead of variables for the machine
            parameters, based on nonintegrated stack version
            0.9.5.

Version 0.9.0
  5Jan03  * Start.
10Jan03  * Finish
13Jan03  * Modified for integrated stack Forth, specifically for
            kForth. -- Krishna Myneni

This is a port of W. J. Cody's MACHAR subroutine in the celefunt
package from Fortran 77 to ANS Forth.  As ACM Algorithm 714
[TOMS], that package is presumed to be under the ACM license for
noncommercial use:

http://www.acm.org/pubs/copyright_policy/softwareCRnotice.html

There is a Forth environmental dependency on lower case.

The software determines the floating point machine parameters
corresponding to the default words in the Floating-Point word
set.

Quote from the original package:

   This Fortran 77 subroutine is intended to determine the
   parameters of the floating-point arithmetic system specified
   below.  The determination of the first three uses an extension
   of an algorithm due to M. Malcolm, CACM 15 [1972], pp. 949-951,
   incorporating some, but not all, of the improvements suggested
   by M. Gentleman and S. Marovich, CACM 17 [1974], pp. 276-277.
   An earlier version of this program was published in the book
   Software Manual for the Elementary Functions by W. J. Cody and
   W. Waite, Prentice-Hall, Englewood Cliffs, NJ, 1980.

WARNING!  The following code has only been tested on IEEE-754
systems.

)

include ans-words  ( for kForth )
decimal
\ MARKER -MACHAR

(
This program computes the following constants --- integer
constants are designated by i: and floating point constants
are designated by f: :  

i:  ibeta       The radix for the fp representation.
f:  beta        Float representation of IBETA.
i:  #digits     The number of base IBETA digits in the fp
                  significand.  Original name: IT
i:  irnd        0 if fp addition chops
                1 if fp addition rounds, but not in the
                  IEEE style
                2 if fp addition rounds in the IEEE style
                3 if fp addition chops, and there is
                  partial underflow
                4 if fp addition rounds, but not in the
                  IEEE style, and there is partial underflow
                5 if fp addition rounds in the IEEE style,
                  and there is partial underflow
i:  ngrd        The number of guard digits for
                  multiplication with truncating
                  arithmetic.  It is
                  0 if floating-point arithmetic rounds,
                    or if it truncates and only #DIGITS
                    base IBETA digits participate in the
                    post-normalization shift of the
                    floating-point significand in
                    multiplication;
                  1 if floating-point arithmetic truncates
                    and more than #DIGITS base IBETA digits
                    participate in the post-normalization
                    shift of the floating-point significand
                    in multiplication.
i:  macheps     The largest negative integer such that
                  1e + BETA^MACHEPS <> 1e, except that
                  MACHEPS is bounded below by -[#DIGITS+3].
                  Original name:  MACHEP
i:  negeps      The largest negative integer such that
                  1e - BETA^NEGEPS <> 1e, except that
                  NEGEPS is bounded below by -[#DIGITS+3].
                  Original name:  NEGEP
i:  iexp        The number of bits [decimal places if
                  IBETA = 10] reserved for the
                  representation of the exponent
                  [including the bias or sign] of a
                  floating-point number.
i:  minexp      The largest in magnitude negative integer
                  such that BETA^MINEXP is positive and
                  normalized.
i:  maxexp      The smallest positive power of BETA that
                  overflows.
f:  eps         The smallest positive floating-point number
                   such that 1e + EPS <> 1e.  In particular,
                   if either IBETA = 2 or IRND = 0,
                   EPS = BETA^MACHEPS.  Otherwise,
                   EPS = [BETA^MACHEPS]/2.
f:  epsneg      A small positive floating-point number
                  such that 1e - EPSNEG <> 1e.  In
                  particular, if IBETA = 2 or  IRND = 0,
                  EPSNEG = BETA^NEGEPS.  Otherwise,
                  EPSNEG = [BETA^NEGEPS]/2.  Because NEGEPS
                  is bounded below by -[#DIGITS+3], EPSNEG
                  may not be the smallest number that can
                  alter 1e by subtraction.
f:  xmin        The smallest non-vanishing normalized
                  fp power of the radix, i.e.,
                  XMIN = BETA**MINEXP.
f:  xmax        The largest finite floating-point number.
                  In particular XMAX =
                  [1.0 - EPSNEG]*BETA^MAXEXP.  Note: on
                  some machines XMAX will be only the
                  second, or perhaps third, largest
                  number, being too small by 1 or 2 units
                  in the last digit of the significand.
)


: fdepth 0 ;	\ no separate fp stack

: ?stacks  ( -- )
   depth IF .s THEN
   fdepth IF cr ." FDEPTH is " fdepth . THEN ;


: f>s   ( r -- n ) f>d drop ;
: f2/   ( r -- r/2 ) 0.5e f* ;
: fnip  ( x y -- y ) fswap fdrop ;
[UNDEFINED] f2dup [IF]
: f2dup ( x y -- x y x y ) fover fover ;
[THEN]

\ In the following, the labels A, B, etc. correspond to
\ temporary variables used in the Fortran code.  The sometimes
\ strange-looking algebra in the stack comments tries to mimic
\ the original Fortran, to minimize translation errors.

: noname  ( -- 2^u )
(
Calculate 2^U, the smallest positive integer power of 2
unaffected by the floating point addition of 1.
)
   1e               ( A=1 )
   BEGIN
     fdup f+         ( A=A+A)
     fdup 1e f+
     fover f- 1e f-  ( A [[A+1]-A]-1)
     f0= 0=
   UNTIL
   ( A) ;  ( execute) noname
fconstant 2^u

: noname  ( -- beta )
(
Find the floating point radix beta.  The algorithm adds to 2^U
the smallest power of 2 that increases its next to lowest digit,
[an increase by 1], then subtracts 2^U, whose lowest digit gets
truncated in the alignment of digits for subtraction, leaving
the radix as the difference.
)
   1e                          ( B=1)
   BEGIN
     fdup f+                   ( B=B+B)
     fdup 2^u                  ( B A)
     f+ 2^u f-                 ( B [A+B]-A)
     f>s dup 0=
   WHILE drop REPEAT ( B) >r fdrop r>
   ( radix) ; ( execute) noname
( radix) dup constant ibeta   s>f fconstant beta

: noname  ( -- #digits )
(
Calculate #digits, the number of base BETA digits in the fp
significand.  Uses BETA.
)
   0 1e                        ( #digs=0 B=1)
   BEGIN
     2>r 1+ 2r>                ( #digs=#digs+1)
     beta f*                   ( #digs B=B*beta)
     fdup fdup 1e f+
         fswap f- 1e f-        ( #digs B [B+1]-B]-1)
     f0= 0=
   UNTIL ( #digs B) fdrop ; ( execute) noname
constant #digits

(
Calculate a preliminary determination of the rounding type
as PRE-IRND.  Uses BETA and 2^U.
)
: noname
   beta f2/   fdup 2^u         ( beta/2 beta/2 A=2^u)
   f+ 2^u f-                   ( beta/2 [A+beta/2]-A])
   f0= 0=
   IF ( beta/2) fdrop 1        ( rnd.enum=1)
   ELSE
     2^u beta f+               ( beta/2 A+beta)
     fswap fover f+            ( A+beta [A+beta]+beta/2)
     fswap f-                  ( [[A+beta]+beta/2]-[A+beta])
     f0=
     IF 0 ELSE 2 THEN      ( rnd.enum=0|2)
   THEN ( rnd.enum) ; noname
constant pre-irnd

#digits 3 +  constant #digs+3
1e beta f/  fconstant 1/beta

: noname  ( -- [1/beta]^[#digits+3] )
(
Calculate [1/BETA]^[#DIGITS+3].
)
   1/beta 1e                   ( 1/beta A=1)
   #digs+3 0
   DO
     fover f*                  ( 1/beta A*1/beta)
   LOOP fnip                   ( B=[1/beta]^[#digs+3])
   ; ( execute) noname
fconstant [1/beta]^[#digits+3]

: noname  ( -- negeps epsneg )
(
Calculate NEGEPS and EPSNEG.  Uses #DIGITS, and EPSLB.
)
   #digs+3                      ( negep)
   [1/beta]^[#digits+3] fnegate ( negep -A)
   BEGIN
     fdup 1e f+ 1e f-           ( negep -A [1-A]-1)
   f0= WHILE
     beta f*                    ( negep -A=-A*beta)
     2>r 1- 2r>                 ( negep=negep-1 -A)
   REPEAT
   fnegate
   2>r negate 2r> ; ( execute) noname
fconstant epsneg   constant negeps

: noname  ( -- macheps eps )
(
Calculate MACHEPS and EPS.  Uses #DIGITS, BETA, and EPSLB.
)
   #digs+3 negate              ( macheps)
   [1/beta]^[#digits+3]        ( macheps A)
   BEGIN
     fdup 1e f+ 1e f-          ( macheps A [1+A]-1)
   f0= WHILE
     beta f*                   ( macheps A=A*beta)
     2>r 1+ 2r>                ( macheps=macheps+1 A)
   REPEAT                      ( macheps eps)
   ; ( execute) noname
fconstant eps   constant macheps

(
Calculate NGRD.  Uses EPS and PRE-IRND.
)
: noname ( -- ngrd )
   1e eps f+ 1e f* 1e f-       ( [1+eps]*1-1)
   f0= 0=   pre-irnd 0= and
   IF 1 ELSE 0 THEN ; noname
constant ngrd

fvariable pre-xmin
: noname  ( -- maxnu 2^maxnu )
(
Calculate MAXNU and 2^MAXNU, where MAXNU is the largest integer
such that [1/BETA]^[2^MAXNU] does not underflow.

Set PRE-XMIN to the preliminary value [1/BETA]^[2*MAXNU].

Uses BETA and EPS.
)
   0 1			      ( I=0 K=2^I=1)
   1/beta                      ( I K Z=1/beta)
   BEGIN
     fdup pre-xmin f!          ( I K Y=Z)
     fdup fdup f*              ( I K Y Z=Y*Y)
     fdup fabs frot            ( I K Z |Z| Y)
     f>=                       ( I K Z flag=[|Z|>=Y])
     >r
     fdup 1e f*                ( I K Z A=Z*1)
     fdup f+                   ( I K Z A+A)
     f0= r> or                 ( I K Z flag=flag.or.A+A=0)
     >r
     fdup 1e eps f+ f*
         1/beta f* beta f*     ( I K Z R=[Z*[1+eps]*1/beta]*beta])
     fover f= r> or            ( I K Z flag.or.R=Z)
   0= WHILE  \ no underflow
     2>r swap 1+ swap dup + 2r>  ( I=I+1 K=K+K Z)
   REPEAT  ( I K Z) fdrop ; ( execute) noname
constant 2^maxnu   constant maxnu

: noname  ( -- pre.exp mx )
(
Calculate  PRE-IEXP and MX, part of MAXEXP - MINEXP.  Uses
IBETA, MAXNU, and 2^MAXNU.
)
   ibeta 10 =
   IF  \ decimal machine
     2 ibeta                   ( IEXP=2 IZ=beta)
     BEGIN
       2^maxnu over            ( IEXP IZ K=2^maxnu IZ)
     < 0= WHILE                ( IEXP IZ)
       ibeta *
       swap 1+ swap            ( IEXP=IEXP+1 IZ=IZ*beta)
     REPEAT
     2* 1- ( pre.exp=IEXP mx=IZ+IZ-1)
   ELSE
     maxnu 1+ ( pre.exp)
     2^maxnu 2* ( mx)
   THEN ; ( execute) noname
constant mx   constant pre-iexp

0 value nxres
fvariable xmin/beta   fvariable xmin/beta*1
: noname  ( -- minexp )
(
Calculate MINEXP and XMIN.  Set XMIN/BETA, XMIN/BETA*1, and
NXRES, the partial underflow adjustment to the IRND enumeration.

Uses BETA, 2^MAXNU, and PRE-XMIN = [1/BETA]^[2*MAXNU].
)
   2^maxnu  		      ( K=2^maxnu)
   pre-xmin f@  	              ( K Y=[1/beta]^[2*maxnu])
   BEGIN
     fdup pre-xmin f!          ( K Y)
     1/beta f*                 ( K Y=Y*1/beta)
     fdup 1e f*                ( K Y A=Y*1)
     fdup xmin/beta*1 f!
     fdup f+ f0=               ( K Y flag=[A+A=0])
     >r
     fdup fabs pre-xmin f@ f>= r> or  ( K Y flag.or.|Y|>=xmin)
   0= WHILE
     2>r 1+ 2r>                ( K=K+1 Y)
     fdup 1e eps f+ f*         ( K Y TEMP=Y*[1+eps])
     f2dup f=                  ( K Y TEMP flag=[Y=TEMP])
     >r
     1/beta f* beta f*         ( K Y R=[TEMP*1/beta]*beta)
     fover f<> r> or           ( K Y flag.or.R<>Y)
\  0= UNTIL
    0= IF
      fdup pre-xmin f! xmin/beta f!
      3 to nxres
      negate ( minexp)
      exit
    THEN
   REPEAT
   xmin/beta f!
   negate ( minexp) ; ( execute) noname
constant minexp   pre-xmin f@ fconstant xmin

variable pre-maxexp
(
Calculate IEXP and a PRE-MAXEXP.  Uses MINEXP, IBETA, MX, and
PRE-IEXP.
)
: noname ( -- iexp )
   mx dup                      ( MX MX)
   minexp negate 2* 3 - >      ( MX flag=MX>[K+K-3])
   ibeta 10 = or               ( MX flag.or.[ibeta=10])
   0= IF
     ( MX) 2*   pre-iexp 1+    ( MX=MX+MX iexp=pre.iexp+1)
   ELSE
     pre-iexp                  ( MX iexp=pre.iexp)
   THEN
   swap ( iexp MX) minexp + pre-maxexp ! ;  noname
constant iexp

(
Calculate IRND, which reflects partial underflow.  Uses PRE-IRND
and NXRES.
)
nxres pre-irnd + constant irnd

(
Adjust PRE-MAXEXP for IEEE-style machines.  Uses IRND.
)
: noname ( -- )
   irnd 2 >= IF -2 pre-maxexp +! THEN ; noname

(
Calculate MAXEXP from the IEEE-adjusted PRE-MAXEXP, by adjusting
for machines with an implicit leading bit in the binary
significand, and machines with radix point at the extreme right
of the significand.  Uses MINEXP, IBETA, XMIN/BETA, and
XMIN/BETA*1.
)
: noname ( -- maxexp )
   pre-maxexp @                ( pm=pre.maxexp)
   dup minexp +                ( pm I=maxexp+minexp)
   dup 0=   ibeta 2 = and      ( p I I=0.and.beta=2)
   IF
     swap 1- swap              ( pm=pm-1 I)
   THEN
   ( I) 20 >
   IF
     1-                        ( pm=pm-1)
   THEN
   xmin/beta f@   xmin/beta*1 f@ f<>
   IF
     2 -                       ( pm=pm-2)
   THEN ;  noname
constant maxexp

: noname  ( -- xmax )
(
Calculate XMAX.  Uses MAXEXP, MINEXP, EPSNEG, BETA, and XMIN.
)
   1e epsneg f-                ( XMAX=1-epsneg)
   fdup fdup 1e f* f<>         ( XMAX flag=XMAX<>XMAX*1)
   IF
     ( XMAX) fdrop 1e beta
         epsneg f* f-          ( XMAX=1-beta*epsneg)
   THEN
   beta fdup fdup f* f*
       xmin f* f/              ( XMAX=XMAX/[beta*beta*beta*xmin])
   maxexp minexp + 3 +         ( XMAX I)
   dup 0>
   IF
     ( XMAX I) 0 DO
       ibeta 2 =
       IF
         fdup f+               ( XMAX=XMAX+XMAX)
       ELSE
         beta f*               ( XMAX=XMAX*beta)
       THEN
     LOOP
   THEN
   ( XMAX) ; ( execute) noname
fconstant xmax


   ?stacks
   cr .( INTERMEDIATE QUANTITIES)
   cr .( 2^u         ) 2^u fs.
   cr .( maxnu       ) maxnu .
   cr .( 2^maxnu     ) 2^maxnu .
   cr .( mx          ) mx .
   cr .( nxres       ) nxres .
   cr .( [1/beta]^[#digits+3] ) [1/beta]^[#digits+3] fs.
   cr .( xmin/beta   ) xmin/beta f@ fs.
   cr .( xmin/beta*1 ) xmin/beta*1 f@  fs.
   cr


   cr .( MACHAR PARAMETERS)
   cr .( ibeta     ) ibeta .
   cr .( beta      ) beta f.
   cr .( #digits   ) #digits .
   cr .( irnd      ) irnd .
   cr .( ngrd      ) ngrd .
   cr .( macheps  ) macheps .
   cr .( negeps   ) negeps .
   cr .( iexp      ) iexp .
   cr .( minexp   ) minexp .
   cr .( maxexp    ) maxexp .
   cr .( eps       ) eps fs.
   cr .( epsneg    ) epsneg fs.
   cr .( xmin      ) xmin fs.
   cr .( xmax      ) xmax fs.
   cr
