\ fcalls-x86.4th
\
\ Forth to C function Calling Interface for kForth
\
\ Krishna Myneni, Creative Consulting for Research & Education
\ krishna.myneni@ccreweb.org
\
\ This software is provided under the GNU Lesser General Public License
\ (LGPL).
\
\ Requires:
\   ans-words, asm-x86
\
\ Revisions:
\   2009-10-02  km  created
\   2009-10-04  km  implemented generic fcall
\   2009-10-07  km  renamed to fcall-x86.4th and moved
\                   library interface words to lib-interface.4th
\   2009-10-12  km  use assembler macro to consolidate code
\                   for fcall and fcall-noret
\   2009-11-18  km  added fcall-1r to provide interface to functions
\                   returning floating point number (single or double precision)

\ The fcallx words all assume that the arguments are 
\ single or double cell values, with no double precision
\ floating point args.
\
\ fcall[-x] cannot handle zero number of args. Use fcall0
\ or fcall0-noret for zero args.
\
\ In order to use the generic fcall, we make an assumption
\ about the stack usage of the function we are calling. Below, we
\ assume that the called function does not require > 64K of stack.
65536 constant MAX_FUNC_STACK

MACRO: fcall-m
   0 [ebx] eax mov,
   TCELL # ebx add,
   0 [ebx] ecx mov,
   TCELL # ebx add,
           ebx push,
       ecx edx mov,
    DO,
       0 [ebx] push,
       TCELL # ebx add,
    LOOP,
         MAX_FUNC_STACK # esp sub,
	 edx push,                          \ store arg count at a "safe" offset
	 MAX_FUNC_STACK TCELL + # esp add,
         eax call,
	 MAX_FUNC_STACK TCELL + # esp sub,
	 ecx pop,                           \ restore arg count
	 MAX_FUNC_STACK # esp add,

	 ecx edx mov,	
	 2 # ecx shl,
	 ecx esp add,          \ offset the machine stack ptr

         ebx pop,              \ restore Forth stack ptr

         edx ecx mov,
	 ecx dec,
	 2 # ecx shl,
	 ecx ebx add,          \ offset the Forth stack ptr to drop args 
END-MACRO


CODE fcall ( ... ncells addr -- val)
     fcall-m
     eax 0 [ebx] mov,
     0 # eax mov,
END-CODE


CODE fcall-1r ( ... ncells addr -- r )
     fcall-m
     TCELL # ebx sub,
     0 [ebx] fstp,
     0 # eax mov,
END-CODE


\ WARNING: Number of items on stack prior to calling fcall-2r must occupy 
\   a minimum of four cells, due to asm-x86 limitation under kForth
CODE fcall-2r ( ... ncells addr -- r r )
     fcall-m
     TCELL # ebx sub,
     0 [ebx] fstp,
     TCELL 2* # ebx sub,
     0 [ebx] fstp,
     0 # eax mov,
END-CODE


CODE fcall-noret ( ... ncells addr -- )  \ same as fcall but with no return value
     fcall-m
     TCELL # ebx add,
     0 # eax mov,
END-CODE 

\ call a function with no arguments but with one return value
CODE fcall0 ( addr -- val )  
    0 [ebx] eax mov,
    ebx push,
    eax call,
    ebx pop,
    eax 0 [ebx] mov,
    0 # eax mov,
END-CODE

\ call a function with no arguments and no return value
CODE fcall0-noret ( addr -- )  
    0 [ebx] eax mov,
    TCELL # ebx add,
    ebx push,
    eax call,
    ebx pop,
    0 # eax mov,
END-CODE


