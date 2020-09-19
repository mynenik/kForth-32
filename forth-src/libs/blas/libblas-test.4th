\ libblas-test.4th
\
\ Test the Forth interface to the BLAS routines
\
\ Copyright (c) 2009 Krishna Myneni, Creative Consulting for 
\   Research and Education,  krishna.myneni@ccreweb.org
\
\ Notes:
\ 
\   1. These tests are used to validate the Forth interface to
\      the 32-bit FORTRAN version of the BLAS library. The purpose
\      of the tests is not to rigorously test the BLAS routines,
\      but to ensure that calling the library routines from Forth 
\      gives the expected results.
\
\   2. Some examples are taken from Refs. [1--4].
\
\
\ References:
\
\ [1] Handbook for matrix computations by T. F. Coleman and 
\     C. F. van Loan
\
\ [2] http://www.gnu.org/software/gsl/manual/html_node/GSL-CBLAS-Examples.html
\
\ [3] http://sensawave.com/manuals/SENSAWAVE-manual/SENSAWAVE-manual_5.html
\
\ [4] http://www.intel.com/software/products/mkl/docs/webhelp/appendices/mkl_appC_BLAS.html
\
 
include ans-words
include modules.fs
include syscalls
include mc
include asm
include strings
include libblas
include fsl/fsl-util
include fsl/complex
include ttester

[UNDEFINED] SFLOAT  [IF] 1 SFLOATS CONSTANT SFLOAT  [THEN]
[UNDEFINED] COMPLEX [IF] 2 FLOATS  CONSTANT COMPLEX [THEN]
[UNDEFINED] SFVARIABLE [IF] : SFVARIABLE CREATE 1 SFLOATS ALLOT ; [THEN]

: }sfput ( r1 ... r_n n 'a -- | store r1 ... r_n into array of size n )
     SWAP DUP 0 ?DO  1- 2DUP 2>R } SF! 2R>  LOOP  2DROP ;

: }zput ( z1 ... z_n n 'a -- | store z1 ... z_n into array of size n )
     SWAP DUP 0 ?DO  1- 2DUP 2>R } z! 2R>  LOOP  2DROP ;


variable N
variable M
variable incx
variable incy
variable lda

fvariable alpha
fvariable a
fvariable b
fvariable c
fvariable s

10 SFLOAT  array sx{
10 SFLOAT  array sy{
10 FLOAT   array  x{
10 FLOAT   array  y{
10 COMPLEX array zx{
10 COMPLEX array zy{

COMMENT Level 1 BLAS
TESTING SNRM2 SDOT DSDOT DNRM2 DDOT 
set-near
3 N !
1 incx !
1 incy !
-3e 1e  5e 3 sx{ }sfput 
 7e 0e -2e 3 sy{ }sfput
1e-7 rel-near f!
t{ N sx{ incx  SNRM2  ->  5.91608e r}t
t{ N sx{ incx sy{ incy SDOT -> -31e r}t

1e-15 rel-near f!
t{ N sx{ incx sy{ incy DSDOT -> -31e r}t

-3e 1e  5e  3 x{ }fput
 7e 0e -2e  3 y{ }fput
1e-15 rel-near f!
t{ N x{ incx  DNRM2  ->  5.9160797830996161e  r}t
t{ N x{ incx y{ incy DDOT ->  -31e r}t


TESTING SAXPY DAXPY
set-near

3 N !
1 incx !
1 incy !

0.1e alpha sf!             \ <-- Note alpha is used as single precision real
-3e 1e  5e 3 sx{ }sfput 
 7e 0e -2e 3 sy{ }sfput
1e-7 rel-near f!
t{  N alpha sx{ incx sy{ incy SAXPY ->  }t
t{  sy{ 0 } sf@  ->   6.7e  r}t
t{  sy{ 1 } sf@  ->   0.1e  r}t
t{  sy{ 2 } sf@  ->  -1.5e  r}t

0.1e alpha f!
-3e 1e  5e  3 x{ }fput
 7e 0e -2e  3 y{ }fput
1e-15 rel-near f!
t{  N alpha  x{ incx  y{ incy DAXPY ->  }t
t{   y{ 0 } f@  ->   6.7e  r}t
t{   y{ 1 } f@  ->   0.1e  r}t
t{   y{ 2 } f@  ->  -1.5e  r}t


TESTING ISAMAX IDAMAX SASUM DASUM
-2e -3e 0e 1e 5.5e -3e 6 sx{ }sfput
-2e -3e 0e 1e 5.5e -3e 6  x{ }fput
1 incx !
6 N !

t{ N sx{ incx isamax  ->  5  }t
t{ N  x{ incx idamax  ->  5  }t

set-near
1e-7 rel-near f!
t{ N sx{ incx sasum   ->  14.5e r}t
1e-15 rel-near f!
t{ N  x{ incx dasum   ->  14.5e r}t


TESTING SCOPY DCOPY
set-exact
: set-sx 10 0 DO  I 1+ s>f sx{ I } sf!  LOOP ;
: set-x  10 0 DO  I 1+ s>f  x{ I }  f!  LOOP ;
set-sx
set-x
10 N !
1 incx !
1 incy !
t{ N sx{  incx sy{  incy  SCOPY  ->  }t
t{ sy{ 0 } sf@  ->  1e  r}t
t{ sy{ 4 } sf@  ->  5e  r}t
t{ sy{ 9 } sf@  -> 10e  r}t
t{ N  x{  incx  y{  incy  DCOPY  ->  }t
t{  y{ 0 }  f@  ->  1e  r}t
t{  y{ 4 }  f@  ->  5e  r}t
t{  y{ 9 }  f@  -> 10e  r}t

0 [IF]
TESTING ZDOTC ZDOTU
set-near
1e-15 rel-near f!
3 N !
1 incx !
1 incy !

\ 1-i1  i  3+i2
1e -1e  0e 1e  3e 2e  3 zx{ }zput
\ -2  5-i2 -i
-2e 0e  5e -2e  0e -1e  3 zy{ }zput
t{ N  zx{  incx  zy{  incy  ZDOTU  ->  -6e -10e  rr}t
[THEN]


TESTING SROTG DROTG
set-near
: set-srotg-vals  s sf!  c sf!  b sf!  a sf! ;
: get-srotg-vals  a sf@  b sf@  c sf@  s sf@ ;
: set-drotg-vals  s df!  c df!  b df!  a df! ;
: get-drotg-vals  a df@  b df@  c df@  s df@ ;

1e-7 rel-near f!
4e 3e 0e 0e set-srotg-vals
t{ a b c s SROTG  get-srotg-vals  ->  5e 0.6e 0.8e 0.6e rrrr}t

1e-15 rel-near f!
4e 3e 0e 0e set-drotg-vals
t{ a b c s DROTG  get-drotg-vals  ->  5e 0.6e 0.8e 0.6e rrrr}t

cr 
COMMENT Level 2 BLAS
TESTING SGER
set-near

0.5e alpha sf!
2 M ! 
3 N ! 
2 lda ! 
1 incx ! 
1 incy !
1e 1e 2 sx{ }sfput  
1e 1e 1e 3 sy{ }sfput 

2 3 SFLOAT matrix sa{{
1e sa{{ 0 0 }} sf!
2e sa{{ 0 1 }} sf!
3e sa{{ 0 2 }} sf!
1e sa{{ 1 0 }} sf!
2e sa{{ 1 1 }} sf!
3e sa{{ 1 2 }} sf!

1e-7 rel-near f!
t{  M  N  alpha  sx{  incx  sy{  incy  sa{{  lda  SGER  ->  }t
t{  sa{{ 0 0 }} sf@  ->  1.5e  r}t
t{  sa{{ 0 1 }} sf@  ->  2.5e  r}t
t{  sa{{ 0 2 }} sf@  ->  3.5e  r}t
t{  sa{{ 1 0 }} sf@  ->  1.5e  r}t
t{  sa{{ 1 1 }} sf@  ->  2.5e  r}t
t{  sa{{ 1 2 }} sf@  ->  3.5e  r}t

0 [IF]
\ TESTING DGEMM
set-near
2 3 FLOAT matrix A{{
0.11e 0.12e 0.13e
0.21e 0.22e 0.23e 
2 3 A{{ }}fput

3 2 FLOAT matrix B{{
1011e 1012e
1021e 1022e
1031e 1032e
3 2 B{{ }}fput

2 2 FLOAT matrix C{{

[THEN]


