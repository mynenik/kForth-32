\ ANEW  --Ran-Next--                              \  Wil Baden  2003-01-17

\  *********************************************************************
\  *                                                                   *
\  *  D E Knuth  2002-11-10                                            *
\  *                                                                   *
\  *     RAN-NEXT  ( -- urandom )                                      *
\  *                                                                   *
\  *  Knuth's recommended random number generator from TAOCP,          *
\  *  updated 2002.                                                    *
\  *                                                                   *
\  *  Transformed to pure Core Forth by Wil Baden from:                *
\  *     http://www-cs-faculty.stanford.edu/~knuth/programs/rng.c      *
\  *                                                                   *
\  *  This generator is good for billions of numbers, unlike a         *
\  *  linear congruential sequence in 32-bIt arithmetic (good for a    *
\  *  few million numbers), or a linear congruential sequence in       *
\  *  16-bit arithmetic, such as from _Starting Forth_ (good for       *
\  *  about five dozen numbers).                                       *
\  *                                                                   *
\  *  Operations are all shift, add, or subtract.                      *
\  *                                                                   *
\  *  Needs two's complement arithmetic.                               *
\  *                                                                   *
\  *  [Abstract by WB.]                                                *
\  *                                                                   *
\  *********************************************************************

\    Knuth: "Every block of 100 consecutive values ... in the subsequent
\    output of [Ran-Array] will be distinct from the blocks that occur
\    with another seed. ... Several processes can therefore start in
\    parallel with different seeds and be sure that they are doing
\    independent calculations."

100 CONSTANT  KK           \  the long lag
37  CONSTANT  LL           \  the short lag
1 30 LSHIFT CONSTANT  MM   \  the modulus

\  Mod-Diff       ( n1 n2 -- n3 )
\     subtraction mod MM
\     [Knuth defines this as a macro.]

: Mod-Diff  S" - MM 1- AND " EVALUATE ; IMMEDIATE

    : TH  S" 2 LSHIFT + " EVALUATE ; IMMEDIATE
    : @PTR  a@ ;  \ use a@ for kForth instead of @
    : !PTR  ! ;

: SPACE BL EMIT ;

CREATE Ran-X  KK CELLS ALLOT  \  the generator state

\  ***************************  Ran-Array  ***************************

\  Ran-Array   ( aa n -- )
\     put n new random numbers in aa
\     aa   destination
\     n    array length (must be at least KK)

: Ran-Array                ( aa n -- )
    KK 0 DO
        over  Ran-X I TH @
            SWAP I TH !
    LOOP
    dup KK ?DO
        over  dup I KK - TH @   over I LL - TH @  Mod-Diff
            SWAP I TH !
    LOOP                     ( aa j)
    LL 0 DO
        2dup  LL - TH @  >R  2dup  KK - TH @  R> Mod-Diff
            Ran-X I TH !
        1+
    LOOP
    KK LL ?DO
        2dup KK - TH @  Ran-X I LL - TH @  Mod-Diff
            Ran-X I TH !
        1+
    LOOP
    2DROP ;

\  the following routines are from exercise 3.6--15
\  after calling ran_start, get new randoms by, e.g., "x=ran_arr_next()"

1009 CONSTANT  QUALITY  \  recommended quality level for high-res use
CREATE  Ran-Arr-Buf   QUALITY CELLS ALLOT

VARIABLE Ran-Arr-Dummy    -1 Ran-Arr-Dummy !
VARIABLE Ran-Arr-Started  -1 Ran-Arr-Started !
\ CREATE  Ran-Arr-Dummy  -1 ,
\ CREATE  Ran-Arr-Started  -1 ,

\  [pointer to] the next random number, or -1
\ CREATE  Ran-Arr-PTR  0 ,  
VARIABLE Ran-Arr-PTR
Ran-Arr-Dummy Ran-Arr-PTR !PTR

\  guaranteed separation between streams
70 CONSTANT  TT

\  ***************************  Ran-Start  ***************************

\   Ran-Start               ( seed -- )
\     do this before using ran_array
\     seed  selector for different streams

KK 2* 1- CELLS CREATE  X  ALLOT  \  the preparation buffer

: Ran-Start                ( seed -- )
    dup  2 +  MM 2 -  AND    ( seed ss)
    KK 0 DO
        dup  X I TH !             \  bootstrap the buffer
        1 LSHIFT  dup MM < NOT    \  cyclic shift 29 bits
            IF  MM 2 -  -  THEN
    LOOP  DROP               ( seed)
    1 X CELL+ +!                  \  make x[1] (and only x[1]) odd
    TT 1-  over MM 1- AND    ( seed t ss)
    BEGIN  over WHILE
        1 KK 1- DO                \  "square"
            X I TH @  X I 2* TH !
            0 X I 2* 1- TH !
        -1 +LOOP
        KK  KK 2* 2 -  DO
            X  I KK LL -  -  TH @  X I TH @  Mod-Diff
                X  I KK LL - - TH !
            X  I KK - TH @  X I TH @  Mod-Diff
                X I KK - TH !
        -1 +LOOP
        dup 1 AND IF              \  "multiply by z"
            1 KK DO  X I 1- TH @  X I TH !  -1 +LOOP
            X KK TH @  X !        \  shift the buffer cyclically
            X LL TH @  X KK TH @  Mod-Diff  X LL TH !
        THEN
        dup IF  1 RSHIFT  ELSE  DROP 1-  0  THEN
    REPEAT  2DROP DROP
    LL 0 DO  X I TH @  Ran-X I KK + LL - TH !  LOOP
    KK LL DO  X I TH @  Ran-X I LL - TH  !  LOOP
    10 0 DO  X KK 2* 1- Ran-Array  LOOP  \  warm things up
    Ran-Arr-Started  Ran-Arr-PTR  !PTR ;

\  *************************  Ran-Arr-Cycle  *************************

\  Ran-Arr-Cycle           ( -- urandom )

: Ran-Arr-Cycle            ( -- urandom )
    Ran-Arr-PTR @PTR Ran-Arr-Dummy =  \  the user forgot to initialize
        IF  314159 Ran-Start  THEN
    Ran-Arr-Buf QUALITY Ran-Array
    -1 Ran-Arr-Buf 100 TH !PTR
    Ran-Arr-Buf CELL+  Ran-Arr-PTR  !PTR
    Ran-Arr-Buf @ ;

\  ***************************  Ran-Next  ****************************

\  [Knuth defines Ran-Arr-Next in C as a macro, but this is not
\  appropriate for Forth.]

: Ran-Next                 ( -- 30-bit-random )
    Ran-Arr-PTR @PTR @ dup 0< IF DROP
        Ran-Arr-Cycle
    ELSE
        1 CELLS Ran-Arr-PTR +!
    THEN ;

\  *******************************************************************
\  *     Optional Tests                                              *
\  *******************************************************************

\  Test for the correctness of the update.  (Knuth)

\ MARKER ONCE

CREATE A  2009 CELLS ALLOT

: MAIN                      ( -- )
    310952 Ran-Start
    2009 1+ 0 DO  A 1009 Ran-Array  LOOP
    CR  A @ .  ." should be 995235265 "
    310952 Ran-Start
    1009 1+ 0 DO  A 2009 Ran-Array  LOOP
    CR  A @ .  ." should be 995235265 "
    ;

MAIN ( ONCE)

\  Check distribution of numbers.  (WB)

\ MARKER ONCE

CREATE BINS  10 CELLS ALLOT

: Ran-Unif                 ( +n -- u )
    Ran-Next 2 LSHIFT UM* NIP ;

: SAMPLE                   ( -- )
    12345 Ran-Start
    BINS 10 CELLS 0 FILL
    100000 0 DO
       \  9 Digit Number
       1000000000 Ran-Unif   ( u)
       \  Into 10 Bins
       100000000 /
       CELLS BINS +  1 SWAP +! ( )
    LOOP ;

: HISTOGRAM                ( -- )
    CR
    10 0 DO
       CR  I CELLS BINS + @  ( cnt)
       dup 5 .R SPACE
       200 / 0 ?DO  ." *"  LOOP
    LOOP
    CR ;

SAMPLE HISTOGRAM ( ONCE)
