\ numerov-test.4th
\
\ Test the Numerov integrator using a known case.
\
\ Use the analytic solution for the non-relativistic radial equation
\ for the H atom in the 1s state.
\
\    d^2/dr^2 P_1s(r) = [ -2/r + 1 ] * P_1s(r)
\
\ which has the analytic solution,
\
\    P_1s(r) = 2*r*exp(-r)
\
\ Mapping the above differential equation to the form,
\
\    P''(r) = Q(r)P(r)
\
\ we have,
\
\   P(r) = P_1s(r)
\   Q(r) = -2/r - -1  
\
\ Note that Q(r) = [ V(r) - E_n ], with V(r) = -2/r and,
\ for the 1s state, E_1 = -1
\
\ The more general case[1] is,
\
\   V(r) = -2*Z/r + l*(l+1)/r^2
\
\ where Z is the atomic number, and l is the orbital angular
\ momentum quantum number (l = 0 for the s-state).
\
\ with eigenvalues, 
\
\    E_n = -Z^2/n^2
\
\
\ K. Myneni, 2012-03-05
\
\ Revisions:
\   2012-03-09 km changed MAXPTS to 3200; beyond this, machine
\                 precision gives no benefits -- see [2].
\   2015-02-07 km compute both absolute differences and relative
\                 differences.
\ 
\ References
\
\ 1. R. D. Cowan, The Theory of Atomic Structure and Spectra,
\      Univ. of California Press, Berkeley (1981).
\
\ 2. ftp://ccreweb.org/software/fsl/extras/numerov-test-kforth-errors.ps
\
include ans-words
include fsl/fsl-util
include fsl/dynmem
include fsl/extras/array-utils1
include fsl/extras/numerov

DECIMAL

3200 constant MAXPTS

MAXPTS FLOAT ARRAY Q{
MAXPTS FLOAT ARRAY P{

MAXPTS FLOAT ARRAY absdiffs{
MAXPTS FLOAT ARRAY reldiffs{

10e fconstant r_max
r_max MAXPTS s>f f/  fconstant  h

\ Analytic solution for P_1s(r)
: P(r) ( F: r -- P_1s[r] ) FDUP FNEGATE FEXP F* 2e F* ;

: Q(r) ( F: r -- Q[r] )  -2e FSWAP F/ 1e F+ ;

: setup-Q ( -- )
    0e MAXPTS 0 DO  h F+ FDUP Q(r) Q{ I } F!  LOOP fdrop ;

: calc ( -- )
    setup-Q

    \ Set up first two points in P{ :
    \ we use analytic values for these two points to avoid having
    \ to renormalize the solution and iterate the integration.
    h P(r) P{ 0 } F!  h 2e F* P(r) P{ 1 } F!

    \ Perform the Numerov integration
    P{ Q{ MAXPTS h numerov_integrate

    \ Compute the absolute and relative difference arrays
    0e MAXPTS 0 DO h F+ FDUP P(r) P{ I } F@ F-  absdiffs{ I } F! LOOP
    FDROP
    0e MAXPTS 0 DO  
       h F+ FDUP P(r) FDUP P{ I } F@ F- FSWAP F/
       FABS reldiffs{ I } F!
    LOOP
    FDROP  

    \ Find and print the max absolute and relative difference
    MAXPTS absdiffs{ }fmax FABS
    MAXPTS absdiffs{ }fmin FABS
    FMAX

    CR ." From R = " h F. ."  to R = " r_max F. ."  with " MAXPTS .
    ."  points,"
    CR ." Maximum absolute difference = " FS.
    CR ." Maximum relative difference = " MAXPTS reldiffs{ }fmax FS.
;

calc

0 [IF]  \ kForth specific
: save-calc ( -- )
    \ Write data to file, numerov-test.dat
    s" >file numerov-test.dat" evaluate
    0e MAXPTS 0 DO
	h F+ FDUP FS. 2 SPACES   \ 1st col: r
	P{ I } F@ FS. 2 SPACES   \ 2nd col: numerical soln of P_1s
	FDUP P(r) FS. CR         \ 3rd col: analytic  soln of P_1s
    LOOP
    FDROP
    console

    CR ." Data written to numerov-test.dat!"
;
[THEN]


