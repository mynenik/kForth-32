(
 * LANGUAGE    : ANS Forth with extensions
 * PROJECT     : Forth Environments
 * DESCRIPTION : Ferrari's method to solve a quartic equation
 * CATEGORY    : Numeric Utility
 * AUTHOR      : Marcel Hendrix
 * LAST CHANGE : February 23, 2012, Marcel Hendrix
 )
\ Requires the FSL auxiliary file ( fsl/fsl-util )
\ and the complex Library ( FSL Algorithm #60, fsl/complex )
\
\ Revisions:
\   2012-02-23 km; ported to standard Forth, and adapted to
\                  use FSL complex library; also put in
\                  FSL form, using km/dnw's modules library

CR .( --- Solve a Quartic     Version 0.01b --- )

0 [IF]

  The quartic is the highest order polynomial equation that can be solved by
  radicals in the general case (i.e., one where the coefficients can take any
  value).

  Lodovico Ferrari is attributed with the discovery of the solution to the
  quartic in 1540, but since this solution, like all algebraic solutions of
  the quartic, requires the solution of a cubic to be found, it couldn't be
  published immediately. The solution of the quartic was published together
  with that of the cubic by Ferrari's mentor Gerolamo Cardano in the book Ars
  Magna (1545).

  The proof that four is the highest degree of a general polynomial for which
  such solutions can be found was first given in the Abel-Ruffini theorem in
  1824, proving that all attempts at solving the higher order polynomials
  would be futile. The notes left by Evariste Galois prior to dying in a duel
  in 1832 later led to an elegant complete theory of the roots of polynomials,
  of which this theorem was one result.
  ( http://en.wikipedia.org/wiki/Quartic_function )

[THEN]

BASE @ DECIMAL

Begin-Module

[UNDEFINED] F2* [IF] : F2* 2e F* ; [THEN]
[UNDEFINED] 1/F [IF] : 1/F 1e FSWAP F/ ; [THEN]
[UNDEFINED] F0<> [IF] : F0<> F0= INVERT ; [THEN]
: fsqr  ( F: r -- r^2 ) FDUP F* ;
: fcube ( F: r -- r^3 ) FDUP FDUP F* F* ;
: fquad ( F: r -- r^4 ) fsqr fsqr ;
: fcbrt ( F: r -- r^[1/3] )  3e 1/F F** ;
: zfloats ( u1 -- u2 ) complexes ;
: zfloat+ ( a1|n1 -- a2|n2 ) 1 zfloats + ;
: z@+ ( F: -- z ) ( a1 -- a2 )  \ or ( a1 -- a2 z )
    dup zfloat+ swap z@ ;
: complex[] ( a1 n -- a2 ) zfloats + ;
 
FVARIABLE a
FVARIABLE b
FVARIABLE c
FVARIABLE d
FVARIABLE e
  1e a F!
  0e b F!
  6e c F!
-60e d F!
 36e e F!

FVARIABLE alpha
FVARIABLE beta
FVARIABLE gamma
  0e alpha F!
  0e beta  F!
  0e gamma F!

FVARIABLE p
FVARIABLE q
FVARIABLE +r
  0e p  F!
  0e q  F!
  0e +r F!

0e 0e zconstant 0+0i
zvariable +u
zvariable  y
zvariable  w
0+0i +u z!
0+0i  y z!
0+0i  w z!

CREATE qsol 4 zfloats ALLOT

: alpha! ( -- )
        b F@ a F@ F/ fsqr -3e F* 8e F/
        c F@ a F@ F/ F+ alpha F! ;

: beta! ( -- )
        b F@ a F@ F/ fcube 8e F/
        b F@ c F@ F*   a F@ fsqr F2* F/  F-
        d F@ a F@ F/ F+ beta F! ;

: gamma! ( -- )
        b F@ a F@ F/ fquad  -3e F*  256e F/
        c F@ b F@ fsqr F*  a F@ fcube 16e F* F/  F+
        b F@ d F@ F*  a F@ fsqr 4e F* F/  F-
        e F@ a F@ F/ F+ gamma F! ;

FVARIABLE a1
FVARIABLE a2

: beta=0? ( -- bool )
        beta F@ F0<> IF  FALSE EXIT  THEN  
        alpha F@ fsqr  gamma F@ 4e F* F-  FSQRT a2 F!
        b F@  a F@ -4e F* F/ a1 F!
        alpha F@ FNEGATE a2 F@ F+  F2/  FSQRT  a1 F@ F+  0e ( R,I->Z)  qsol 0 complex[] z!
        alpha F@ FNEGATE a2 F@ F-  F2/  FSQRT  a1 F@ F+  0e ( R,I->Z)  qsol 1 complex[] z!
        alpha F@ FNEGATE a2 F@ F+  F2/  FSQRT  a1 F@ F-  0e ( R,I->Z)  qsol 2 complex[] z!
        alpha F@ FNEGATE a2 F@ F-  F2/  FSQRT  a1 F@ F-  0e ( R,I->Z)  qsol 3 complex[] z!
        TRUE ;

: p!  ( -- ) alpha F@ fsqr  -12e  F/  gamma F@ F- p F! ;
: q!  ( -- ) alpha F@ fcube -108e F/  alpha F@ gamma F@ F*
	     3e F/ F+  beta F@ fsqr 8e F/ F- q F!  ;
: +r! ( -- ) q F@ -0.5e F* ( a1)  q F@ fsqr 4e F/  p F@ fcube 27e F/ F+ FSQRT
	     ( a2) F+ +r F! ;
: +u! ( -- ) +r F@ 0e ( R,I->Z)   3e 1/F 0e ( R,I->Z) z^ +u z! ;

: y! ( -- )
        +u z@ 0+0i z= IF  alpha F@ -5e F* 6e F/  q F@ 
	fcbrt F- 0e ( R,I->Z) y z! EXIT  THEN
        alpha F@ -5e F* 6e F/ 0e ( R,I->Z)
        +u z@ z+  
        p F@ 3e F/ 0e ( R,I->Z)  +u z@ z/  z- y z! ;

: w! ( -- ) alpha F@ 0e ( R,I->Z)  y z@ 2e z*f z+  zsqrt w z! ;

Public:

: setup-quartic ( F: a b c d e -- )
        e F! d F! c F! b F! a F!
        alpha! beta! gamma!
        beta=0? IF EXIT THEN
        p! q! +r! +u! y! w! ;

Private:

zvariable zterm1
zvariable zterm2
zvariable za1
zvariable za2
zvariable za3+
zvariable za3-

Public:

: compute-quartic ( -- addr )
        beta F@ F0= IF  qsol EXIT  THEN

        alpha F@ 3e F* 0e  ( R,I->Z)   y z@ 2e z*f z+  zterm1 z!
        beta  F@ F2*   0e  ( R,I->Z)   w z@        z/  zterm2 z!

        b F@ a F@ F/  -4e F/  0e ( R,I->Z)    za1 z!
        w z@ 2e z/f                           za2 z!
        zterm1 z@ zterm2 z@ z+  znegate zsqrt  2e z/f za3+ z!
        zterm1 z@ zterm2 z@ z-  znegate zsqrt  2e z/f za3- z!

        za1 z@ za2 z@ z+ za3+ z@ z+  qsol 0 complex[] z! \ the sign distribution is tricky
        za1 z@ za2 z@ z+ za3+ z@ z-  qsol 1 complex[] z!
        za1 z@ za2 z@ z- za3- z@ z-  qsol 2 complex[] z!
        za1 z@ za2 z@ z- za3- z@ z+  qsol 3 complex[] z!

        qsol ;

: quartic[] ( ix -- addr ) ( F: a b c d -- ) setup-quartic compute-quartic ;
: .quartic ( addr -- ) 4 0 ?DO  z@+ CR ." x" I 1+ 0 .R ."  = " zs.  LOOP DROP ;


End-Module
BASE !

TEST-CODE? [IF]
zvariable x

: xeval ( F: z1 -- z2)
    x z!  x z@ 4 Z^n  x z@ z^2 6e z*f z+  x z@ 60e z*f z-  36e 0e ( R,I->Z) z+ ;

: test-Cardano \ -- Cardano's problem x^4 + 6x^2 - 60x + 36 = 0
    1e 0e 6e -60e 36e setup-quartic
    CR ." Beta == 0 -> " beta F@ F0= IF ." TRUE" ELSE ." FALSE" THEN
    CR ." +R = " +r F@ F.
    CR ." +U = " +u z@ zs.
    CR ." W  = "  w z@ zs.
    CR ." y  = "  y z@ zs.
    compute-quartic
    4 0 DO  
	z@+ CR ." x" I 1+ 0 .R ."  = " zdup zs. ." -> " xeval zs.  
    LOOP DROP 
;

(
        FORTH> test-cardano
        Beta == 0 -> FALSE
        +R = 374.1276730966858224403
        +U =  7.2056518963939844012e0  + i0.0000000000000000000e0
        W  =  3.7442732882456315480e0  + i0.0000000000000000000e0
        y  =  4.0097912285348771276e0  + i0.0000000000000000000e0
        x1 =  3.0998744240188162990e0  + i0.0000000000000000000e0 ->  1.9012569296705805754e-14 + i0.0000000000000000000e0
        x2 =  6.4439886422681535992e-1 + i0.0000000000000000000e0 ->  7.2615524704389144972e-15 + i0.0000000000000000000e0
        x3 = -1.8721366441228157740e0  - i3.8101353367982659924e0 ->  3.6776137690708310402e-15 + i3.3903435614490717854e-14
        x4 = -1.8721366441228157740e0  + i3.8101353367982659924e0 ->  3.6776137690708310402e-15 - i3.3903435614490717854e-14  ok
)

CR .( Try: 1e 0e 6e -60e 36e QUARTIC[] .QUARTIC -- Solve x^4 + 6x^2 - 60x + 36 = 0 )
CR .( Should give: )
CR .(   x1 =  3.0998744240188162990e+0 + i0.0000000000000000000e0 )
CR .(   x2 =  6.4439886422681535992e-1 + i0.0000000000000000000e0 )
CR .(   x3 = -1.8721366441228157740e+0 - i3.8101353367982659924e0 )
CR .(   x4 = -1.8721366441228157740e+0 + i3.8101353367982659924e0 )

[THEN]

                              ( End of Source ) 

