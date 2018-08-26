( * 
  * LANGUAGE    : ANS Forth
  * PROJECT     : Forth Environments
  * DESCRIPTION : Son-of Terry Winograd's SHRDLU
  * CATEGORY    : Example AI program
  * AUTHOR      : Marcel Hendrix 
  * LAST CHANGE : October 15, 1993, Marcel Hendrix; Ansification 
  * LAST CHANGE : May 1, 1993, Marcel Hendrix 
  * LAST CHANGE : June 5, 2002, Krishna Myneni; adapted for kForth,
		    also can run under other ANS Forths [PFE, gforth,
	            etc.] --- see below.
  * )

.( --- Blockworld     Version 1.00 ---) CR
.( A simple program that ``knows'' about colored blocks placed in its ) CR
.( two dimensional world. It can tell what its world looks like, it can ) CR
.( locate any of the blocks by color, and it can manipulate things. ) CR
.( Put block1 on top of block2, even if both blocks are obscured by other ) CR 
.( blocks. ) CR


\ ----- ANS Forth compatibility section -------
(
: ?allot HERE SWAP ALLOT ;
)
\ ---------------------------------------------

\ ------------- kForth defs -------------------
\ comment this section out if not using kForth

: CHARS ;
: WITHIN  \ n m1 m2 -- flag | is m1 <= n < m2 
	over - >r - r> u< ;

\ ------------- end of kForth defs ------------

\ Pseudo-random number generation
variable last-rn
time&date 2drop 2drop drop last-rn !  \ seed the rng

: lcrng ( -- n ) last-rn @ 31415928 * 2171828 + 31415927 mod dup last-rn ! ;

: next_ran ( -- n | random number from 0 to 255 )
	0 8 0 do 1 lshift lcrng 1 and or loop ;

: choose ( n -- n' | arbitrarily choose a number between 0 and n-1)
 	dup next_ran * 255 / swap 1- min ;

\ Two-dimensional array

: 2D-ARRAY	CREATE	OVER * CELL+ ?ALLOT !	\ <xm> <ym> --- <>
		DOES>	DUP CELL+ >R 		\ <x> <y> --- <addr>
			@ * + CHARS R> + ;

 6 CONSTANT #cols  			       
 5 CONSTANT #rows			       
#cols #rows 2D-ARRAY world	       

char R CONSTANT 'R'
char Y CONSTANT 'Y'
char B CONSTANT 'B'
char G CONSTANT 'G'
char _ CONSTANT '_'


: INITIALIZE	#cols 0 DO 
		           #rows 0 DO '_' J I  world C!
			         LOOP
		      LOOP 
		0 1 2 3 4 5     
		6 0  DO 6 CHOOSE ROLL LOOP 		\ shuffle
		'R' ( red)    SWAP 0 world C!
		'Y' ( yellow) SWAP 0 world C!
		'B' ( blue)   SWAP 0 world C!
		'G' ( green)  SWAP 0 world C! 
		2DROP ;        

		INITIALIZE

: .WORLD	CR
		0 #rows 1- DO  CR 8 SPACES  
			       #cols 0 DO I J world C@ EMIT LOOP
		     -1 +LOOP 
		CR 1000 MS ;


: .COLOR	CASE 					\ <char> --- <>
		      'R' OF ."  the red block"    ENDOF
		      'B' OF ."  the blue block"   ENDOF
		      'Y' OF ."  the yellow block" ENDOF
		      'G' OF ."  the green block"  ENDOF
		      '_' OF ."  a space"          ENDOF
		  ENDCASE ;        



: TELL-COLUMN		\ <col#> --- <>
		0 #rows 1- DO
			      DUP I world C@ 
			      DUP '_' <> IF     .COLOR 
					        I IF ."  on top of"
					        THEN
				       ELSE  I 0= IF .COLOR
						ELSE DROP
				                THEN
				       THEN
		     -1 +LOOP DROP ;        

: TELL-ABOUT-WORLD	CR ." Starting from the left, I see: " CR
		#cols 0 DO  
		           I TELL-COLUMN
		           I #cols 1-  <> IF ." ," CR ."  flanked by" 
			        	ELSE ." ." 
				        THEN
		      LOOP CR ;

: .SINGLE					\ <col> <row> --- <>
		OVER  0 #cols WITHIN
		OVER  0 #rows WITHIN 
		AND IF world C@ .COLOR 
		  ELSE 2DROP ."  nothing"  
		  THEN ;        

: .ALL						\ <col> <row> --- <>
		CR ." That block is at column " OVER 1 .R 
		."  and row " DUP 1 .R ." ." CR
		2DUP >R 1- R> .SINGLE ."  is to the left,"  CR
		2DUP >R 1+ R> .SINGLE ."  is to the right," CR
		2DUP 1-       .SINGLE ."  is beneath it,"   CR   
		1+            .SINGLE ."  is on top of it." CR ;        

VARIABLE color1	       
VARIABLE color2	       
VARIABLE col#1	       		\ the column where color1 is
VARIABLE col#2	        	\ the column where color2 is
VARIABLE row#1	       		\ the row where color1 is
VARIABLE row#2	        	\ the row where color2 is

: BCOLOR	CREATE	1 CELLS ?ALLOT !		\ <char> --- <>
		DOES>	@ color1 @ 0= IF color1 ! 
				  ELSE color2 ! 
				  THEN ;

: LOCATE?					\ <color> --- <c> <r> <bool>
		-1 -1 ROT	
		#cols 0 DO
			  #rows 0 DO  J I world C@  
				      over = IF -ROT 2DROP J I ROT LEAVE 
					    THEN
				LOOP
		      LOOP 
		DROP 2DUP -1 -1 D= IF 2DROP 0 0 FALSE 
				   ELSE TRUE 
			           THEN ;

: WHERE-IS	color1 @ LOCATE?			\ <> --- <>
		0= IF  2DROP CR ." That block isn't there." 
		       EXIT
		 THEN .ALL ;

: SHUFFLE-BLOCKS 	INITIALIZE .WORLD  CR CR ." I enjoyed that." ;

\ Find a free column (not corresponding to color1 or color2).

: HOLE		BEGIN #cols CHOOSE 		\ <> --- <column>
		      DUP  col#1 @ = 
		      OVER col#2 @ = OR 
		WHILE DROP 
		REPEAT ;        


\ Always possible as #rows is larger than the number of blocks.

: STORE						\ <color> <column> --- <>
		#rows 0 DO  DUP I world C@ '_' 
		  = IF 2DUP I world C! LEAVE  THEN
		LOOP 2DROP ;        

\ Remove blocks from off color. These blocks are put there where they do not 
\ obscure EITHER colors. After a STORE the location of one of the colors may
\ have changed, so FIND'M is necessary (color1 may obscure color2, so color1
\ is STOREd elsewhere).


: FIND'M	color1 @ LOCATE? -ROT row#1 ! col#1 !	\ <> --- <bool>
		color2 @ LOCATE? -ROT row#2 ! col#2 !  
		AND ;        

variable column
variable color

: (UNOBSCURE)					\ <color> <column> --- <>
		column ! color !
		0 #rows 1- DO 
 			      column @ I world C@
			      DUP color @ = IF DROP LEAVE THEN
			      DUP '_'     = IF DROP 
				        ELSE HOLE 
					     STORE  '_' column @ I world C!
					     FIND'M DROP .WORLD
				        THEN
		     -1 +LOOP ;        

: UNOBSCURE	color1 @ col#1 @ (UNOBSCURE)
		color2 @ col#2 @ (UNOBSCURE) ;        

: TOP		color1 @ col#2 @ row#2 @ 1+ world C! 
		 '_'     col#1 @ row#1 @    world C! .WORLD ;        

: PUT-BLOCK 	color1 @ color2 @ = IF ." That's easy." EXIT THEN
		FIND'M IF UNOBSCURE TOP
		ELSE ." One of the colors doesn't exist." THEN ;

: UNREF_BLOCKS	0 color1 ! 0 color2 ! ;	\ unreference the blocks

: EVAL-REST
		BEGIN
		  BL WORD DUP C@
		WHILE
		  FIND IF DUP ['] UNREF_BLOCKS > IF EXECUTE ELSE DROP THEN
		  ELSE DROP THEN
		REPEAT 
		DROP ;


		'R' BCOLOR Red
		'B' BCOLOR Blue
		'G' BCOLOR Green
		'Y' BCOLOR Yellow

: SHOW		EVAL-REST .WORLD ;
: WHERE		EVAL-REST WHERE-IS UNREF_BLOCKS ;
: TELL		EVAL-REST TELL-ABOUT-WORLD ;
: SHUFFLE	EVAL-REST SHUFFLE-BLOCKS ;
: PUT		EVAL-REST PUT-BLOCK UNREF_BLOCKS ;
: HELP		EVAL-REST CR ." Commands: SHOW WHERE TELL SHUFFLE PUT HELP" ;


: .ABOUT
		CR ." A possible conversation might go as follows:" CR
		CR ." TELL me what you see."
		CR ." WHERE is the BLUE block?"
		CR ." SHUFFLE your blocks around a bit."
		CR ." SHOW it to me."
		CR ." HELP me please, I lost my bearings."
		CR ." PUT the RED block over the GREEN one."
		;

                .ABOUT SHOW



