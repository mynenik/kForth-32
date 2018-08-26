( *
  * LANGUAGE    : ANS Forth 
  * PROJECT     : Forth Environments
  * DESCRIPTION : famous algorithm, the 8 Queens problem
  * CATEGORY    : Example 
  * AUTHOR      : Erwin Dondorp, August 19, 1991
  * LAST CHANGE : March 6, 1993, Marcel Hendrix, Ansification 
  * LAST CHANGE : October 13, 1991, Marcel Hendrix 
  * )

\ == kForth requires ==
include ans-words
include strings
include ansi
\ =====================

\        MARKER -queens 

( *
  8 Queens problem.
  After an implementation in Fys-Forth by Rieks Joosten c.s.
  This algorithm is completely I/O-bound.
 * )

20 CONSTANT maxq

10 VALUE #q  	\ number of queens (20 max!)

: CARRAY	CREATE	CHARS ALLOT
		DOES>	SWAP CHARS + ;

maxq 2* CARRAY AA
maxq 2* CARRAY BB
maxq 2* CARRAY CC
maxq 2* CARRAY XX

0 VALUE  #solutions

: AT    1+ SWAP 
        1- SWAP AT-XY ;

: CALC.SOLUTIONS #q 0
   DO I 2DUP 2DUP - #q 1- + CC C@ ROT ROT + BB C@ AND SWAP AA C@ AND
      IF I OVER XX C! I 2DUP + 0 SWAP BB C! 2DUP - #q 1- + 0 SWAP CC C!
            0 SWAP AA C! DUP #q 1- <
         IF DUP 1+ RECURSE
         ELSE #solutions 1+ TO #solutions 0 0 AT-XY ." Solution: " #solutions . 
            #q 0 DO CR #q 0 DO ."  . " LOOP  LOOP 
            #q 0 DO I DUP XX C@ 3 * 1 + SWAP AT ."  X "  LOOP
         THEN I 2DUP + 1 SWAP BB C! 2DUP - #q 1- + 1 SWAP CC C! 1 SWAP AA C!
      THEN
   LOOP DROP ;


: QUEENS 0 TO #solutions #q 0
   DO 1 I AA C! 0 I XX C!
   LOOP #q 2* 1- 0
   DO 1 I BB C! 1 I CC C!
   LOOP PAGE 0 CALC.SOLUTIONS #q #q AT ;


: HELP   CR ." Enter QUEENS to solve the " #q 1 .R ." -queens problem" ;

                HELP 


                              ( * End of Source * )
