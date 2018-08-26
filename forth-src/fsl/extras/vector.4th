\ vector.4th
\
\ Auxiliary utility words for working with floating point vectors in the 
\ Forth Scientific Library.
\
\ The term "vector" is used here synonymously with a 1D FLOAT ARRAY.
\
\ K. Myneni
\
\ 

: vector FLOAT ARRAY ;

[UNDEFINED] ptr [IF] : ptr  CREATE 1 CELLS ?allot ! DOES> a@ ; [THEN]

FVARIABLE vtemp

: vscale ( N 'v f -- | scale the components of a vector by f )
    vtemp F! 
    SWAP 0 ?DO  DUP I } DUP >R F@ vtemp F@ F* R> F!  LOOP  DROP ;

: vmag ( N 'v -- f | return magnitude of a vector )
    0e vtemp F!
    SWAP 0 ?DO  DUP I } F@ FDUP F* vtemp F@ F+ vtemp F!  LOOP  DROP 
    vtemp F@ FSQRT ;     

: vnorm ( N 'v -- | normalize a vector )
    2DUP vmag 1e FSWAP F/ vscale ;

: vmaxabs ( N 'v -- f | return element with max absolute value for a vector )
    0e vtemp F!
    SWAP 0 ?DO  DUP I } F@ FABS vtemp F@ FMAX vtemp F!  LOOP  DROP vtemp F@ ;


0 ptr  v1{
0 ptr  v2{

: vdot ( N 'v1 'v2 -- f | Return dot product of two vectors )
    TO v2{  TO v1{ 
    0e vtemp F!
    0 ?DO  v1{ I } F@  v2{ I } F@ F* vtemp F@ F+ vtemp F!  LOOP
    vtemp F@ ;

: v+ ( N 'v1 'v2 'v3 -- | add two vectors: v3 = v1 + v2 )
    >r TO v2{ TO v1{ r>
    SWAP 0 ?DO  DUP I } v1{ I } F@ v2{ I } F@ F+ ROT F! LOOP DROP ;

: v- ( N 'v1 'v2 'v3 -- | subtract two vectors: v3 = v1 - v2 )
    >r TO v2{ TO v1{ r>
    SWAP 0 ?DO  DUP I } v1{ I } F@ v2{ I } F@ F- ROT F! LOOP DROP ;
     
0 ptr  Ain{{

: v* ( N 'A 'v1 'v2 -- | v2 = A*v1; multiply NxN matrix and N-element vector )
    TO v2{  TO v1{  TO Ain{{
    3 0 DO
      0e
      3 0 DO  Ain{{ J I }} F@  v1{ I } F@ F* F+  LOOP
      v2{ I } F!
    LOOP ;

