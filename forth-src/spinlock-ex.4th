\ spinlock-ex.4th
\
\  Demonstrate mutual exclusion of a resource, shared by two tasks, through
\  the method of spin locking. In this example, the shared resource is not
\  specified; it may be a hardware device, a file, memory, etc.
\
\  Copyright (c) 2007 Krishna Myneni
\
\  Requires:
\	signal.4th
\       asm-x86.4th
\  Revisions:
\       2007-08-25  created  km
\

include signal.4th
include asm-x86.4th

VARIABLE DAQ_IN_USE  ( the lock variable )
VARIABLE START_TIME
VARIABLE SLEEP_TIME  ( sleep time in microseconds )
300000 SLEEP_TIME !

: elapsed ( -- u )  ms@ START_TIME @ - ;

\ : spin-lock ( a -- )
\    BEGIN DUP @ 0= UNTIL true SWAP ! ;

\ assembler spin-lock is different from Forth version above

CODE spin-lock ( a -- )
    TRUE #  eax  mov,
    0 [ebx] ecx  mov,
    BEGIN,
      eax  0 [ecx] xchg,
      0<,
    WHILE,
    REPEAT,
    0 #     eax  mov,
    TCELL # ebx  add,
END-CODE

    
\ : unlock ( a -- )  0 SWAP ! ;

CODE unlock ( a -- )
    0 [ebx] ecx  mov,
    0 #  0 [ecx] mov,
    TCELL # ebx  add,
END-CODE


: handler ( n -- )
    DROP
    DAQ_IN_USE spin-lock
    CR elapsed 6 .r ."   HANDLER has lock!"
    100 MS  ( time to process with shared resource )
    DAQ_IN_USE unlock
;


CR .( Use ESC to halt the test)

: test  ( -- )
    DAQ_IN_USE unlock       \ for safety
    ['] handler SIGALRM forth-signal drop  \ install the handler
    1000 1000 SET-TIMER     \ Send SIGALRM to kForth every 1000 ms
    ms@ START_TIME !
    BEGIN
	KEY? IF
	    KEY 27 = IF
		SIG_IGN SIGALRM  forth-signal  DROP  \ Stop sending SIGALRM
		CR ." Exiting test "
		EXIT
	    THEN
	THEN
	DAQ_IN_USE spin-lock
	CR elapsed 6 .r ."   test has lock."
	100 MS  ( time to process with shared resource )
	DAQ_IN_USE unlock
	SLEEP_TIME @ usleep        \ relinquish control to the system for a while
    AGAIN
;

test

