\ parallel-mm.4th
\
\ Parallel matrix multiplication on a multi-core machine using the
\ syscalls, fork and mmap.
\
\ Krishna Myneni, 2010-04-17
\
\ Multiply an n x m matrix A with a m x 1 vector B to find the n x 1
\ result. Use one process to multiply the even rows of A with B, and
\ use the child process to multiply the odd rows of A with B.
\
\ Notes:
\
\  0) The syscalls, "fork", "mmap", and "munmap" are implemented
\     in syscalls.4th.
\
\  1) It is assumed that on a multi-core CPU, the child process is
\     forked by the OS to use a different core. On a 4-core machine,
\     we find this to be true under Linux.
\
\  2) The input matrix A{{ and array B{ are not in shared memory
\     since both processes have access to separate copies of their
\     fixed data, and do not write to these. The computed product
\     data must be in a shared region to allow the main process to
\     obtain the child-computed data. For very large matrices, A{{
\     and B{ can be kept in shared memory as well.
\
\ Revisions:
\   2010-04-17  km  use syscall waitpid to wait for child to terminate
\                   before measuring elapsed time; renamed syscalls386.4th
\                   to syscalls.4th so INCLUDE statement changed accordingly.
\   2015-08-01  km  include modules.fs since syscalls.4th is now a module.
\   2017-05-13  km  updated to use shared memory to communicate child
\                   process calculation to parent. Store single process
\                   and parallel process calculations in separate arrays
\                   for comparison. The code is generalized for an 
\                   arbitrary number of rows for matrix A{{ .

include ans-words
include strings
include modules
include syscalls
include fsl/fsl-util
include fsl/horner
include fsl/extras/noise

Also syscalls

variable cpid        \ child process id
variable status
variable shared_mem  \ address of shared memory buffer used by
                     \   both child and parent.

1000000 constant NCOLS
4       constant NROWS

NROWS DFLOATS constant SHARED_LEN  \ length of shared memory region

NROWS NCOLS FLOAT MATRIX A{{
NCOLS FLOAT ARRAY B{
NROWS FLOAT ARRAY S{          \ result from single process
NROWS FLOAT ARRAY P{          \ result from parallel processes

\ Allocate u bytes of shared memory for parallel processes
\ to write their outputs. Return shared memory address or
\ -1 if allocation fails.
: allocate-shared ( u -- addr )
   0                         \ address picked by kernel 
   swap                      \ length of region to map
   PROT_READ PROT_WRITE or   \ able to read and write 
   MAP_SHARED MAP_ANONYMOUS or   \ shared memory, no file used
   -1                            \ fd
   0                             \ offset
   mmap ;

\ Return -1 if free-shared fails.
: free-shared ( addr u -- n )  munmap ;

: init-matrices ( -- )
	NCOLS 0 DO  NROWS 0 DO  ran0 A{{ I J }} F!  LOOP  LOOP
	NCOLS 0 DO  ran0  B{ I } F!  LOOP ;

0 value row
: mul-row ( nrow -- r )
        to row
        0e  NCOLS 0 DO  A{{ row I }} F@ B{ I } F@ F* F+  LOOP ;

\ Use a single process to perform the multiplication one row at a time
: single-process ( -- )
     NROWS 0 ?DO
       I mul-row S{ I } f!
     LOOP
;

: parallel-process ( -- )
     \ ms@ cr ." Start of parent: " .
     fork  dup cpid !
     0< ABORT" Unable to fork!"  
     cpid @ 0= IF
	\ child  handles multiplication of odd rows of A{{
        NROWS 1 ?DO
          \ I 2 mod IF 
            I mul-row  
            shared_mem a@ I floats + f!
          \ THEN
	2 +LOOP
        bye    
     ELSE
 	\ parent handles multiplication of even rows of A{{ 
        NROWS 0 ?DO
          \ I 2 mod 0= IF
	    I mul-row 
            shared_mem a@ I floats + f!
          \ THEN
        2 +LOOP
     THEN
;

\ Setup matrices, run the single process calculation,
\ then the parallel calculation, storing the results in
\ arrays S{ and P{ , respectively. Measure and report the
\ execution times for both calculations 
cr .( Initializing the matrices ... )
init-matrices
cr .( The matrix A is ) NROWS . .( x ) NCOLS . 

cr cr .( Performing singe process calcualtion. )
ms@ single-process ms@ swap -
cr .( Elapsed [ms]: ) .

cr cr .( Performing the parallel processing calculation. )
cr .( Allocate shared memory. )
SHARED_LEN allocate-shared
dup shared_mem !
-1 = [IF]
  cr .( Unable to allocate shared memory! )
  quit
[THEN]

ms@ 
parallel-process
\ parent has finished; now, wait for the child to terminate
cpid @ status 0 waitpid cpid @ <> 
[IF] 
cr .( Child process did not terminate properly! )
[ELSE]
\ Transfer shared memory to array P{
shared_mem a@ P{ 0 } NROWS floats move  
ms@ swap - 
cr .( Elapsed [ms]: ) . 
[THEN]

cr .( Free shared memory region ) cr
shared_mem a@ SHARED_LEN free-shared
-1 = [IF]
   .( Error freeing shared memory! ) cr
[THEN]

\ Compare parallel and serial results
P{ 0 } S{ 0 } NROWS floats tuck compare
cr .( Parallel result is ) [IF] .( NOT ) [THEN]
.( equal to single process result. ) cr

cr .( To print the results, type ) cr
cr .(    NROWS S{ }fprint )
cr .(    NROWS P{ }fprint )

