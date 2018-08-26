\ mmul_x86.4th
\
\ Double precision floating point matrix multiplication
\ for an integrated data/fp stack, for 1 DFLOATS occupying
\ 2 cells.
\
\ Krishna Myneni, Creative Consulting for Research
\ and Education
\
\ Usage: a1 a2 a3 nr1 nc1 nc2 df_mmul
\
\ Requires:
\   ans-words.4th
\   modules.4th
\   fsl/fsl-util.4th
\
\ Revisions:
\   2017-05-27  km; created from mmul.4th; added CODE defn.
\                   for DF_MUL_R1C2.
\
\ Notes:
\   0. Matrix data is assumed to be stored in row order
\
\   1. Only the word DF_MMUL is specific for an integrated
\      data/fp stack. Other words work with separate fp
\      stack.

CR .( MMUL_x86           V1.2          27 May  2017 )

BEGIN-MODULE

BASE @
DECIMAL

variable nc1
variable nc2
variable a1
variable a2
variable roffs1
variable roffs2

Public:

\ Convert row of a1 and column of a2 to
\ corresponding addresses
: df_r1c2>a1a2 ( row1 col2 -- arow1 acol2 )
    dfloats a2 a@ + >r
    roffs1 @ * a1 a@ + r>   \ -- arow1 acol2
;

CODE _df_r1c2>a1a2 ( row1 col2 -- arow1 acol2 )
        DFLOAT #  eax mov,
	D-PTR   0 [ebx]  imul,
	a2 #@     eax    add,
	eax     0 [ebx]  mov,     
        TCELL #   ebx    add,
        roffs1 #@ eax   mov,
	D-PTR  0  [ebx]  imul,
	a1 #@     eax    add,
	eax    0  [ebx]  mov,
	TCELL #   ebx    sub,
	0 #       eax    mov,
END-CODE

CODE df_mul_r1c2 ( row1 col2 -- rsum )
	call-code _df_r1c2>a1a2
	          ebx  push,
	0 [ebx]   edx  mov,   \ edx = acol2
	TCELL #   ebx  add,
	0 [ebx]   ebx  mov,   \ ebx = arow1
	               fldz,
	nc1 #@    ecx  mov,
	DO,
	       0 [ebx] fld,
	       0 [edx] fld,
	               fmulp,
		       faddp,
	DFLOAT #  ebx  add,
	roffs2 #@ edx  add,
	LOOP,
	          ebx  pop,
	       0 [ebx] fstp,
END-CODE	

: set_mmul_params ( a1 a2 a3 nr1 nc1 nc2 -- a3 nr1 )
    nc2 ! nc1 ! 2>r a2 ! a1 !
    \ offsets to next row for a1 and a2
    nc1 @ dfloats roffs1 !
    nc2 @ dfloats roffs2 !
    2r> ;

\ Multiply two double-precision matrices with data beginning at
\ a1 and a2, and store at a3. Proper memory allocation is
\ assumed, as are the dimensions for a2, i.e. nr2 = nc1 is
\ assumed. This word assumes an integrated data/fp stack.
: df_mmul ( a1 a2 a3 nr1 nc1 nc2 -- )
    set_mmul_params
    0 DO
      nc2 @ 0 DO
        J I df_mul_r1c2 2 pick f!
        dfloat+
      LOOP
    LOOP
    drop
;

BASE !

END-MODULE

TEST-CODE? [IF]
[undefined] T{ [IF] s" ttester.4th" included  [THEN]

base @
decimal

\ Allot and initialize three 2x2 matrices

2 2 dfloat matrix a{{
2 2 dfloat matrix b{{
2 2 dfloat matrix c{{

cr

t{ 1e a{{ 0 0 }} f! ->  }t
t{ 2e a{{ 0 1 }} f! ->  }t
t{ 3e a{{ 1 0 }} f! ->  }t
t{ 4e a{{ 1 1 }} f! ->  }t

t{ 5e b{{ 0 0 }} f! ->  }t
t{ 6e b{{ 0 1 }} f! ->  }t
t{ 7e b{{ 1 0 }} f! ->  }t
t{ 8e b{{ 1 1 }} f! ->  }t

TESTING df_mmul

set-near
1e-16 rel-near f!

t{ a{{ 0 0 }} b{{ 0 0 }} c{{ 0 0 }} 2 2 2 df_mmul -> }t
t{ c{{ 0 0 }} f@  ->  19e r}t
t{ c{{ 0 1 }} f@  ->  22e r}t
t{ c{{ 1 0 }} f@  ->  43e r}t
t{ c{{ 1 1 }} f@  ->  50e r}t

\ Compute the product of a 3x4 matrix with a 4x4 matrix
3 4 dfloat matrix d{{
4 4 dfloat matrix e{{
3 4 dfloat matrix f{{

t{ 1e         0.5e      0.25e        2e 
   1e 3e f/   0.75e     5e 6e f/     3e
   2e 3e f/   5e 4e f/  6e 7e f/     11e 12e f/
   3 4 d{{ }}fput  ->  }t

t{ 10e       9e         8e         7e
   6e        5e         4e         3e
   2e        1e         0.5e       0.25e
   1e 8e f/  1e 16e f/  1e 3e f/   2e 3e f/ 
   4 4 e{{ }}fput  ->  }t

t{ d{{ 0 0 }} e{{ 0 0 }} f{{ 0 0 }} 3 4 4 df_mmul  -> }t
t{ f{{ 0 0 }} f@  ->  10e 3e f+ 0.5e f+ 0.25e f+  r}t
t{ f{{ 0 1 }} f@  ->  9e 2.5e f+ 0.25e f+ 0.125e f+  r}t
t{ f{{ 0 2 }} f@  ->  8e 2e f+ 0.125e f+ 2e 3e f/ f+  r}t
t{ f{{ 0 3 }} f@  ->  7e 1.5e f+ 1e 16e f/ f+ 4e 3e f/ f+  r}t
t{ f{{ 1 0 }} f@  ->  10e 3e f/ 4.5e f+ 5e 3e f/ f+ 3e 8e f/ f+  r}t
t{ f{{ 1 1 }} f@  ->  3e 3.75e f+ 5e 6e f/ f+ 3e 16e f/ f+  r}t
t{ f{{ 1 2 }} f@  ->  8e 3e f/ 3e f+ 5e 12e f/ f+ 1e f+  r}t
t{ f{{ 1 3 }} f@  ->  7e 3e f/ 2.25e f+ 5e 24e f/ f+ 2e f+ r}t
t{ f{{ 2 0 }} f@  ->  20e 3e f/ 7.5e f+ 12e 7e f/ f+ 11e 96e f/ f+  r}t
t{ f{{ 2 1 }} f@  ->  6e 6.25e f+ 6e 7e f/ f+ 11e 192e f/ f+  r}t
t{ f{{ 2 2 }} f@  ->  16e 3e f/ 5e f+ 3e 7e f/ f+ 11e 36e f/ f+  r}t
t{ f{{ 2 3 }} f@  ->  14e 3e f/ 3.75e f+ 3e 14e f/ f+ 11e 18e f/ f+  r}t

base !
[THEN]

