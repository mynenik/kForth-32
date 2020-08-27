\ ieee-754.4th
\ 
\ Provides additional definitions for IEEE 754 double-precision
\ floating point arithmetic on x87 FPU
\
\ K. Myneni, 2020-08-20
\ Rev. 2020-08-27

BASE @
DECIMAL
0e fconstant F=ZERO
HEX

1 cells 4 = [IF]

\ Make an IEEE 754 double precision floating point value from
\ the specified bits for the sign, binary fraction, and exponent.
\ Return the fp value and error code with the following meaning:
\   0  no error
\   1  exponent out of range
\   2  fraction out of range
fvariable temp

: MAKE-IEEE-DFLOAT ( signbit udfraction uexp -- r nerror )
    dup 800 u< invert IF 2drop 2drop F=ZERO 1 EXIT THEN
    14 lshift 3 pick 1F lshift or >r
    dup 100000 u< invert IF 
      r> 2drop 2drop F=ZERO 2 EXIT 
    THEN
    r> or [ temp cell+ ] literal ! temp !
    drop temp df@ 0 ;

: FSIGNBIT ( r -- minus? )
    temp df! [ temp cell+ ] literal @ 80000000 and 0<> ;

: FEXPONENT ( r -- u )
    temp df! [ temp cell+ ] literal @ 14 rshift 7FF and ;

: FFRACTION ( r -- ud )
    temp df! temp @  [ temp cell+ ] literal @ 000FFFFF and ;

: FINITE?  ( r -- [normal|subnormal]? ) fexponent 7FF <> ;

: FNORMAL? ( r -- normal? )  fexponent 0<> ;

: FSUBNORMAL? ( r -- subnormal? )  fexponent 0= ;

: FINFINITE? ( r -- [+/-]Inf? )
   temp df! temp @ 7FFF and 0<> [ temp cell+ ] literal @ 0= and 0<> ; 

: FNAN? ( r -- nan? ) 
   fdup FEXPONENT 7FF = >r FFRACTION D0= invert r> and ; 


\ Exception bits in fpu status word

 1  constant  FINVALID
 4  constant  FDIVBYZERO
 8  constant  FOVERFLOW
10  constant  FUNDERFLOW
20  constant  FINEXACT

FINVALID FDIVBYZERO or FOVERFLOW or FUNDERFLOW or FINEXACT or  
constant ALL-FEXCEPTS

: GET-FFLAGS ( excepts -- flags )
    getFPUstatusX86 fpu-status @ and ;

: CLEAR-ALL-FFLAGS ( -- ) clearFPUexceptionsX86 ;

: CLEAR-FFLAGS ( excepts -- )
;

: SET-FFLAGS ( excepts -- )
;

: FENABLE ( excepts -- )
;

: FDISABLE ( excepts -- )
;


: FNEARBYINT ( r1 -- r2 )
;

: FNEXTUP ( r1 -- r2 )
;

: FNEXTDOWN ( r1 -- r2 )
;

: FSCALBN ( r n -- r*2^n )
;

: FLOGB ( r -- e )
;

: FREMAINDER ( x y -- r q )

;

[ELSE]
cr .( 32-bit system only! ) cr
[THEN]

\ Constants representing  -INF  +INF  -NAN  +NAN
true  0 0 7FF make-ieee-dfloat 0= [IF] fconstant -INF [ELSE] fdrop [THEN]
[DEFINED] -INF [IF] -INF fnegate fconstant +INF [THEN]
true  1 0 7FF make-ieee-dfloat 0= [IF] fconstant -NAN [ELSE] fdrop [THEN]
[DEFINED] -NAN [IF] -NAN fnegate fconstant +NAN [THEN]


BASE !
