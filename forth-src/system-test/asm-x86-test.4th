\ asm-x86-test.4th
\
\ Some basic tests to verify that the asm-x86 assembler is functioning
\ correctly within the Forth environment.
\
\ Copyright (c) 2009 Creative Consulting for Research and Education
\ Provided under the GNU Lesser General Public License (LGPL).
\
\ Requires kForth v1.5.x: 
\   ans-words.4th, ttester.4th, asm-x86.4th, dump.4th, 
\   asm-x86-examples.4th
\
\ Revisions:
\   2009-10-09  km  created
\
\
s" ans-words" included
s" ttester" included
s" asm-x86-examples" included


DECIMAL
TESTING Use of ADD, MOV, IMUL,
T{   5 adrop ->    }T
T{ 1 2 adrop ->  1 }T

T{  16 add5 -> 21 }T
T{ -10 add5 -> -5 }T

T{  0  5 add ->  5 }T
T{  1 -1 add ->  0 }T
T{ -2 -3 add -> -5 }T

T{  6  3 mul  ->  18 }T
T{ -6  3 mul  -> -18 }T
T{ -3  6 mul  -> -18 }T
T{ -6 -3 mul  ->  18 }T


TESTING Use of CXNZ, IF, THEN, DO, LOOP, INC,
312 v !
T{ -1 add-loop -> 311 }T

TESTING Use of BEGIN, WHILE, REPEAT, CMP, <, XOR,
0 v !
T{ test1 v @  ->  100 }T

TESTING Use of LABEL: JMP, >,
0 v !
T{ test2 v @  ->  100 }T
50 v !
T{  -1 v>  -> FALSE }T
T{   0 v>  -> FALSE }T
T{  50 v>  -> FALSE }T
T{  51 v>  -> TRUE  }T
