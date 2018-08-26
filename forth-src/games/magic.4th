( *
  * LANGUAGE    : ANS Forth 
  * PROJECT     : Forth Environments
  * DESCRIPTION : Magic squares demo
  * CATEGORY    : Example 
  * AUTHOR      : Erwin Dondorp, August 19, 1991
  * LAST CHANGE : March 6, 1993, Marcel Hendrix, Ansification
  * LAST CHANGE : October 10, 1991, Marcel Hendrix 
  * LAST CHANGE : August 24, 2001, Krishna Myneni, core Ansification
* )

\ -----------------------------------------------------------
: SPACE bl emit ; ( needed for kForth only)
\ -----------------------------------------------------------
\ MARKER -magic 

        DECIMAL


( *
  Magic squares by Erwin Dondorp
  after a widely known algorithm:
  - Start with value one in upper middle cell.
  - next cell is one up and to the right, use circular wrap when passing edges
  - if this cell is occupied, move one cell down
  - if this cell is also occupied, stop
 * )

VARIABLE ORDER            
VARIABLE COL              
VARIABLE ROW              

create ADDR 99 dup * cells allot	\ allocate maximum needed space	

: MAGIC \ <n> --- <>
        ORDER !

        ORDER @ 1 AND 0= ABORT" Value should be odd"

        ORDER @ 99 > ORDER @ 3 < OR ABORT" Value should be between 3 and 99"


        ADDR ORDER @ DUP * CELLS ERASE
        ORDER @ 2/ COL !
        0 ROW !

        ORDER @ DUP * 1+ 1
        DO
                I ROW @ ORDER @ * COL @ + CELLS ADDR + !
                -1 ROW +!
                1  COL +!
                COL @ ORDER @  < INVERT ( >= )
                IF
                	ORDER @ NEGATE COL @ + COL !
                THEN
                ROW @ 0<
                IF
                        ORDER @ ROW @ + ROW !
                THEN
                ROW @ ORDER @ * COL @ + CELLS ADDR + @
                IF
                        2 ROW +!
                        -1 COL +!
                        ROW @ ORDER @ MOD ROW !
                        COL @ ORDER @ + ORDER @ MOD COL !
                THEN
        LOOP
        CR ." Magic square "  ORDER @ DUP 1 .R [CHAR] x EMIT . CR
        ORDER @ 0
        DO 
                ORDER @ 0 CR
                DO 
                        ADDR J CELLS  ORDER @ * + I CELLS + @
                        ORDER @ DUP * S>D <# #S #> NIP .R SPACE
                LOOP
        LOOP 
        CR CR ." Sum = "
        ORDER @ DUP DUP * *  ORDER @ + 2/ .
;


: HELP  CR
        ." <n> MAGIC     for a magic square n*n" CR 
        ." <n> must be odd, >= 3, <= 99" CR
        ." <n> > 19 will be too wide for the screen" ;


        HELP CR

