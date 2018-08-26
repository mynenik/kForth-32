\ hanoi.4th
\
\ Towers of Hanoi puzzle
\ 
\ From a posting to comp.lang.forth, 30 May 2002, by Marcel 
\   Hendrix and Brad Eckert. According  to Marcel Hendrix, the 
\   code for the HANOI algorithm was originally posted to clf 
\   by Raul Deluth Miller in 1994.
\ ---------------------------------------------------------------------------
\ kForth includes and defs  (2002-05-30  K. Myneni)
\
include strings
include ansi
: chars ;
\ ---------------------------------------------------------------------------
\ To run under other ANS Forths, uncomment the defs below:
\ : a@ @ ;
\ : ?allot here swap allot ;
\ : nondeferred ;

variable slowness  1000 slowness !      \ ms delay between screen updates
create PegSPS  3 cells allot            \ pointers for three disk stacks

: PegSP     ( peg -- addr ) cells PegSPS + ;
: PUSH      ( c peg -- )    PegSP tuck a@ c!  1 chars swap +! ;
: POP       ( peg -- c )    PegSP -1 chars over +!  a@ c@ ;

create PegStacks  30 chars allot        \ stack area for up to 10 disks

: PegStack  ( peg -- addr ) 10 * PegStacks + ;
: PegClr    ( peg -- )      dup PegStack  swap PegSP ! ;
: PegDepth  ( peg -- depth) dup PegSP @  swap PegStack - ; \ not needed

: ShowDisk  ( level diameter peg )
  22 * 10 + over -  rot 10 swap - at-xy \ position cursor
  1+ 2* 0 ?do [char] * emit loop ;      \ display the disk

: ShowPeg   ( peg -- )  dup >r PegStack
      BEGIN  r@ PegSP @ over <>
      WHILE  dup r@ PegStack - over c@  ( addr level diameter )
             r@ ShowDisk  char+
     REPEAT  drop r> drop ;

: MAKETAB   CREATE dup ?allot over 1- + swap 0 ?do dup >r c! r> 1- loop drop 
	DOES> + c@ ;

: base3 [ decimal ] 3 base ! ; nondeferred
base3  00 02 01 12 00 10 21 20  decimal 8 maketab TO!
base3  00 21 12 20 00 02 10 01  decimal 8 maketab FRO!


: ShowPegs  ( -- )           page 3 0 do i showpeg loop slowness @ ms 
	key? if key drop 0 11 at-xy ." Stopped" cr abort then ;

: MoveRing  ( ring -- ring ) dup to! 3 / pop  over fro! 3 mod push
	ShowPegs ;

: HANOI     ( depth direction -- depth direction ) swap 1- swap
    over IF  to!  recurse  to! MoveRing fro! recurse  fro!
       ELSE  MoveRing
       THEN  swap 1+ swap ;

: PLAY      ( depth -- )
  3 0 DO i PegClr LOOP                          \ clear the pegs
  dup BEGIN ?dup WHILE 1- dup 0 push REPEAT     \ stack up some disks
  showpegs 1 HANOI 2drop                        \ move them
  0 11 at-xy ;

4 play