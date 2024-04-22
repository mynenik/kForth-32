\ asm-x86.4th -- ANS Forth assembler (postfix)
\
\ 32/16-bit Assembler for x86 processors
\
\ -------- Original Notes ------------------------------------------------
\
\ Designed to compile the Forth-OS from any ANS Forth compiler.
\ by Thomas Novelli, 1999-2000
\
\ Based on the 16-bit assembler from Pygmy Forth, by Frank Sergeant.
\ http://pygmy.utoh.org
\
\ Floating point instructions adapted from gforth's 386/asm.fs
\   by Bernd Paysan.
\
\ asm-x86 is released under the MIT/BSD license, in accordance
\   with the preference of its original author, Frank Sergeant.
\  
\
\   
\ Special notations:
\   ta - Target address
\
\ TBD:
\   EBP@ and ESP@ can't be done w/ mod r/m alone; use S-I-B.
\     Workaround: use #@ EBP+ instead of EBP@  (same for ESP)
\
\ Low-priority items:
\   INCBIN
\   MOV CRx
\   2,3-operand IMUL
\   Do more error checking? (wrong number/type of operands, etc)
\   Support for running under 16-bit Forths (use double-cells..)
\
\ Output Options:
\
\ 1. Assemble to blocks (or blockfiles)
\ 2. Assemble to ALLOCATEd memory (and save to file)
\ 3. Assemble to heap (HERE) or "code space" with C,
\    Prevents some useful things, like macros & named labels
\
\ -------- end original notes --------------------------------------------
\
\ Revisions:
\   2001-10-23  modified for kForth, Krishna Myneni
\   2004-10-19  make OCTAL nondeferred word  KM
\   2004-10-20  KM began floating pt instruction implementation;
\               revisions to kForth interface: 
\                 -- fixed END-CODE to update stack ptr
\                 -- moved compilation of "RET," to inside of END-CODE
\   2004-10-21  changed stack ptr to EBX for CODE words, added fp words  KM
\   2004-10-22  fixed displacement addressing for fp words KM
\   2004-10-26  finished first cut of fp implementation  KM
\   2004-10-27  changed ASM-RESET to set default flags for WORD/DWORD 
\                 based on MODE; added MACRO: and END-MACRO; reduced
\                 CODE overhead slightly  KM
\   2006-02-11  removed operations in SIZED-CODE which were redundant or useless;
\                 this should reduce CODE overhead significantly  KM 
\   2006-03-02  changed SIZED-CODE so that CODE words generate inline calls and stack fixup,
\                 which increases efficiency considerably  KM 
\   2006-03-11  fixed problems with JMP, -- apparently coded on assumption of
\		  16-bit mode causing relative jumps to mis-assemble for 32-bit  KM
\   2006-03-13  modified BEGIN, to return address rather than offset, so its use
\                 would be consistent with AGAIN, and REPEAT, ; 
\                 added DO, with behavior of old BEGIN, for use with LOOP, ;
\                 commented out UNTIL, and inserted corresponding code in LOOPx,
\                 since UNTIL, should correspond to BEGIN, ;  KM
\  2006-03-14  fixed a problem with order of computation in ASM-TO ;
\                 fixed JMP to allow both short and long relative jumps for 32-bit mode ;
\                 added CALL-CODE to allow CODE words to call other CODE words ;
\                 added mixed integer/fp arithmetic and memory words (FIxx) KM 
\  2007-01-07  modified "<reg>" and "reg": a) in "reg" the E and W flag bits are cleared
\                 prior to calling "<reg>" so that byte and word register operands will
\                 assemble properly; b) moved code to set the variable SRCSIZ which
\                 is needed for the MOVSX, and MOVSZ, instructions from "<reg>" to
\                 "reg" to avoid side effects from change a)  KM
\  2009-05-24  added FSTPT, and FLDT, for storing and loading full width (10 byte) values
\                 between the FPU register and memory  KM
\  2009-09-26  removed definition of WITHIN  KM
\  2009-10-05  re-enable use of wordlists; updated CODE, END-CODE, MACRO, and END-MACRO  KM
\  2020-09-15  requires modules.4th, syscalls.4th, and mc.4th
\
\ Version Specific Notes:
\ ----------------------
\
\ 1. Output Options 1 and 3 are not relevant for the kForth version.
\
\ 2. This version may be ported to other ANS-Forth systems which
\    provide a way to call machine code at a given address, and
\    provide MMAP and MPROTECT or equivalent system words.
\
\ 3. Currently, any values placed on top of the stack from a
\    CODE word get clobbered on return to Forth, due to
\    specific implementation of CODE. However, values may be 
\    dropped, or the number of stack items can remain unchanged 
\    in which case the values may be changed. See asm-x86-test.4th
\    for examples.

ALSO ASSEMBLER DEFINITIONS

BASE @
HEX    
: OCTAL 8 BASE ! ; nondeferred

variable MODE  ( 0=16-bit 1=32-bit)

: USE16  0 MODE ! ;   
: USE32  1 MODE ! ;
: TCELL ( - n) 2 MODE @ LSHIFT ;  ( Target CELL size, in chars)

variable ORIGIN \ start of code (when loaded on target)
variable -ORG   \ difference
variable ASM0   \ start of code
variable >ASM   \ assembly pointer -- w/rt ASM0 (starts at 0)
variable OUTPUT \ 0=memory, 1=blocks


: $' ( - a  Current address w/rt ASM0)  >ASM @ ;
: $  ( - a  Current address w/rt ORIGIN)  >ASM @  -ORG @ + ;
: ORG ( a -)  DUP ORIGIN !  $' - -ORG ! ;

( Assemble to memory -- ORG = start address, by default)

\ : ASM-TO ( a -- ) DUP ORG  ASM0 !  0 >ASM !  0 OUTPUT ! ;
: ASM-TO ( a -- )   DUP ASM0 !  0 >ASM ! ORG 0 OUTPUT ! ;
: MEM-db! ( n ta -) ASM0 a@ + C! ;

HEX
( Assemble to blocks -- ORG = 0, by default)

: ASM-BLOCK ( start_block -)
  0a LSHIFT ASM0 !  0 ORG  0 >ASM !  1 OUTPUT ! ;

: BLOCK-db! ( n ta -) 2DROP ;
\  ASM0 @ +  400 /MOD BLOCK  + C!  UPDATE ;


\ DB! is the one and only way to output code/data.
\ That way it's easy to "filter" for block output, etc.

: db! ( n ta -)
 	OUTPUT @  0= if MEM-db! else BLOCK-db! then ;

: dw! ( n ta -)
	2DUP db! CHAR+ SWAP 8 RSHIFT SWAP db! ;

: dd! ( n ta -)
	4 0 DO  2DUP db! CHAR+ SWAP 8 RSHIFT SWAP  LOOP  2DROP ;

: dc! ( n ta -)
  	TCELL 0 DO  2DUP db! CHAR+ SWAP 8 RSHIFT SWAP  LOOP  2DROP ;

\ Data definition words (also used for code generation)

: db,  ( c -) >ASM @  TUCK db!  CHAR+ >ASM ! ;
: dw,  ( x -) DUP db, 8 RSHIFT db, ;
: dd,  ( x -) 4 0 DO  DUP db, 8 RSHIFT  LOOP DROP ;
: dc,  ( x -) MODE @ if dd, else dw, then ;

\ Save memory to file

\ : SAVE ( "filename" -)  ( Usage: SAVE filename )
\  BL PARSE ( c-addr u) R/W BIN CREATE-FILE 0<>
\  if DROP ( fid) ." CREATE-FILE error" cr
\  else DUP ASM0 @  $' ( location & size of code)
\    ROT WRITE-FILE  0<> if ." WRITE-FILE error" cr then
\    CLOSE-FILE  0<> if ." CLOSE-FILE error" cr then
\  then  ;

\ For debugging - show assembly buffer:
\ TBD: only works w/ memory right now

\ : SHOW ( -) ASM0 @  $'  DUMP ;



variable DISP   \ displacement
variable SIB    \ -------- ssrrr00I
  \ ss=scale; rrr=index reg; I=index?
variable FLAGS  \ -------E OMIAGSDW
  \ M=r/m; I=imm; A=accumulator (AL/AX/EAX); G=seg;
  \ S=imm size (1=Short, 0=full size)
  \ W=Word or byte; E=dword (Extended reg.)
  \ O=DISP Only; D=direction (1 when r/m field is source)

variable #OPS   \ # of operands
variable #REGS  \ # of register operands
variable SRCSIZ \ size of 1st (source) operand; used for MOVZX,


: F-SET  ( mask -) FLAGS @ OR FLAGS ! ;
: F-CLR  ( mask -) INVERT FLAGS @ AND FLAGS ! ;
: F-GET  ( mask - flags ) FLAGS @ AND ;
: F-FLIP ( mask -) FLAGS @ XOR FLAGS ! ;

\ Set flags

: B-PTR  101 F-CLR ;
: W-PTR  100 F-CLR  1 F-SET ;
: D-PTR  101 F-SET ;


: ASM-RESET  2 FLAGS ! ( D) MODE @ IF D-PTR ELSE W-PTR THEN
             0 DISP !  0 SIB !  0 #REGS !  0 #OPS ! ;

\ Read flags

: BYTE?  ( - f)  1 F-GET 1 XOR ;
: WORD?  ( - f)  1 F-GET ;    \ True for both 16-and 32-bit values
: DWORD? ( - f)  100 F-GET 0<> NEGATE ;
: CELL?  ( - f)  100 F-GET 8 RSHIFT  MODE @  XOR INVERT  1 F-GET AND ;

: SREG?  ( - f)  8 F-GET ;

: D? ( - f)  2 F-GET ;
: S? ( - f)  4 F-GET ;
: M? ( - f) 40 F-GET ;
: O? ( - f) 80 F-GET ;

: IMM? ( -f)  20 F-GET ;
: ACC? ( -f)  10 F-GET ;
: 1REG?  #REGS @ 1 = ;
: 2REGS? ( -f) #REGS @ SREG? OR  DUP 2 =  SWAP 9 =  OR ;
               ( cc=2  OR  cc=1 + sreg )


HEX
( Conditionals )

: IF, ( opcode -- offset ) db,  $' ( origin)  0 db, ( blank) ;

: WHILE, ( a1 opcode -- offset a1) IF, SWAP ;

: THEN, ( offset -- ) $' OVER 1+ - SWAP db! ;

: ELSE, ( offset -- offset') EB ( short jmp) db,
	$' OVER - SWAP db!  $'  0 db, ;

: BEGIN, ( -- a ) ( $') $ ;     \ changed for consistency with AGAIN, and REPEAT,  km2006-03-13

\ : UNTIL, ( a opc -) db,  $'  1+ - db, ;
 
( REPEAT, and AGAIN are defined after JMP, )

: opc ( opcode -) ( - opcode) CREATE 1 allot? C! DOES> C@ ;

73 opc CS,
75 opc 0=,  
79 opc 0<,  
73 opc U<,  
E3 opc CXNZ,
7D opc <,   
7E opc >,   
76 opc U>,  
71 opc OV,

: DO,     ( -- offset )  $' ;
: LOOP,   ( offset -- )  E2 db, $' 1+ - db, ;
: LOOPZ,  ( offset -- )  E1 db, $' 1+ - db, ;
: LOOPNZ, ( offset -- )  E0 db, $' 1+ - db, ;

: FAR-JMP,  ( seg offset -)  EA db,  dc, dw,  ASM-RESET ;

HEX

: <reg> ( a - n)
  1 #OPS +!  
  DUP 8 RSHIFT  ( high byte)
  DUP 1 AND  1 XOR  2 LSHIFT  ( S flag = NOT of bit 1)
  OR F-SET
  FF AND ( low byte)  ;


: r/m ( n -) ( disp - n)  CREATE 1 CELLS allot? !
	DOES> @ <reg> 2 F-CLR ( D) SWAP DISP !  ;

\ high byte = flags, low byte=reg
\  40000=indirect
\ 100000=disp only

OCTAL
40000 r/m [BX+SI]  
40001 r/m [BX+DI]   
40002 r/m [BP+SI]
40003 r/m [BP+DI]  
40004 r/m [SI]      
40005 r/m [DI]
40006 r/m [BP]     
40007 r/m [BX]

: #@ ( disp - n)  140006 MODE @ -
                  <reg> 2 F-CLR ( D) SWAP DISP ! ;


\ Base registers: (r/m)

40000 r/m EAX@  
40001 r/m ECX@  
40002 r/m EDX@  
40003 r/m EBX@
40004 r/m ESP@  
40005 r/m EBP@  
40006 r/m ESI@  
40007 r/m EDI@

\ Index registers: (s-i-b, r/m=100)

HEX
: idx ( n -) ( - n)  CREATE 1 CELLS allot? ! DOES> @
	SIB @ 1 AND if ABORT" Index reg defined twice!"
	else FF AND SIB ! then ;

OCTAL
40001 idx EAX+  
40011 idx ECX+  
40021 idx EDX+  
40031 idx EBX+
40041 idx ESP+  
40051 idx EBP+  
40061 idx ESI+  
40071 idx EDI+

\ Scaling, for the index regs:
: 1x  300 INVERT SIB @ AND SIB ! ;
: 2x  1x  100 SIB @ OR SIB ! ;
: 4x  1x  200 SIB @ OR SIB ! ;
: 8x  1x  300 SIB @ OR SIB ! ;


HEX
: reg ( 000a00ew00rrr000 -) ( - 0000000000rrr000)  CREATE 1 CELLS allot? !
  DOES>
    #OPS @ 1 = if 101 F-GET  SRCSIZ ! then   \ needed for MOVSX, and MOVZX,
    101 F-CLR
    @ <reg> 1 #REGS +!  2 F-FLIP ( D)  ;

OCTAL
\  10000= A (accumulator)
\    400= W (word)
\ 200400= EW (dword)

210400 reg EAX  
200410 reg ECX  
200420 reg EDX  
200430 reg EBX
200440 reg ESP  
200450 reg EBP  
200460 reg ESI  
200470 reg EDI

 10400 reg AX      
   410 reg CX      
   420 reg DX      
   430 reg BX
   440 reg SP      
   450 reg BP      
   460 reg SI      
   470 reg DI

 10000 reg AL       
    10 reg CL       
    20 reg DL       
    30 reg BL
    40 reg AH       
    50 reg CH       
    60 reg DH       
    70 reg BH

: seg ( n -) ( -n)  CREATE 1 CELLS allot? ! DOES> @ <reg> 2 F-SET ( D) ;

4400 seg ES   
4410 seg CS   
4420 seg SS   
4430 seg DS
4440 seg FS   
4450 seg GS

\ Debugging routine: .F (show flags, etc.)
HEX

CREATE F$ 8 allot?
char O over c! 1+
char M over c! 1+
char I over c! 1+
char A over c! 1+
char G over c! 1+
char S over c! 1+
char D over c! 1+
char W swap c!

: 2^  ( n - 2^n)  1 SWAP LSHIFT ;

: .F ( -)
  BASE @ HEX
  DWORD? if [char] E else [char] - then EMIT 20 EMIT
  80  8 0 DO  DUP F-GET  if F$ I + C@  else [char] -  then
             EMIT 1 RSHIFT LOOP DROP
  #REGS @ 3 U.R  ."  regs  "
  1  SIB @ 6 RSHIFT  LSHIFT  1 U.R  ." x  DISP=" DISP @ u.
  BASE !  cr ;

: R>M ( reg - r/m)  3 RSHIFT ;

: SHORT? ( n - f)  -80 80 WITHIN ;

: # ( n1 - n1) 20 OVER SHORT? 04 AND OR F-SET ;
  \ clears all flags except I and (if short) S

: orW  ( --opc---  -  --opc--w )  1 F-GET  OR ;
: orDW ( --opc---  -  --opc-dw )  3 F-GET  OR ;


\ Generate mod r/m byte, and s-i-b byte if needed

: mod, ( md***rrr -)
  SIB @ if DUP F8 AND 4 OR db,  7 AND SIB @ OR db,
  else db,  then ;

\ Generates mod r/m byte, s-i-b byte, displacement

: modDISP, ( 00***r/m -)
  M? if
    O? if ( disp only)
      mod, DISP @ dc,
    else
      SREG? DISP @ OR  OVER 7 AND 6 = OR ( [BP])
      if
         DISP @ TUCK
         SHORT? if 40 OR mod, db,  else 80 OR mod, dc,  then
      else ( zero & not seg) mod, then
    then
  else ( 11***reg) C0 OR db,  then ;

: ,IMM ( n -)
  5 F-GET 4 = if ( S,-W) db,
              else  DWORD? if dd, else dw, then  then ;


\ prefix instructions
OCTAL

: PFX CREATE 1 allot? C! DOES> C@ db, ;

 46 PFX ES:  
 56 PFX CS:  
 66 PFX SS:  
 76 PFX DS:
144 PFX FS:     
145 PFX GS:     ( 386+)
146 PFX OPSIZ:  
147 PFX ADRSIZ: ( 386+)
362 PFX REPNZ   
362 PFX REPNE
363 PFX REPZ    
363 PFX REPE    
363 PFX REP
\ Note: REP* was done differently in Pygmy

( Generate OPSIZ: prefix if necessary )
: (OPSIZ)  BYTE? 0=  CELL? 0=  AND  if OPSIZ: then ;


\ one-byte opcodes with no operands

: M1 ( n -) ( -)  CREATE 1 CELLS allot? ! DOES> @ db, ASM-RESET ;

OCTAL
 47 M1 DAA,      
 57 M1 DAS,     
 67 M1 AAA,      
 77 M1 AAS,
324 M1 AAM,     
325 M1 AAD,
220 M1 NOP,
230 M1 CBW,     
230 M1 CWDE,   
231 M1 CWD,
140 M1 PUSHAD,  
141 M1 POPAD,  
234 M1 PUSHFD,  
235 M1 POPFD,
236 M1 SAHF,    
237 M1 LAHF,
303 M1 RET,   \ what about RET ## form?
313 M1 RETF   \ (We shouldn't need it for Forth)
311 M1 LEAVE,
314 M1 INT3,	
316 M1 INTO,
317 M1 IRET,
327 M1 XLAT,
360 M1 LOCK:
364 M1 HLT,     
233 M1 WAIT,
370 M1 CLC,     
371 M1 STC,    
365 M1 CMC,
372 M1 CLI,     
373 M1 STI,    
374 M1 CLD,     
375 M1 STD,

HEX
( ALU instructions with 2 operands, like ADD )

: M2 ( n -) ( various -)   CREATE 1 CELLS allot? !
  DOES> (OPSIZ)  @ >R  IMM? if
    ACC? if   DROP  R> orW 4 OR db,
         else 1REG? if R>M then  80 orW db,
              R> 38 AND OR modDISP,
         then  ,IMM
  else  2REGS?  if SWAP R>M then
  	R> orDW db, OR modDISP,
  then ASM-RESET  ;

OCTAL
00 M2 ADD,  
10 M2 OR,   
20 M2 ADC,  
30 M2 SBB,
40 M2 AND,  
50 M2 SUB,  
60 M2 XOR,  
70 M2 CMP,


HEX
: MOV, ( r/m/i r/m - )
  (OPSIZ)
  IMM? if
    1REG? if   ( imm,reg) R>M B0 OR  WORD? 3 LSHIFT OR  db,
    else ( imm,r/m) C6 orW db, modDISP,
    then ,IMM
  else ( reg,r/m)
    O? ACC? AND
    if ( disp,acc) 
      2DROP A0  2 F-FLIP  orDW db,  DISP @ dc,
    else
      2REGS? if ( reg,reg) D? if SWAP then  R>M  then
      SREG? if ( sreg,r/m) 1 F-CLR 8C else ( reg,r/m)  88  then
      orDW db,  OR modDISP,
    then
  then  ASM-RESET  ;

\ MOVZX, MOVSX, -- zero extend / sign extend

: MX ( n -) ( r/m reg -)
  CREATE 2 allot? TUCK C! 1+ C! DOES> (OPSIZ)
  SRCSIZ @ 100 AND if ABORT" Attempt to extend a dword" then
  DUP CHAR+ C@ db,  C@ SRCSIZ @ OR db,
  2REGS? if SWAP R>M then  OR modDISP,
  ASM-RESET ;

HEX  
0F B6 MX MOVZX,  
0F BE MX MOVSX,


\ String instructions -- all 1-byte opcodes with W bit

: M3 ( n -) ( reg -)
	CREATE 1 CELLS allot? ! DOES> (OPSIZ) @ orW db, ASM-RESET ;

OCTAL
246 M3 CMPS, 
254 M3 LODS, 
244 M3 MOVS, 
256 M3 SCAS, 
252 M3 STOS,


\ MUL, DIV, etc...    xxxxxxxW  mdNNNr/m

OCTAL

: M4 ( n -) ( -)  CREATE 1 cells allot? !
  DOES> (OPSIZ)  @  366 orW db, SWAP
  1REG? if R>M then OR modDISP,  ASM-RESET ;

20 M4 COM,   
40 M4 MUL,   
60 M4 DIV,
30 M4 NEG,   
50 M4 IMUL,  
70 M4 IDIV,

\ Note: I used NOT for conditionals, so this alias is okay:
\ 20 M4 NOT, ( alias for COM,)

\ LEA, LDS, LES instructions

OCTAL

: M5 ( n -) ( -)       \ TBD: fix if broken; add LFS/LGS/LSS
  CREATE 1 allot? C! DOES> (OPSIZ)  C@  db, OR modDISP, ASM-RESET  ;

215 M5 LEA,  
304 M5 LES,  
305 M5 LDS,

\ rotate & shift instructions
\ Note: To shift by CL, omit first operand

OCTAL
: M6 ( n -) ( n# r/m | r/m - )  CREATE 1 CELLS allot? !
  DOES> (OPSIZ)  @
  320  IMM? if  3 PICK 1 <> 20 AND XOR  else  2 OR  then
  orW db,
  1REG? if SWAP R>M then OR modDISP,
  IMM? if  DUP 1 <> if db, else DROP then  then
  ASM-RESET  ;

00 M6 ROL,  
20 M6 RCL,	
40 M6 SHL,
10 M6 ROR,  
30 M6 RCR,  
50 M6 SHR,  
70 M6 SAR,


\ INC, DEC instructions
OCTAL

: M7 ( opc -) ( reg | r/m - )  CREATE 1 CELLS allot? !
  DOES> (OPSIZ)  @ SWAP  1REG? if ( opc reg) R>M then
  1REG?  WORD? AND  ( full-size register?)
  if ( opc rX)  OR 100 OR db,
  else ( opc mem | opc rH | opc rL )
    376 orW db,  OR modDISP,
  then  ASM-RESET  ;

00 M7 INC,   
10 M7 DEC,


\ PUSH, POP instructions
HEX

: M8 ( n -) ( reg | seg | r/m -)  CREATE 1 CELLS allot? !
  DOES> @  8 ( G) F-GET
  if ( seg opc) OVER 20 AND
    if   ( sreg3) 0F db,  4 RSHIFT 1 AND 1 XOR  80 OR  OR db,
    else ( sreg2)         4 RSHIFT 1 AND 1 XOR   6 OR  OR db,
    then
  else 1REG?
    if ( reg opc) 2/  8 AND  8 XOR  50 OR  SWAP R>M OR db,
    else ( r/m opc) DUP 8 RSHIFT  FF AND  db,  OR modDISP,
    then  then  ASM-RESET  ;

FF30 M8 PUSH,    
8F00 M8 POP,   \ Hex
\ 177460 M8 PUSH,  107400 M8 POP, \ Octal


\ IN, OUT instructions
OCTAL

: M9 ( n -) ( n# r1 | r1 -)  CREATE 1 CELLS allot? !
  DOES> @  (OPSIZ) orW NIP
    IMM? if ( n# opc)  db, ( n#) else ( opc) 10 OR then db,
    ASM-RESET  ;

344 M9 IN,   
346 M9 OUT,

\ XCHG
HEX

: XCHG,  ( reg mem | mem reg | reg1 reg2 -)
  (OPSIZ)
  #REGS @ 2 =  ACC? AND  WORD? AND ( AX and another reg)
  if  ?DUP if NIP then ( r1) R>M  90 OR db,
  else 2REGS? if  R>M  then  OR  86 orW db, modDISP,
  then  ASM-RESET  ;

\ TEST -- sim. to ADD
HEX

: TEST,  ( various -)
  (OPSIZ)
  IMM?
  if ACC? if     DROP  A8 orW ( 4 OR) db,
          else   1REG? if R>M then  F6 orW db,
                 ( OR)  modDISP,
          then  ,IMM
  else  2REGS?  if SWAP R>M then
        84 orW db, OR modDISP,
  then  ASM-RESET  ;



\ INT -- usage: 21 INT,
OCTAL

: INT, ( #n -) 315 db, db, ASM-RESET ;

\ CALL
HEX

: CALL, ( various -)  IMM?	( intra-seg direct)
  if  ( n#)  $ 1+ TCELL + -  ( relative)
    E8 db, dc,   ( usage: 2338 CALL, )
  else   ( intra-seg indirect: address in reg/mem)
    ( mem | reg -)  1REG?  if R>M then
    FF db,  10 OR modDISP, ( usage: 0 [BX] CALL,  or  DX CALL, )
  then  ASM-RESET  ;

\ JMP
HEX

: JMP, ( various -) ( 140) 40  F-GET  ( R or M intra-seg indirect)
  if ( mem | reg -)  1REG?  if R>M then
    FF db,  20 OR modDISP,  \ 0 [BX] JMP,   DX JMP,
                           \ 3759 ) JMP,
  else  ( a) $ 1+ TCELL + -  ( relative)
    DUP SHORT? if TCELL + 1- EB db, db, else E9 db, dc, then
  then  ASM-RESET  ;

: LJMP, ( a -)  E9 db,  $'  TCELL + - dc, ; 
: AGAIN, ( a -)  JMP, ;   
: REPEAT, ( a a -) AGAIN, THEN, ;


\ Some 386/486 instructions...
OCTAL

: CLTS,		17 db, 06 db, ;
: INVD,		17 db, 10 db, ;
: WBINVD,	17 db, 11 db, ;

: LABEL: ( "name" -) ( - a) CREATE $ 1 CELLS allot? ! DOES> a@ ;
: LABEL' ( "name" -) ( - a) CREATE $' 1 CELLS allot? ! DOES> a@ ;

: JMP-FROM ( "name" -) 351 db,  LABEL'  0 dc, ;
: JMP-TO ( a -)
  $'  OVER -  TCELL - ( displacement)
  SWAP dc! ;

HEX

: 0FILL ( # -  Pad out target file w/ 0's)
  ?DUP if  0 DO 0 db, LOOP  then ;

\ Pad w/ NOPs
: ALIGN, ( u -)  $  OVER MOD
  DUP if - 0 DO  NOP,  LOOP
  else 2DROP then ;

\ Pad w/ zeroes
: 0ALIGN, ( u -)  $  OVER MOD
  DUP if - 0 DO  NOP,  LOOP
  else 2DROP then ;

\ DPUSH/DPOP pseudo-instructions
\ Use this like: 32 # DPUSH,  or  EDX DPOP,

: DPUSH, ( r/m -)
  83 db, ED db, TCELL db,  ( TCELL # EBP SUB,)
  89 db, 45 db, 00 db,    ( EAX 0 EBP@ MOV,)
  ( r/m) EAX MOV,  ;

: DPOP, ( r/m -)
  EAX  SWAP ( r/m) MOV,
  TCELL # EBP ADD,  ;

: DROP,
\  0 EBP@ EAX MOV,
  0 #@ EBP+ EAX MOV,  \ EBP@ workaround
  TCELL # EBP ADD, ;

\ -----------------------------------------------------
\ Floating point instructions
\ Adapted from gforth 0.6.x 386 assembler by B. Paysan, 92--94
\ K. Myneni, 2004-10-20
\ ------------------------------------------------------

HEX

Variable fsize
\ : .fs   0 fsize ! ;
\ : .fd   2 fsize ! ;
\ : .fx   3 fsize ! ;   
: .fl   4 fsize ! ;  
\ : .fw   6 fsize ! ;  
\ : .fq   7 fsize ! ;
.fl 

: ST   ( n -- )  7 and 5C0 or ;
: st?  ( reg -- reg flag ) dup 8 rshift 5 - ;
\ : ?mem ( mem -- mem )  dup C0 < 0= abort" mem expected!" ;


D9 PFX D9,
DE PFX DE,   
: D9: Create 1 CELLS allot? c! DOES> D9, c@ db, ASM-RESET ;
: DE: Create 1 CELLS allot? c! DOES> DE, c@ db, ASM-RESET ;

\ Some floating point instructions with no operands.

D0 D9: FNOP,
E0 D9: FCHS,     E1 D9: FABS,
E4 D9: FTST,     E5 D9: FXAM,
E8 D9: FLD1,     E9 D9: FLDL2T,   EA D9: FLDL2E,   EB D9: FLDPI,
EC D9: FLDLG2,   ED D9: FLDLN2,   EE D9: FLDZ,
F0 D9: F2XM1,    F1 D9: FYL2X,    F2 D9: FPTAN,    F3 D9: FPATAN,
F4 D9: FXTRACT,  F5 D9: FPREM1,   F6 D9: FDECSTP,  F7 D9: FINCSTP,
F8 D9: FPREM,    F9 D9: FYL2XP1,  FA D9: FSQRT,    FB D9: FSINCOS,
FC D9: FRNDINT,  FD D9: FSCALE,   FE D9: FSIN,     FF D9: FCOS,


\ Single operand floating point instructions; operand may be a
\   memory address, indirect register reference, or an fpu
\   stack register.
: fop:  ( n -- ) CREATE 1 CELLS allot? C! 
	         DOES> ( reg/mem/st -- ) C@ >R
	           st? 0= IF  C7 AND R> OR D8 db, db,
	           ELSE  R> OR D8 
	             fsize @ DUP 1 AND DUP 2* + - +
	             db, modDISP,
	           THEN  ASM-RESET ;

OCTAL

( reg/mem/st -- )
00 fop: FADD,    11 fop: FMUL,    22 fop: FCOM,    33 fop: FCOMP,
44 fop: FSUB,    55 fop: FSUBR,   66 fop: FDIV,    77 fop: FDIVR,

HEX

\ Following arithmetic instructions do not use an operand;
\   they operate on st(0) and st(1)
C1 DE: FADDP,
C9 DE: FMULP,
E9 DE: FSUBP,    \  ( -- | Intel Style:  1 = 1 - 0, pop )
E1 DE: FSUBRP,   \  ( -- | Intel Style:  1 = 0 - 1, pop )
F9 DE: FDIVP,    \  ( -- | Intel Style:  1 = 1 / 0, pop )
F1 DE: FDIVRP,   \  ( -- | Intel Style:  1 = 0 / 1, pop )


: FWAIT,   ( -- | wait for fpu ready)       9B db, ; 
: FINIT,   ( -- | initialize fpu)    FWAIT, DB db, E3 db,         ASM-RESET ;
: FNCLEX,  ( -- | clear exceptions)         DB db, E2 db,         ASM-RESET ;
: FCLEX,   ( -- | clear exceptions w/ wait) FWAIT, FNCLEX, ;

: FCOMPP,  ( -- | compare 0-1, pop both)    DE db, D9 db,         ASM-RESET ;
: FUCOMPP, ( -- | unord. comp, pop both)    DA db, E9 db,         ASM-RESET ;
: FUCOM,   ( st -- | unord. compare 0 - st)  7 AND E0 OR DD db, db, ASM-RESET ;
: FFREE,   ( st -- )                        C7 AND DD db, db,     ASM-RESET ;
: FXCH,    ( st -- | exchange 0 and st)     C7 AND  8 OR D9 db, db, ASM-RESET ;

: FBLD,    ( mem -- | load BCD encoded fp)  DF db, 20 OR modDISP, ASM-RESET ;
: FBSTP,   ( mem -- | save in BCD format)   DF db, 30 OR modDISP, ASM-RESET ;
: FSAVE,   ( mem -- | save fpu state) FWAIT, DD db, 30 OR modDISP, ASM-RESET ;
: FRSTOR,  ( mem -- | restore fpu state)    DD db, 20 OR modDISP, ASM-RESET ;

: FNSTCW,  ( mem -- | save control word )   D9 db, 38 OR modDISP, ASM-RESET ; 
: FSTCW,   ( mem -- | save control word )   FWAIT, FNSTCW, ;
: FLDCW,   ( mem -- | load control word )   D9 db, 2D OR modDISP, ASM-RESET ;
: FNSTENV, ( mem -- | save environment )    D9 db, 30 OR modDISP, ASM-RESET ; 
: FSTENV,  ( mem -- | save environment )    FWAIT, FNSTENV, ;
: FLDENV,  ( mem -- | load environment )    D9 db, 20 OR modDISP, ASM-RESET ;

: FNSTSW,  ( reg/mem -- | save status word ) AX = IF 20 DF 
                                ELSE 3D DD THEN  db, modDISP, ASM-RESET ;

: FSTSW,   ( reg/mem -- | save status word ) FWAIT, FNSTSW, ;
: FNENI,   ( -- | enable fpu interrupts )  E0 DB db, db, ASM-RESET ;
: FNDISI,  ( -- | disable fpu interrupts ) E1 DB db, db, ASM-RESET ;

: FLD,     ( st/mem -- ) st? 0= IF    C7 AND D9 db, db, 
                                ELSE  D9 fsize @ OR db, modDISP, 
				THEN  ASM-RESET ;

: FLDT,    ( st/mem10r ) st? 0= IF    C7 AND D9 db, db, 
                                ELSE  DB db, 28 OR modDISP, 
				THEN  ASM-RESET ;


: FST,     ( st/mem -- ) st? 0= IF     7 AND D0 OR DD db, db, 
                                ELSE  D9 fsize @ OR db, 10 OR modDISP, 
				THEN  ASM-RESET ;

: FSTP,    ( st/mem -- ) st? 0= IF    C7 AND DD db, db, 
                                ELSE  D9 fsize @ OR db, 18 OR modDISP, 
				THEN  ASM-RESET ;

: FSTPT,    ( st/mem10r -- ) st? 0= IF   C7 AND DD db, db, 
                                ELSE  DB db, 38 OR modDISP, 
				THEN  ASM-RESET ;

: FILD,    ( mem4 -- | push, 0 = mem4 )  DB db, modDISP, ASM-RESET ;
: FIST,    ( mem4 -- | mem4 = 0 )        DB db, 10 OR modDISP, ASM-RESET ;
: FISTP,   ( mem4 -- | mem4 = 0, pop)    DB db, 18 OR modDISP, ASM-RESET ;
: FIDIV,   ( mem4 -- | 0 = 0 / mem4 )    DA db, 30 OR modDISP, ASM-RESET ;
: FIDIVR,  ( mem4 -- | 0 = mem4 / 0 )    DA db, 38 OR modDISP, ASM-RESET ;
: FIMUL,   ( mem4 -- | 0 = 0 * mem4 )    DA db, 08 OR modDISP, ASM-RESET ;
: FIADD,   ( mem4 -- | 0 = 0 + mem4 )    DA db, modDISP, ASM-RESET ;
: FISUB,   ( mem4 -- | 0 = 0 - mem4 )    DA db, 20 OR modDISP, ASM-RESET ;
: FISUBR,  ( mem4 -- | 0 = mem4 - 0 )    DA db, 28 OR modDISP, ASM-RESET ;
 

\ ----------------------------------------------------
\ K. Myneni's extensions, 2001-10-23
\ ----------------------------------------------------

: [EBP] ( n -- m) DUP 0= IF #@ EBP+ ELSE EBP@ THEN ; \ EBP@ workaround
: [ESP] ( n -- m) #@ ESP+ ;	\  "   "

: [EAX] ( n -- m) EAX@ ;
: [EBX] ( n -- m) EBX@ ;
: [ECX] ( n -- m) ECX@ ;
: [EDX] ( n -- m) EDX@ ;
: [ESI] ( n -- m) ESI@ ;
: [EDI] ( n -- m) EDI@ ;

\ ----------------------------------------------------
\ kForth Interface
\ ----------------------------------------------------

ASM-RESET
USE32
DECIMAL

 128  CONSTANT  TINYCODESIZE
 256  CONSTANT  SMALLCODESIZE
1024  CONSTANT  MEDIUMCODESIZE
4096  CONSTANT  LARGECODESIZE

VARIABLE CODE-STACK-PTR

: SIZED-CODE ( n -- )
        ALSO ASSEMBLER
	CREATE IMMEDIATE MC-Allot?
        DUP FALSE MC-Executable invert 
        ABORT" Failed to make CODE memory (read/write)able!" 
        ASM-TO
	  TCELL # EBX ADD,
	DOES>
          a@ 
	  POSTPONE LITERAL
	  POSTPONE CALL               
	  CODE-STACK-PTR 
	  POSTPONE LITERAL
	  POSTPONE a@ 
	  POSTPONE SP! ;

: END-CODE       
	EBX CODE-STACK-PTR #@ MOV,    \ update stack ptr
	RET,
        ASM0 a@ TRUE MC-Executable invert
        ABORT" Failed to make CODE word executable!"
	ASM-RESET PREVIOUS ;

: CALL-CODE ( -- | use to call another CODE word from inside a CODE word)
    ' >BODY a@ TCELL + 2+  \ skip prefix assembly code for advancing EBX
    #   CALL,
;

ALSO FORTH DEFINITIONS

\ These words provide control of allocated memory for code definitions
  
: TINY-CODE   TINYCODESIZE SIZED-CODE ;
: SMALL-CODE  SMALLCODESIZE SIZED-CODE ;
: MEDIUM-CODE MEDIUMCODESIZE SIZED-CODE ;
: LARGE-CODE  LARGECODESIZE SIZED-CODE ;

: CODE SMALL-CODE ; \ default for code provides 256 bytes

\ CODE Macros

: MACRO: ( -- | define a macro)
        ALSO ASSEMBLER
	CREATE TINYCODESIZE CELL+ 
        ALLOT? CELL+ ASM-TO
	DOES> ( a -- )
	  DUP @ SWAP CELL+ SWAP
	  0 ?DO DUP C@ db, 1+ LOOP DROP ;

: END-MACRO ( -- | end of the macro)
        >ASM @ ASM0 a@ 1 CELLS - ! ASM-RESET 
        PREVIOUS ;

PREVIOUS
PREVIOUS

BASE !

