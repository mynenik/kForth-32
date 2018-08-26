( * DOC COREWARS					   13:31 02/02/87

 Modified to run on iForth 1.0: March 19, 1994
 Modified to run on kForth 1.2.6: Feb 25, 2005
 Your screen should have at least 25 rows and 80 columns, AT-XY must work.
 Removed a range check bug, don't use MOD when the address can be negative ...
 -----------------------------------------------------------------------------

 "As seen in SCIENTIFIC AMERICAN, May 1984"

 This file was compatible with UR/FORTH 1.0X.
 Copyright [C] 1986 Laboratory Microsystems, Inc.

 The COREWARS game was described in the "Computer Recreations"
 department of the May '84 issue of SCIENTIFIC AMERICAN.

 To compile the REDCODE assembler, MARS interpreter, and example programs, 
 enter:

	INCLUDE corewars.frt

 To run the MARS interpreter and start COREWARS, enter

	<name1> <name2> GO

 where <name1> and <name2> are names of REDCODE programs.  For example,

	DWARF GEMINI GO

 pits DWARF versus GEMINI in a COREWARS battle.

 Use  Esc  to end the battle, any other key pauses the war.

 To create your own battle programs, type them into a file like this:

	REDCODE <name>	 ... <instructions> ...	 END-REDCODE

 Be sure that everything - instruction mnemonics, addressing mode symbols, 
 commas, and numbers - is separated by at least one space.

 After you INCLUDE the file containing your program, you can run it.  To be 
 sure you typed it correctly, you can disassemble it by typing

	<name> DECODE

 Note: there are a few differences from the REDCODE language described in the 
 Scientific American article.

 -  JMZ in the article is renamed to JZ
 -  JMG in the article is renamed to JNZ
 -  conditional jump instructions - JZ, JNZ, DJZ - use the FIRST argument as 
    the conditional and the SECOND argument as the jump destination 
    address -- opposite to the article

 The limits for the size of CORE and the number of instructions to be executed
 before MARS declares a "draw" are at line 186. If you change them, you should
 execute  -overlay  and recompile.

 MARS means "Memory Array Redcode Simulator".	

* )

\ ---------- kForth requirements ---------------------------------------------
include ans-words
include strings
include utils
include ansi

CREATE dummy-space 8192 CELLS ALLOT

\ The definitions of HERE,  ",", and "C,"  are NOT equivalent
\   to the corresponding ANS Forth defs. Their use is
\   restricted to the scope of this program only.
\
dummy-space ptr HERE
: C,  ( u|a -- ) HERE  ! HERE 1+ TO HERE ;
: ,   ( u|a -- ) HERE  ! HERE CELL+ TO HERE ;
: aCreate ( <name> -- | like ANS CREATE ) HERE ptr ;
: aAllot ( n -- | advance HERE by n bytes) HERE + TO HERE ;

: ><  ( 16b1 -- 16b2 ) dup 8 lshift swap 8 rshift OR ;  \ byteswap

\ Pseudo-random number generation
variable last-rn
time&date 2drop 2drop drop last-rn !  \ seed the rng

: lcrng ( -- n ) last-rn @ 31415928 * 2171828 + 31415927 mod dup last-rn ! ;

: next_ran ( -- n | random number from 0 to 255 )
	0 8 0 do 1 lshift lcrng 1 and or loop ;

: choose ( n -- n' | arbitrarily choose a number between 0 and n-1)
 	dup next_ran * 255 / swap 1- min ;

\ other kForth specific changes include moving defs around in this code 
\   to avoid conflicts in a single vocabulary.
\ ----------- end of kForth defs -------------------------------------------

\ Port these to your system ------------------------------------------------
\ : ><  ( 16b1 -- 16b2 ) ;  \ byteswap
\ : BINARY	2 BASE ! ;			\ <> --- <>
27 CONSTANT ESC				\ key code for ESCAPE key.
\ 0 VALUE rnd
\
\ : RANDOM	rnd 31421 * 6927 + DUP TO rnd ;	\ ( -- u1 )
\ : CHOOSE	RANDOM UM* NIP ;		\ ( u1 .. u2 )
\
\ Standard utilities -------------------------------------------------------
	
: 3DROP	2DROP DROP ;			        \ <n1> <n2> <n3> --- <>

: SIGNED	DUP 32767 > IF 65536 - THEN ;	\ <16b> --- <n>

: CWMOVE	5 CMOVE ; 			\ <addr1> <addr> --- <>
: CW@		COUNT >< >R C@  R> OR  SIGNED ;	\ <addr> --- <n>
: CW!		>R  DUP >< R@ C!  R> 1+ C! ;	\ <n> <addr> --- <>

: CW,		DUP  8 RSHIFT C,  C, ;		\ <n> --- <> Big endian 16 bit
: CW+!		DUP >R CW@ +  R> CW! ;		\ <n> <addr> --- <>
: CW.R		SIGNED 0 .R ;


\ The COREWARS code

\ VOCABULARY RED  ALSO RED DEFINITIONS

0 VALUE #exops			\ # of expected operands
0 VALUE #ops			\ # of operands found so far
0 VALUE #inst			\ # of opcodes in program
0 VALUE amode			\ addressing mode for operand
0 VALUE opcode			\ opcode for instruction
0 ptr   ofa			\ opcode field addr
0 ptr   '#inst			\ holds address of instruction count

: ?#OPS 			\ <> --- <>
   #exops 1 = IF EXIT THEN	\ exit if #operands OK
   CR ." wrong number of operands for "
   opcode 15 AND
   CASE	0 OF ." DAT" ENDOF	1 OF ." MOV" ENDOF
	2 OF ." ADD" ENDOF	3 OF ." SUB" ENDOF
	4 OF ." JMP" ENDOF	5 OF ." JZ"  ENDOF
	6 OF ." JNZ" ENDOF	7 OF ." DJZ" ENDOF
	8 OF ." CMP" ENDOF	ABORT" huh"
   ENDCASE 
   ( we're in RED) ABORT ;


: RESET 0 TO #exops
	0 TO #ops
	0 TO opcode
	1 TO amode ;

: !opcode 				\ <opcode> --- <>
   opcode ofa C!			\ compile opcode
   1 TO amode ;				\ relative addressing mode

: !PREVOP ( operand --- )		\ store previous operand
   #inst 0= IF EXIT THEN		\ exit if no instructions
   ?#OPS				\ verify that one operand remains
   CW,					\ compile operand
   amode 4 LSHIFT			\ shift to bits 4-5
   opcode OR TO opcode                  \ OR into opcode byte
   !opcode				\ compile opcode
   RESET ;				\ reset all semaphores

: OPSET 				\ <opcode> <#exops> --- <>
   2>R !PREVOP 2R>			\ store previous operand
   TO #exops                            \ store # of expected operands
   TO opcode                            \ store this instruction's opcode
   HERE TO ofa                          \ save address for compilation
   1 aALLOT				\ skip op field byte for now
   #inst 1+ TO #inst                    \ increment # of instructions
   2 #exops - 0 ?DO  -1 CW,  LOOP ;	\ dummy once for 1 op, twice for none



\ ALSO FORTH DEFINITIONS

: REDCODE
   RESET  0 TO #inst                    \ zero everything
   aCREATE
   HERE TO '#inst 
   0 ,	                                \ allot cell for # inst
   ( ALSO RED ) ; 


: END-REDCODE
   !PREVOP				\ finish last instruction
    #inst				\ get # of instructions ..
   '#inst !  				\ .. and compile it
   ( PREVIOUS ) ;	 



2000 CONSTANT #insts			\ max # of insts in game
1000 CONSTANT #CELLS			\ size of CORE

CREATE CORE  #CELLS 5 * ALLOT   

VARIABLE IP1				\ instruction ptrs
VARIABLE IP2
VARIABLE IPADDR				\ addr of current instr ptr

0 VALUE result				\ result semaphore
0 VALUE inst				\ instruction opcode

0 VALUE op1				\ operands 
0 VALUE op2

0 VALUE amode1				\ addressing modes
0 VALUE amode2


\ Valid addressing modes for each REDCODE instruction are
\ tabulated in VAMTABLE:  #=immediate, R=relative, @=indirect.
\ Note that "##" is not a valid mode ...


BINARY
( DAT )		   10110110
( MOV )		   11011011
( ADD )		   11011011
( SUB )		   11011011
( JMP )		   11011011
( JZ  )		   11011011
( JNZ )		   11011011
( DJZ )		   00011011
( CMP )		   11111111
DECIMAL
9 table VAMTABLE ( ##RRR@@@ <-- operand 1 )
		 ( R@#R@#R@ <-- operand 2 )

: ?VAM ( inst mode1 mode2 --- flag )	\ valid addressing mode?
   2DUP OR 0= IF 3DROP FALSE EXIT THEN	\ false if both immediate
   SWAP 3 * +  256 SWAP RSHIFT		\ bit mask
   SWAP CELLS VAMTABLE + @ AND 0<> ;	\ get result from table

: PARSE-RED ( addr --- )
   DUP C@  DUP 15 AND TO inst           \ instruction
	   DUP 6 RSHIFT TO amode1       \ addressing modes
	   4 RSHIFT 3 AND TO amode2
   DUP 1+ CW@ TO op1 3 + CW@ TO op2 ;	\ operands

: CELL#>ADDR 				\ <cell#> --- <addr> 
\	#CELLS MOD			\ not when cell# is negative ...
	0 #CELLS UM/MOD DROP
	5 * CORE + ;

: ADDR>CELL#	CORE - 5 / ;		\ <addr> --- <cell#> 

: .INST 				\ <opcode> --- <>
   CASE 0 OF ." DAT" ENDOF   4 OF ." JMP" ENDOF
	1 OF ." MOV" ENDOF   5 OF ." JZ"  ENDOF
	2 OF ." ADD" ENDOF   6 OF ." JNZ" ENDOF
	3 OF ." SUB" ENDOF   7 OF ." DJZ" ENDOF
			     8 OF ." CMP" ENDOF
   ENDCASE  SPACE ;

: .AMODE 					\ <amode> --- <>
   ?DUP 0= IF		[CHAR] # EMIT
	   ELSE 2 = IF  [CHAR] @ EMIT  THEN
	   THEN ;

: DISASM 					\ do PARSE-RED first
   inst .INST
   inst DUP 0= SWAP 4 = OR 0=			\ two operands?
   IF amode1 .AMODE				\ yes, so print ...
      op1 CW.R  ." , " THEN			\ ... the first one
   amode2 .AMODE				\ print 2nd operand
   op2 CW.R ;

: FLAG						\ <addr> --- <>
   IPADDR @ IP1 = IF [CHAR] 1 ELSE [CHAR] 2 THEN
   SWAP ADDR>CELL# 80 /MOD 8 + AT-XY EMIT ;

: SELECT-IPADDR 				\ <prog#> --- <>
   1 = IF IP1 ELSE IP2 THEN  IPADDR ! ;

: IP 	IPADDR a@ ;				\ <> --- <addr>

: IMM-ADDR ( operand --- addr )			\ creates pseudo-DAT ...
   PAD 3 ERASE	PAD 3 + CW!  PAD ;		\ .. with bad addr mode

: REL-ADDR ( operand --- addr )			\ relative address
   IP @ + CELL#>ADDR ;

: IND-ADDR ( operand --- addr )			\ indirect address
   IP @ + DUP CELL#>ADDR  3 + CW@  +  CELL#>ADDR ;

: OP>ADDR ( operand addr_mode --- addr )
   CASE 0 OF IMM-ADDR ENDOF
	1 OF REL-ADDR ENDOF
	2 OF IND-ADDR ENDOF
	     CR . 1 ABORT" illegal addressing mode" 
   ENDCASE ;

: @OP1 	( --- value )				\ fetch actual value of op1
   op1 amode1  OP>ADDR  3 + CW@ ;

: +IP ( --- flag )				\ increment IP and leave flag
   IP @ 1+ #CELLS MOD IP !  TRUE ;

: DAT ( --- flag )  +IP ;			\ does nothing at run-time

: MOV
   op1 amode1 OP>ADDR				\ addr of source data
   op2 amode2 OP>ADDR  DUP FLAG  CWMOVE		\ copy to dest location
   +IP ;					\ leave "true" flag on stack

: ADD ( --- flag )
   @OP1	 op2 amode2 OP>ADDR  DUP FLAG
   3 + CW+!  +IP ;

: SUB ( --- flag )
   @OP1	 NEGATE					\ number to subtract
   op2 amode2 OP>ADDR  DUP FLAG 
   3 + CW+!  +IP ;				\ store in dest location

: JMP ( --- flag )
   op2 amode2 OP>ADDR  ADDR>CELL#		\ dest addr
   IP !	 TRUE ;					\ update IP

: JZ ( --- flag )
   @OP1 0= IF	op2 amode2 OP>ADDR		\ jump to ..
		ADDR>CELL#  IP ! TRUE		\ .. new IP
	   ELSE +IP THEN ;

: JNZ ( --- flag )
   @OP1 0<> IF	 op2 amode2 OP>ADDR		\ jump to ..
		 ADDR>CELL#  IP ! TRUE		\ .. new IP
	    ELSE +IP THEN ;

: DJZ ( --- flag )
   op1 amode1 OP>ADDR 3 +			\ 1st location
   DUP CW@ 1-	DUP ROT CW!			\ decrement
   0= IF   op2 amode2 OP>ADDR			\ jump to ..
	   ADDR>CELL#  IP ! TRUE		\ .. new IP
      ELSE +IP THEN ;

: CMP ( --- flag )
   @OP1	 op2 amode2 OP>ADDR 3 + CW@
   <> IF 1 IP +! THEN				\ if not equal, skip next inst
   +IP ;


' DAT  ' MOV  ' ADD  
' SUB  ' JMP  ' JZ   
' JNZ  ' DJZ  ' CMP 
9 table OPTABLE					\ table of cfa's


: DO-RED ( --- )
	inst CELLS OPTABLE + a@ EXECUTE ;


: INIT-DISPLAY ( addr1 addr2 --- )
  PAGE ." COREWARS for ANS-Forth  (c) 1986 by Laboratory Microsystems"
    CR ." Modified 1994 by MHX for iForth, 2005 by KM for kForth"
    CR ." Size of CORE: " #CELLS . ." locations"
    CR ." Maximum number of instructions to be executed: " #insts .
    10 5 AT-XY ." p1 loaded at " IP1 @ .
    45 5 AT-XY ." p2 loaded at " IP2 @ . 
    #CELLS 0 DO I 80 /MOD 8 + AT-XY [CHAR] - EMIT  LOOP ;


: SHOW-COUNT ( n --- )
   4 .R ;


: RED-EXEC ( prog# --- flag )		\ execute redcode instruction 
   DUP 1- 35 * 10 +  24 AT-XY  		\ select column on screen
   SELECT-IPADDR			\ IP address
   IP @ SPACE 4 .R ." : "		\ show IP
   IP @ CELL#>ADDR		 	\ addr of executable redcode 
   PARSE-RED			     	\ parse this instruction
   DISASM  8 SPACES		   	\ show current instruction
   inst amode1 amode2 ?VAM		\ valid addr mode?
   0= IF 0 EXIT THEN		 	\ exit if error was detected
   DO-RED ;		    		\ execute and leave flag on stack


: COPY-REDCODE ( redcode-addr cell# --- )
   SWAP DUP @ 5 * SWAP CELL+	      	\ #bytes and start addr
   ROT CELL#>ADDR ROT CMOVE ;		\ dest addr ... move

: SET-RESULT ( n --- ) TO result ;

: LOAD-PROGRAMS ( addr1 addr2 --- )
   CORE #CELLS 5 * ERASE
   DUP @ >R					\ length of program2 
   #CELLS R@ - CHOOSE	DUP IP2 ! COPY-REDCODE	\ copy prog2
   DUP @					\ length of program1 
   BEGIN #CELLS OVER - CHOOSE  DUP IP1 !      	\ tentative IP1
	 IP2 @ R@ + 1- OVER <  >R    		\ start1>start2+len2-1 ?
	 2DUP + 1- IP2 @ <	    		\ start1+len1-1<start2 ?
	 R> OR 0=		 		\ if yes, overlap, so repeat
   WHILE DROP
   REPEAT
   R> 3DROP		      			\ get rid of start1, len1, len2
   IP1 @ COPY-REDCODE ;			      	\ copy program1

: SHOW-RESULT ( --- )
   0 24 AT-XY 79 SPACES
   0 23 AT-XY ." Result:  "  result 
   CASE -1 OF ." *** COREWARS stopped ***" ENDOF
	 0 OF ." Draw after " #insts . ." instructions" ENDOF
	 1 OF ." program #1 wins!" ENDOF
	 2 OF ." program #2 wins!" ENDOF
   ENDCASE ;

\ ALSO FORTH DEFINITIONS

: DECODE ( addr --- )			\ disassemble a REDCODE program
   DEPTH 0= ABORT" Type:  <name> DECODE"
   DUP CELL+ SWAP @ 
	0 ?DO
		CR  I 4 .R   2 SPACES
		DUP I 5 * +
		PARSE-RED DISASM
	 LOOP
	DROP CR ;


: GO ( addr1 addr2 --- )     		\ addr's are of REDCODE programs
   DEPTH 2 < ABORT" Specify REDCODE program names!"
   LOAD-PROGRAMS INIT-DISPLAY
   0 SET-RESULT			      	\ init result variable
   #insts 0 DO
	    0 24 AT-XY I SHOW-COUNT
	    1 RED-EXEC 0=  IF 2 SET-RESULT LEAVE THEN	\ exec prog1
	    2 RED-EXEC 0=  IF 1 SET-RESULT LEAVE THEN	\ exec prog2
	    KEY? IF KEY ESC = IF -1 SET-RESULT LEAVE
			      ELSE KEY DROP THEN THEN	\ ?exit
          LOOP
   SHOW-RESULT ;

\ ONLY FORTH DEFINITIONS

: .HELP	CR ." *** COREWARS ***" CR
	CR ." Two programs containing self-modifying code battle each other"
	CR ." in a confined space (CORE, managed by MARS)."
	CR ." The battle ends when a program is forced to execute an illegal"
	CR ." opcode."
	CR
	CR ." To run the MARS interpreter and start COREWARS, enter"
	CR
	CR ." <name1> <name2> GO"
	CR
	CR ." where <name1> and <name2> are names of REDCODE programs.  For"
	CR ." example,"
	CR
	CR ." DWARF GEMINI GO"
	CR
	CR ." pits DWARF versus GEMINI in a COREWARS battle."
	CR
	CR ." Use  Esc  to end the battle, any other key pauses the war." 
	CR ." Use  <name> DECODE  to see machine code" ;


\ ------------------------------------------------------------------------------


: DAT 	0 1 OPSET ;
: MOV 	1 2 OPSET ;
: ADD 	2 2 OPSET ;
: SUB 	3 2 OPSET ;
: JMP 	4 1 OPSET ;
: JZ  	5 2 OPSET ;
: JNZ 	6 2 OPSET ;
: DJZ 	7 2 OPSET ;
: CMP 	8 2 OPSET ;

: , 					\ <operand1> --- <>
   CW,					\ compile operand 1
   amode 6 LSHIFT			\ shift to bits 6-7
   opcode OR TO opcode
\ OR into opcode byte
   1 TO amode
\ assume relative addressing
   #exops 1- TO #exops ;
: #   	0 TO amode ; 			\ immediate mode
: @   	2 TO amode ; 			\ indirect mode

PAGE CR .HELP

\ Format: instruction - source operand - destination operand
\ The instruction pointer is incremented _after_ execution (fetch exec incr).
\ All addresses are relative to the instruction pointer.
\ DAT is a variable declaration.

REDCODE DWARF ( --- addr )
	DAT 0
	ADD # 4 , -1
	MOV # 0 , @ -2
	JMP -2
END-REDCODE


REDCODE IMP  ( --- addr )
	MOV 0 , 1
END-REDCODE


REDCODE NOWHERE		
	JMP 0
END-REDCODE


REDCODE GEMINI ( --- addr )
	DAT 0
	DAT 99
	MOV @ -2 , @ -1
	CMP -3 , # 9
	JMP 4
	ADD # 1 , -5
	ADD # 1 , -5
	JMP -5
	MOV # 99 , 93
	JMP 93
END-REDCODE


REDCODE BIGFOOT ( --- addr )	\ copies itself 229 cells ahead 
	DAT 8
	DAT 236
	MOV @ -2 , @ -1
	DJZ -3 , 3
	SUB # 1 , -3
	JMP -3
	MOV # 8 , 223
	MOV # 236 , 223
	JMP 223
END-REDCODE


REDCODE MORTAR ( --- addr )	\ like DWARF, but uses a ...
	MOV # 0 , @ 7		\ .. Fibonacci series
	MOV 5 , 4
	MOV 5 , 4
	ADD 2 , 4
	JMP -4
	DAT 1
	DAT 1
	DAT 0
END-REDCODE

				\ End of File 
