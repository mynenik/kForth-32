\ crc-32-x86.4th
\
\ Based on crc-32.f for SwiftForth by 
\ Petrus Prawirodidjojo Thu 2001-10-18
\
\ Modified for asm-x86 under kForth by K. Myneni
\
\ Revisions:
\   2001-10-18 -- initial port (non-functional)
\   2007-01-07 -- working version; required fixes to asm-x86 for
\                   proper assembly of byte and word register operands  km
\
\ Requires: asm-x86.4th
\
base @
hex
EDB88320  constant  CRC-POLYNOMIAL

CODE crc32  ( n1 char -- n2 )
    0 [ebx] eax  mov,  	
    TCELL # ebx  add,
    0 [ebx] edx  mov,   \ crc to edx
            ebx  push,
    eax     ebx  mov,
    8 #     ecx  mov,  	\ loop count
    DO,
        1 # edx  shr,	\ shift crc
        1 #  bh  rcr,
        1 #  bl  ror,	\ shift character
        bx   ax  mov,   \ save character
        bh   bl  xor,   \ xor
        0<, IF,   	\ skip if equal
          CRC-POLYNOMIAL # edx xor,  \ crc-32 polymial 1 04C1 1DB7
        THEN,
        ax   bx  mov,   	\ restore character
    LOOP,   		\ next bit
            ebx  pop,
    edx  0 [ebx] mov,  \ crc to tos
    0 #     eax  mov,
END-CODE

base !

\ calculate crc-32 for several strings
: crc-32  ( n1 c-addr u -- n2 )
    0 do   \ n c-addr
      dup >r c@ crc32 r> 1+ loop drop ;

\ calculate crc-32 of a string
: crc32s  ( c-addr u -- n )
    -1 -rot crc-32 invert ;

\ test
: test
    cr cr ." crc-32" cr
    s" An Arbitrary String" 2dup type cr
    ."   crc-32: " crc32s hex u. decimal ." should be 6FBEAAE7" cr
    s" ZYXWVUTSRQPONMLKJIHGFEDBCA" 2dup type cr
    ."   crc-32: " crc32s hex u. decimal ." should be 99CDFDB2" cr ;

test

\ end of application, - do not delete -


