// vm32-fast.s
//
// The assembler portion of the kForth 32-bit Virtual Machine
// (fast version)
//
// Copyright (c) 1998--2025 Krishna Myneni,
//   <krishna.myneni@ccreweb.org>
//
// This software is provided under the terms of the GNU 
// Affero General Public License (AGPL), v3.0 or later.
//
// Usage from C++
//
//       extern "C" int vm (byte* ip);
//       ecode = vm(ip);
//

.set __FAST__, -1
.include "vm32-common.s"

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro SWAP
	mov %ebx, %edx
        INC_DSP
	mov (%ebx), %eax
	INC_DSP
	mov (%ebx), %ecx
	mov %eax, (%ebx)
	DEC_DSP
	mov %ecx, (%ebx)
        mov %edx, %ebx 
	xorl %eax, %eax
.endm

// Regs: ebx, ecx
// In: ebx = DSP
// Out: ebx = DSP
.macro OVER
        movl 2*WSIZE(%ebx), %ecx
        mov  %ecx, (%ebx)
	DEC_DSP
.endm

// Regs: eax, ebx, ecx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro TWO_DUP
        OVER
        OVER
.endm

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro FDUP
	mov %ebx, %ecx
	INC_DSP
	mov (%ebx), %edx
	INC_DSP
	mov (%ebx), %eax
	mov %ecx, %ebx
	mov %eax, (%ebx)
	DEC_DSP
	mov %edx, (%ebx)
	DEC_DSP
	xor %eax, %eax
.endm

// Regs: ebx
// In: ebx = DSP
// Out: ebx = DSP
.macro FDROP
	INC2_DSP
.endm

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro FSWAP
	movl $WSIZE, %ecx
	add  %ecx, %ebx
	mov  (%ebx), %edx
	add  %ecx, %ebx
	mov  (%ebx), %eax
	add  %ecx, %ebx
	xchgl %edx, (%ebx)
	add  %ecx, %ebx
	xchgl %eax, (%ebx)
	sub  %ecx, %ebx
	sub  %ecx, %ebx
	mov  %eax, (%ebx)
	sub  %ecx, %ebx
	mov  %edx, (%ebx)
	sub  %ecx, %ebx
	xor  %eax, %eax
.endm

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro FOVER
	mov  %ebx, %ecx
	addl $3*WSIZE, %ebx
	mov  (%ebx), %edx
	INC_DSP
	mov  (%ebx), %eax
	mov  %ecx, %ebx
	mov  %eax, (%ebx)
	DEC_DSP
	mov  %edx, (%ebx)
	DEC_DSP
	xor  %eax, %eax
.endm

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro PUSH_R
	movl $WSIZE, %eax
	add  %eax, %ebx	
	mov  (%ebx), %ecx
	movl GlobalRp, %edx
	mov  %ecx, (%edx)
	sub  %eax, %edx
	movl %edx, GlobalRp
        xor  %eax, %eax
.endm

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro POP_R
	movl $WSIZE, %eax
	movl GlobalRp, %edx
	add  %eax, %edx
	movl %edx, GlobalRp
	mov  (%edx), %ecx
	mov  %ecx, (%ebx)
	sub  %eax, %ebx
	xor  %eax, %eax
.endm

// Regs: eax, ebx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro FETCH        
	mov  %ebx, %edx	
	addl $WSIZE, %edx
        mov  (%edx), %eax	
        mov  (%eax), %eax
	mov  %eax, (%edx)
	xor  %eax, %eax
.endm

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro STORE        	
        movl $WSIZE, %eax
        add  %eax, %ebx
        mov  (%ebx), %ecx	# address to store to in ecx
	add  %eax, %ebx
	mov  (%ebx), %edx	# value to store in edx
	mov  %edx, (%ecx)
	xor  %eax, %eax
.endm

// Dyadic Logic operators 
// Regs: eax, ebx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro LOGIC_DYADIC op  
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %eax
	\op  %eax, WSIZE(%ebx)
	xor  %eax, %eax 
.endm
	
.macro _AND
	LOGIC_DYADIC andl
.endm

.macro _OR
	LOGIC_DYADIC orl
.endm

.macro _XOR
	LOGIC_DYADIC xorl
.endm

// Dyadic relational operators (single length numbers) 
// Regs: eax, ebx, ecx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro REL_DYADIC setx  
	movl $WSIZE, %ecx
	add  %ecx, %ebx
	mov  (%ebx), %eax
	cmpl %eax, WSIZE(%ebx)
	movl $0, %eax
	\setx %al
	neg  %eax
	movl %eax, WSIZE(%ebx)
	xor  %eax, %eax
.endm

// Relational operators for zero (single length numbers)
// Regs: eax, ebx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro REL_ZERO setx
	INC_DSP
	mov  (%ebx), %eax
	cmpl $0, %eax
	movl $0, %eax
	\setx %al
	neg  %eax
	mov  %eax, (%ebx)
	DEC_DSP
	xor  %eax, %eax
.endm

// Regs: eax, ebx, ecx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro FREL_DYADIC logic arg set
	movl $WSIZE, %ecx
	add  %ecx, %ebx
	fldl (%ebx)
	add  %ecx, %ebx
	add  %ecx, %ebx
	fcompl (%ebx)
	fnstsw %ax
	andb $65, %ah
	\logic \arg, %ah
	movl $0, %eax
	\set %al
	neg  %eax
	add  %ecx, %ebx
	mov  %eax, (%ebx)
	sub  %ecx, %ebx
	xor  %eax, %eax
.endm

# b = (d1.hi < d2.hi) OR ((d1.hi = d2.hi) AND (d1.lo u< d2.lo))
// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro DLT
	movl $WSIZE, %ecx
	xor  %edx, %edx
	add  %ecx, %ebx
	mov  (%ebx), %eax
	cmpl %eax, 2*WSIZE(%ebx)
	sete %dl
	setl %dh
	add  %ecx, %ebx
	mov  (%ebx), %eax
	add  %ecx, %ebx
	add  %ecx, %ebx
	cmpl %eax, (%ebx)
	setb %al
	andb %al, %dl
	orb  %dh, %dl
	xor  %eax, %eax
	movb %dl, %al
	neg  %eax
	mov  %eax, (%ebx)
	sub  %ecx, %ebx	
	xor  %eax, %eax
.endm

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro BOOLEAN_QUERY
        DUP
        REL_ZERO setz
        SWAP
        movl $TRUE, (%ebx)
        DEC_DSP
        REL_DYADIC sete
        _OR
.endm

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro TWO_BOOLEANS
        TWO_DUP
        BOOLEAN_QUERY
        SWAP
        BOOLEAN_QUERY
        _AND
.endm

// Regs: ebx, 
// In: ebx = DSP
// Out: ebx = DSP
.macro  CHECK_BOOLEAN
        DROP
        cmpl $TRUE, (%ebx)
        jnz E_arg_type_mismatch
.endm


// VIRTUAL MACHINE 
					
.global vm
	.type	vm,@function
vm:	
        push  %ebp
        push  %ebx
	pushl GlobalIp
	pushl vmEntryRp
        mov  %esp, %ebp
        movl 20(%ebp), %ebp     # load the Forth instruction pointer
        movl %ebp, GlobalIp
	movl GlobalRp, %eax
	movl %eax, vmEntryRp
	xor  %eax, %eax
	LDSP
next:
        movb (%ebp), %al         # get the opcode
	movl JumpTable(,%eax,4), %ecx	# machine code address of word
	xor  %eax, %eax          # clear error code
	call *%ecx		 # call the word
	LDSP
	movl GlobalIp, %ebp
	incl %ebp		 # increment the Forth instruction ptr
	movl %ebp, GlobalIp
	cmpl $0, %eax		 # check for error
	jz next        
exitloop:
        cmpl $OP_RET, %eax         # return from vm?
        jnz vmexit
        xor %eax, %eax            # clear the error
vmexit:
	pop vmEntryRp
	pop GlobalIp
        pop %ebx
        pop %ebp
        ret

L_ret:
	movl vmEntryRp, %eax		# Return Stack Ptr on entry to VM
	movl GlobalRp, %ecx
	cmp  %eax, %ecx
	jl ret1
        movl $OP_RET, %eax             # exhausted the return stack so exit vm
        ret
ret1:
	addl $WSIZE, %ecx
        movl %ecx, GlobalRp
ret2:   mov  (%ecx), %eax
	movl %eax, GlobalIp		# reset the instruction ptr
        xor  %eax, %eax
retexit:
        ret

L_jz:
        DROP
        mov  (%ebx), %eax
        cmpl $0, %eax
        jz jz1
        movl $WSIZE, %eax
        add  %eax, %ebp       # do not jump
        xor  %eax, %eax
        NEXT
jz1:    mov  %ebp, %ecx
        inc  %ecx
        mov  (%ecx), %eax       # get the relative jump count
        dec  %eax
        add  %eax, %ebp
        xor  %eax, %eax
        NEXT

# L_tobody:
#	INC_DSP
#	mov  (%ebx), %ecx	# code address
#	inc  %ecx		# the data address is offset by one
#	mov  (%ecx), %ecx
#	mov  %ecx, (%ebx)
#	DEC_DSP
#	STSP
#	ret

L_vmthrow:      # throw VM error (used as default exception handler)
        INC_DSP
        mov (%ebx), %eax
        STSP
        ret

L_base:
        movl $Base, (%ebx)
        DEC_DSP
        NEXT

L_precision:
        movl Precision, %ecx
        mov  %ecx, (%ebx)
        DEC_DSP
        NEXT

L_setprecision:
        DROP
        mov  (%ebx), %ecx
        movl %ecx, Precision
        NEXT

L_false:
        movl $FALSE, (%ebx)
        DEC_DSP
        NEXT

L_true:
        movl $TRUE, (%ebx)
        DEC_DSP
        NEXT

L_bl:
        movl $32, (%ebx)
        DEC_DSP
        NEXT

L_lshift:
        DROP
        mov (%ebx), %ecx
        cmp $MAX_SHIFT_COUNT, %ecx
        jbe lshift1
        movl $0, WSIZE(%ebx)
        NEXT
lshift1:
        shll %cl, WSIZE(%ebx)
        NEXT

L_rshift:
        DROP
        mov (%ebx), %ecx
        cmp $MAX_SHIFT_COUNT, %ecx
        jbe rshift1
        movl $0, WSIZE(%ebx)
        NEXT
rshift1:
        shrl %cl, WSIZE(%ebx)
        NEXT


#
# For precision delays, use MS instead of USLEEP
# Use USLEEP when task can be put to sleep and reawakened by OS
#
L_usleep:
	DROP
	mov  (%ebx), %eax
	push %eax
	call usleep
	addl $WSIZE, %esp
	xor  %eax, %eax
	NEXT

L_ms:
	movl WSIZE(%ebx), %eax
	imull $1000, %eax
	movl %eax, WSIZE(%ebx)
	call C_usec
        INC_DSP
	NEXT

L_fill:
        DROP
	movl WSIZE(%ebx), %ecx
	push %ecx         # byte count
	mov  (%ebx), %ecx
	push %ecx         # fill byte
	INC2_DSP
	mov  (%ebx), %eax
	push %eax
	call memset
	addl $3*WSIZE, %esp
        STSP
	xor  %eax, %eax
	ret

L_erase:
	movl $0, (%ebx)
	DEC_DSP
	call L_fill
	NEXT

L_blank:
	movl $32, (%ebx)
	DEC_DSP
	call L_fill
	NEXT

L_move:
        DROP
        mov  (%ebx), %eax
        push  %eax
        DROP
        movl WSIZE(%ebx), %eax
        push %eax
        mov  (%ebx), %eax
        push  %eax
        DROP
        call memmove
        addl $3*WSIZE, %esp
        xor  %eax, %eax
        NEXT

L_cmove:
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %ecx		# nbytes in ecx
	cmpl $0, %ecx
	jnz  cmove1
	INC2_DSP
	xor %eax, %eax
	NEXT		
cmove1:	add  %eax, %ebx
	mov  (%ebx), %edx		# dest addr in edx
	add  %eax, %ebx
        push %ebx
	mov  (%ebx), %ebx		# src addr in ebx
cmoveloop: 
        movb (%ebx), %al
	movb %al, (%edx)
	inc  %ebx
	inc  %edx
	loop cmoveloop
	pop %ebx
	xor %eax, %eax				
	NEXT

L_cmovefrom:
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %ecx	# load count register
	add  %eax, %ebx
cmovefrom2:
	mov  (%ebx), %edx
	add  %ecx, %edx         
	dec  %edx               # dest addr in %edx
	add  %eax, %ebx
cmovefrom3:
	STSP
	movl %ecx, %eax
	cmpl $0, %eax
	jnz cmovefrom4
	ret
cmovefrom4:
	movl (%ebx), %ebx	
	decl %eax
	addl %eax, %ebx		# src addr in %ebx
cmovefromloop:	
	movb (%ebx), %al
	decl %ebx
	xchgl %ebx, %edx
	movb %al, (%ebx)
	decl %ebx
	xchgl %ebx, %edx
	loop cmovefromloop	
	xor %eax, %eax
	ret

L_slashstring:
	INC_DSP
	mov (%ebx), %ecx
	INC_DSP
	sub %ecx, (%ebx)
	INC_DSP
	add %ecx, (%ebx)
	subl $2*WSIZE, %ebx
	NEXT

L_call:	
	INC_DSP
	STSP
	call *(%ebx)
	LDSP
	ret

L_push_r:
	PUSH_R
        NEXT

L_pop_r:
	POP_R
	NEXT

L_twopush_r:
	INC_DSP
	mov  (%ebx), %edx
	INC_DSP
	mov  (%ebx), %eax
	movl GlobalRp, %ecx
	mov  %eax, (%ecx)
	subl $WSIZE, %ecx
	mov  %edx, (%ecx)
	subl $WSIZE, %ecx
	movl %ecx, GlobalRp
	xor  %eax, %eax
	NEXT

L_twopop_r:
	movl GlobalRp, %ecx
	addl $WSIZE, %ecx
	mov  (%ecx), %edx
	addl $WSIZE, %ecx
	mov  (%ecx), %eax
	movl %ecx, GlobalRp
	mov  %eax, (%ebx)
	DEC_DSP
	mov  %edx, (%ebx)
	DEC_DSP
	xor  %eax, %eax				
	NEXT

L_puship:
        mov  %ebp, %eax
        movl GlobalRp, %ecx
        mov  %eax, (%ecx)
	movl $WSIZE, %eax
        subl %eax, GlobalRp
        xor  %eax, %eax
        NEXT

L_execute_bc:	
        mov  %ebp, %ecx
        movl GlobalRp, %edx
        mov  %ecx, (%edx)
	movl $WSIZE, %eax 
        sub  %eax, %edx 
	movl %edx, GlobalRp
        add  %eax, %ebx
        mov  (%ebx), %eax
	dec  %eax
	mov  %eax, %ebp
        xor  %eax, %eax
        NEXT

L_execute:
        mov  %ebp, %ecx
        movl GlobalRp, %edx
        mov  %ecx, (%edx)
        movl $WSIZE, %eax
        sub  %eax, %edx
        movl %edx, GlobalRp
        add  %eax, %ebx
        mov  (%ebx), %eax
	mov  (%eax), %eax
        dec  %eax
        mov  %eax, %ebp
        xor  %eax, %eax
        NEXT


L_definition:
        mov  %ebp, %eax
	inc  %eax
	mov  (%eax), %ecx # address to execute
	addl $WSIZE-1, %eax
	mov  %eax, %edx
	movl GlobalRp, %eax
	mov  %edx, (%eax)
	subl $WSIZE, %eax
	movl %eax, GlobalRp
	dec  %ecx
	mov  %ecx, %ebp
        xor  %eax, %eax	
	NEXT

L_rfetch:
        movl GlobalRp, %ecx
	movl $WSIZE, %eax
        add  %eax, %ecx
        mov  (%ecx), %ecx
        mov  %ecx, (%ebx)
        sub  %eax, %ebx
        xor  %eax, %eax
	NEXT

L_tworfetch:
	movl GlobalRp, %ecx
	movl $WSIZE, %eax
	add  %eax, %ecx
	mov  (%ecx), %edx
	add  %eax, %ecx
	mov  (%ecx), %ecx
	mov  %ecx, (%ebx)
	sub  %eax, %ebx
	mov  %edx, (%ebx)
	sub  %eax, %ebx
	xor  %eax, %eax				
	NEXT

L_rpfetch:
	movl GlobalRp, %ecx
	movl $WSIZE, %eax
	add  %eax, %ecx
	mov  %ecx, (%ebx)
	sub  %eax, %ebx
	xor  %eax, %eax
	NEXT

L_spfetch:
	mov  %ebx, %ecx
	movl $WSIZE, %eax
	add  %eax, %ecx
	mov  %ecx, (%ebx)
	sub  %eax, %ebx
	xor  %eax, %eax 
	NEXT

L_i:
        movl GlobalRp, %ecx
        movl 3*WSIZE(%ecx), %ecx
        mov  %ecx, (%ebx)
        DEC_DSP 
        NEXT

L_j:
        movl GlobalRp, %ecx
        movl 6*WSIZE(%ecx), %ecx
        mov  %ecx, (%ebx)
        DEC_DSP
        NEXT	

L_rtloop:
        movl GlobalRp, %ebx	
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %edx
	add  %eax, %ebx
	mov  (%ebx), %ecx
	add  %eax, %ebx
        mov  (%ebx), %eax
        inc  %eax
	cmp  %ecx, %eax	
        jz L_rtunloop
loop1:	
        mov  %eax, (%ebx)	# set loop counter to next value
	mov  %edx, %ebp		# set instruction ptr to start of loop
	LDSP
        xor  %eax, %eax
        NEXT

L_rtunloop:  
	UNLOOP
	LDSP
	xor %eax, %eax
        NEXT

L_rtplusloop:
	push %ebp
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %ebp	# get loop increment 
	STSP
        movl GlobalRp, %ebx
	add  %eax, %ebx		# get ip and save in edx
	mov  (%ebx), %edx
	add  %eax, %ebx
	mov  (%ebx), %ecx	# get terminal count in ecx
	add  %eax, %ebx
	mov  (%ebx), %eax	# get current loop index
	add  %ebp, %eax         # new loop index
	cmpl $0, %ebp           
	jl plusloop1            # loop inc < 0?

     # positive loop increment
	cmp  %ecx, %eax
	jl plusloop2            # is new loop index < ecx?
	add  %ebp, %ecx
	cmp  %ecx, %eax
	jge plusloop2            # is new index >= ecx + inc?
	pop  %ebp
	LDSP
	xor  %eax, %eax
	UNLOOP
	NEXT

plusloop1:       # negative loop increment
	dec  %ecx
	cmp  %ecx, %eax
	jg plusloop2           # is new loop index > ecx-1?
	add  %ebp, %ecx
	cmp  %ecx, %eax
	jle plusloop2           # is new index <= ecx + inc - 1?
	pop  %ebp
	LDSP
	xor  %eax, %eax
	UNLOOP
	NEXT

plusloop2:
	pop  %ebp
	mov  %eax, (%ebx)
	mov  %edx, %ebp
	LDSP
	xor  %eax, %eax
	NEXT

L_count:
	movl WSIZE(%ebx), %ecx
	xor  %eax, %eax
	movb (%ecx), %al
	incl WSIZE(%ebx)
	mov  %eax, (%ebx)
	DEC_DSP
	xor  %eax, %eax
	NEXT

L_ival:
L_addr:
        inc  %ebp
        mov  (%ebp), %ecx
        addl $WSIZE-1, %ebp
	mov  %ecx, (%ebx)
	DEC_DSP
	NEXT

L_ptr:
	mov  %ebp, %ecx
	inc  %ecx
	mov  (%ecx), %eax
	addl $WSIZE-1, %ecx
	mov  %ecx, %ebp
	mov  (%eax), %eax
	mov  %eax, (%ebx)
	DEC_DSP
	xor  %eax, %eax
	NEXT

L_2val:
L_fval:
        mov  %ebp, %ecx
        inc  %ecx
        DEC_DSP
        mov  (%ecx), %eax
	mov  %eax, (%ebx)
	movl WSIZE(%ecx), %eax
	movl %eax, WSIZE(%ebx)
	DEC_DSP
	addl $2*WSIZE-1, %ecx
	mov  %ecx, %ebp
	xor  %eax, %eax
	NEXT

L_and:
	_AND
	NEXT

L_or:
	_OR
	NEXT

L_not:
	_NOT
	NEXT

L_xor:
	_XOR
	NEXT

L_boolean_query:
        BOOLEAN_QUERY
        NEXT

L_bool_not:
        DUP
        BOOLEAN_QUERY
        CHECK_BOOLEAN
        _NOT
        NEXT

L_bool_and:
        TWO_BOOLEANS
        CHECK_BOOLEAN
        _AND
        NEXT

L_bool_or:
        TWO_BOOLEANS
        CHECK_BOOLEAN
        _OR
        NEXT

L_bool_xor:
        TWO_BOOLEANS
        CHECK_BOOLEAN
        _XOR
        NEXT

L_eq:
	REL_DYADIC sete
	NEXT

L_ne:
	REL_DYADIC setne
	NEXT

L_ult:
	REL_DYADIC setb
	NEXT

L_ugt:
	REL_DYADIC seta
	NEXT

L_lt:
	REL_DYADIC setl
	NEXT

L_gt:
	REL_DYADIC setg
	NEXT

L_le:
	REL_DYADIC setle
	NEXT

L_ge:
	REL_DYADIC setge
	NEXT

L_zeroeq:
	REL_ZERO setz
	NEXT

L_zerone:
	REL_ZERO setnz
	NEXT

L_zerolt:
	REL_ZERO setl
	NEXT

L_zerogt:
	REL_ZERO setg
	NEXT

L_within:                          # stack: a b c
        movl 2*WSIZE(%ebx), %ecx   # ecx = b
	movl WSIZE(%ebx), %eax     # eax = c
	sub  %ecx, %eax            # eax = c - b
	INC2_DSP     
	movl WSIZE(%ebx), %edx     # edx = a
        sub  %ecx, %edx            # edx = a - b
	cmp  %eax, %edx
	movl $0, %eax
	setb %al
	neg  %eax
	movl %eax, WSIZE(%ebx)
	xor  %eax, %eax      
        NEXT

L_deq:
	INC_DSP
	mov  (%ebx), %edx
	INC_DSP
	mov  (%ebx), %ecx
	INC_DSP
	mov  (%ebx), %eax
	sub  %edx, %eax
	INC_DSP
	mov  (%ebx), %edx
	sub  %ecx, %edx
	or   %edx, %eax
	cmpl $0, %eax
	movl $0, %eax
	setz %al
	neg  %eax
	mov  %eax, (%ebx)
	DEC_DSP
	xor  %eax, %eax
	NEXT

L_dzeroeq:
	INC_DSP
	mov  %ebx, %ecx
	mov  (%ebx), %eax
	INC_DSP
	or   (%ebx), %eax
	cmpl $0, %eax
	movl $0, %eax
	setz %al
	neg  %eax
	mov  %eax, (%ebx)
	mov  %ecx, %ebx
	xor  %eax, %eax
	NEXT

L_dzerolt:
	REL_ZERO setl
	INC_DSP
	mov  (%ebx), %eax
	movl %eax, WSIZE(%ebx)
	xor  %eax, %eax
	NEXT

L_dlt:
	DLT
	NEXT

L_dult:	# b = (d1.hi u< d2.hi) OR ((d1.hi = d2.hi) AND (d1.lo u< d2.lo))
	movl $WSIZE, %ecx
	xor  %edx, %edx
	add  %ecx, %ebx
	mov  (%ebx), %eax
	cmpl %eax, 2*WSIZE(%ebx)
	sete %dl
	setb %dh
	add  %ecx, %ebx
	mov  (%ebx), %eax
	add  %ecx, %ebx
	STSP
	add  %ecx, %ebx
	cmpl %eax, (%ebx)
	setb %al
	andb %al, %dl
	orb  %dh, %dl
	xor  %eax, %eax
	movb %dl, %al
	neg  %eax
	mov  %eax, (%ebx)
	LDSP
	xor  %eax, %eax
	NEXT

L_querydup:
	movl WSIZE(%ebx), %eax
	cmpl $0, %eax
	je L_querydupexit
	mov  %eax, (%ebx)
	DEC_DSP
	xor  %eax, %eax
L_querydupexit:
	NEXT

L_dup:
        DUP
        NEXT 

L_drop:
        DROP
        NEXT 

L_swap:
	SWAP
        NEXT

L_over:
	OVER
        NEXT

L_rot:
	push %ebp
        push %ebx
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  %ebx, %ebp
	add  %eax, %ebx
	add  %eax, %ebx
	mov  (%ebx), %ecx
	mov  (%ebp), %edx
	mov  %ecx, (%ebp)
	add  %eax, %ebp
	mov  (%ebp), %ecx
	mov  %edx, (%ebp)
	mov  %ecx, (%ebx)
	xor  %eax, %eax
        pop  %ebx
	pop  %ebp
	NEXT

L_minusrot:
	movl WSIZE(%ebx), %eax
	mov  %eax, (%ebx)
	INC_DSP
	movl WSIZE(%ebx), %eax
	mov  %eax, (%ebx)
	INC_DSP
	movl WSIZE(%ebx), %eax
	mov  %eax, (%ebx)
	movl -2*WSIZE(%ebx), %eax
	movl %eax, WSIZE(%ebx)
	LDSP
	xor  %eax, %eax
	NEXT

L_nip:
         INC_DSP
         mov  (%ebx), %eax
         movl %eax, WSIZE(%ebx)
         xor  %eax, %eax
         NEXT

L_tuck:
        SWAP
        OVER
        NEXT

L_pick:                        
	mov  %ebx, %ecx
	movl WSIZE(%ebx), %eax
	addl $2, %eax
	imul $WSIZE, %eax
	add  %eax, %ecx
	mov  (%ecx), %eax
	movl %eax, WSIZE(%ebx)
	xor  %eax, %eax
	NEXT

L_roll:
	movl $WSIZE, %eax
	add  %eax, %ebx
	STSP
	mov  (%ebx), %eax
	inc  %eax
	push %eax
	push %ebx
	imul $WSIZE, %eax
	add  %eax, %ebx		# addr of item to roll
	mov  (%ebx), %eax
	pop  %ebx
	mov  %eax, (%ebx)
	pop  %eax		# number of cells to copy
	mov  %eax, %ecx
	imul $WSIZE, %eax
	add  %eax, %ebx
	mov  %ebx, %edx		# dest addr
	subl $WSIZE, %ebx	# src addr
rollloop:
	mov  (%ebx), %eax
	subl $WSIZE, %ebx
	xchgl %ebx, %edx
	mov  %eax, (%ebx)
	subl $WSIZE, %ebx
	xchgl %ebx, %edx
	loop rollloop

	LDSP
	xor  %eax, %eax
	ret

L_depth:
	LDSP
	movl BottomOfStack, %eax
	sub  %ebx, %eax
	movl $WSIZE, (%ebx)
	movl $0, %edx
	idivl (%ebx)
	mov  %eax, (%ebx)
	movl $WSIZE, %eax
	subl %eax, GlobalSp
	xor  %eax, %eax
        ret

L_2drop:
	FDROP
        NEXT

L_f2drop:
	FDROP
	FDROP
	NEXT

L_f2dup:
	FOVER
	FOVER
	NEXT

L_2dup:
	TWO_DUP
        NEXT

L_2swap:
	FSWAP	
        NEXT

L_2over:
	FOVER
        NEXT

L_2rot:
	INC_DSP
	mov  %ebx, %ecx
	mov  (%ebx), %edx
	INC_DSP
	mov  (%ebx), %eax
	INC_DSP
	xchgl %edx, (%ebx)
	INC_DSP
	xchgl %eax, (%ebx)
	INC_DSP
	xchgl %edx, (%ebx)
	INC_DSP
	xchgl %eax, (%ebx)
	mov  %ecx, %ebx
	mov  %edx, (%ebx)
	INC_DSP
	mov  %eax, (%ebx)
	LDSP
	xor  %eax, %eax
        NEXT

L_question:
	FETCH
	STSP
	call CPP_dot	
	ret

L_ulfetch:
L_slfetch:
L_fetch:
	FETCH
	NEXT

L_lstore:
L_store:
	STORE
	NEXT

L_afetch:
	FETCH
	NEXT

L_cfetch:
	xor  %eax, %eax
	mov  %ebx, %edx
	addl $WSIZE, %edx
	mov  (%edx), %ecx
	movb (%ecx), %al
	mov  %eax, (%edx)
	xor  %eax, %eax
        NEXT

L_cstore:
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %ecx	# address to store
	add  %eax, %ebx
	mov  (%ebx), %eax	# value to store
	movb %al, (%ecx)
	xor  %eax, %eax
	NEXT

L_swfetch:
	movl WSIZE(%ebx), %ecx
	movw (%ecx), %ax
	cwde
	movl %eax, WSIZE(%ebx)
	xor  %eax, %eax
        NEXT

L_uwfetch:
	movl WSIZE(%ebx), %ecx
	movw (%ecx), %ax
	movl %eax, WSIZE(%ebx)
	xor  %eax, %eax
        NEXT

L_wstore:
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %ecx
	add  %eax, %ebx
	mov  (%ebx), %edx
	movw %dx, (%ecx)
	xor  %eax, %eax
        NEXT

L_sffetch:
	movl $WSIZE, %eax
	mov  %ebx, %ecx
        add  %eax, %ecx
        mov  (%ecx), %ecx
        flds (%ecx)
        fstpl (%ebx)
        sub  %eax, %ebx
	xor  %eax, %eax
        NEXT

L_sfstore:
	movl $WSIZE, %eax
        add  %eax, %ebx
        add  %eax, %ebx
        fldl (%ebx)              # load the f number into NDP
	mov  %ebx, %edx
        sub  %eax, %ebx
        mov  (%ebx), %ebx          # load the dest address
        fstps (%ebx)             # store as single precision float
	mov  %edx, %ebx
        add  %eax, %ebx
	xor  %eax, %eax
        NEXT

L_2fetch:
L_dffetch:
	mov  %ebx, %edx
	INC_DSP
	mov  (%ebx), %ecx
	mov  (%ecx), %eax
	mov  %eax, (%edx)
	addl $WSIZE, %ecx
	mov  (%ecx), %eax
	mov  %eax, (%ebx)
	subl $WSIZE, %edx
	mov  %edx, %ebx
	xor  %eax, %eax
	NEXT

L_2store:
L_dfstore:
	movl $WSIZE, %edx
	add  %edx, %ebx
	mov  %ebx, %eax
	mov  (%ebx), %ebx  # address to store
	add  %edx, %eax
	mov  (%eax), %ecx
	mov  %ecx, (%ebx)
	add  %edx, %eax
	add  %edx, %ebx
	mov  (%eax), %ecx
	mov  %ecx, (%ebx)
	mov  %eax, %ebx
	xor  %eax, %eax
	NEXT

L_abs:
	_ABS
	NEXT

L_max:
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %eax
	movl WSIZE(%ebx), %ecx
	cmp  %eax, %ecx
	jl max1
	movl %ecx, WSIZE(%ebx)
	jmp maxexit
max1:
	movl %eax, WSIZE(%ebx)
maxexit:
	xor  %eax, %eax
        NEXT

L_min:
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %eax
	movl WSIZE(%ebx), %ecx
	cmp  %eax, %ecx
	jg min1
	movl %ecx, WSIZE(%ebx)
	jmp minexit
min1:
	movl %eax, WSIZE(%ebx)
minexit:
	xor  %eax, %eax
        NEXT

L_stod:
        STOD
        NEXT

L_dmax:
	FOVER
	FOVER
	DLT
	DROP
	mov  (%ebx), %eax
	cmpl $0, %eax
	jne dmin1
	FDROP
	xor  %eax, %eax
	NEXT

L_dmin:
	FOVER
	FOVER
	DLT
	DROP
	mov  (%ebx), %eax
	cmpl $0, %eax
	je dmin1
	FDROP
	xor  %eax, %eax
	NEXT

dmin1:
	FSWAP
	FDROP
	xor %eax, %eax
	NEXT

#  L_dtwostar and L_dtwodiv are valid for two's-complement systems 
L_dtwostar:
        INC_DSP
        movl WSIZE(%ebx), %eax
        mov  %eax, %ecx
        sall $1, %eax
        movl %eax, WSIZE(%ebx)
        shrl $31, %ecx
        mov  (%ebx), %eax
        sall $1, %eax
        or   %ecx, %eax
        mov  %eax, (%ebx)
        DEC_DSP
        xor  %eax, %eax
        NEXT

L_dtwodiv:
	INC_DSP
	mov  (%ebx), %eax
        mov  %eax, %ecx
        sarl $1, %eax
        mov  %eax, (%ebx)
        shll $31, %ecx
        movl WSIZE(%ebx), %eax
        shrl $1, %eax
        or   %ecx, %eax
        movl %eax, WSIZE(%ebx)
        DEC_DSP
        xor  %eax, %eax
        NEXT

L_add:
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %eax
	addl %eax, WSIZE(%ebx)
        xor  %eax, %eax
        NEXT

L_sub:
        DROP         
        mov  (%ebx), %eax
        subl %eax, WSIZE(%ebx)
        xor  %eax, %eax
        NEXT

L_mul:
        movl $WSIZE, %ecx
        add  %ecx, %ebx
        mov  (%ebx), %eax
        add  %ecx, %ebx
        imull (%ebx)
        mov  %eax, (%ebx)
        sub  %ecx, %ebx
        xor  %eax, %eax
        NEXT

L_starplus:
        INC_DSP
        mov (%ebx), %ecx
        INC_DSP
        mov (%ebx), %eax
        INC_DSP
        imull (%ebx)
        add %ecx, %eax
        mov %eax, (%ebx)
        DEC_DSP
        xor %eax, %eax
        NEXT

L_fsl_mat_addr:
        INC_DSP
        mov (%ebx), %ecx   # ecx = j (column index)
        INC_DSP
        mov (%ebx), %edx   # edx = i (row index)
        mov WSIZE(%ebx), %eax   # adress of first element
        sub $2*WSIZE, %eax # eax = a - 2 cells
        push %edi
        mov %eax, %edi
        mov (%eax), %eax   # eax = ncols
        imull %edx         # eax = i*ncols 
        add %eax, %ecx     # ecx = i*ncols + j 
        mov %edi, %eax
        pop %edi
        add $WSIZE, %eax
        mov (%eax), %eax   # eax = size
        imull %ecx         # eax = size*(i*ncols + j)
        add %eax, WSIZE(%ebx)   # TOS = a + eax
        xor %eax, %eax
        NEXT

L_div:
	INC_DSP
	DIV
        mov %eax, (%ebx)
	DEC_DSP
	xor %eax, %eax
	NEXT

L_mod:
	INC_DSP
	DIV
	mov %edx, (%ebx)
	DEC_DSP
	xor %eax, %eax
	NEXT

L_slashmod:
	INC_DSP
	DIV
	mov %edx, (%ebx)
	DEC_DSP
	mov %eax, (%ebx)
	DEC_DSP
	xor %eax, %eax
	NEXT

L_udivmod:
        INC_DSP
        UDIV
        mov %edx, (%ebx)
        DEC_DSP
        mov %eax, (%ebx)
        DEC_DSP
        xor %eax, %eax
        NEXT

L_starslash:
	STARSLASH	
	NEXT

L_starslashmod:
	STARSLASH
	mov %edx, (%ebx)
	DEC_DSP
	SWAP
	STSP
	ret

L_plusstore:
	movl $WSIZE, %edx
	add  %edx, %ebx
	mov  (%ebx), %ecx
	mov  (%ecx), %eax
	add  %edx, %ebx
	mov  (%ebx), %edx
	add  %edx, %eax
	mov  %eax, (%ecx)
	xor  %eax, %eax
	NEXT

L_dabs:
	LDSP
	mov  %ebx, %edx
	INC_DSP
	mov  (%ebx), %ecx
	mov  %ecx, %eax
	cmpl $0, %eax
	jl dabs_go
	mov  %edx, %ebx
        STSP
	xor  %eax, %eax
	ret
dabs_go:
	INC_DSP
	mov  (%ebx), %eax
	clc
	subl $1, %eax
	not  %eax
	mov  %eax, (%ebx)
	mov  %ecx, %eax
	sbbl $0, %eax
	not  %eax
	movl %eax, -WSIZE(%ebx)
	mov  %edx, %ebx
        STSP
	xor  %eax, %eax
	ret

L_dnegate:
	LDSP
	DNEGATE
        STSP
	ret

L_dplus:
        LDSP
	DPLUS
        STSP
        ret

L_dminus:
	LDSP
	DMINUS
	STSP
	ret

L_umstar:
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %ecx
	add  %eax, %ebx
	mov  %ecx, %eax
	mull (%ebx)
	mov  %eax, (%ebx)
	DEC_DSP
	mov  %edx, (%ebx)
	DEC_DSP
	xor  %eax, %eax				
	NEXT

L_dsstar:
	# multiply signed double and signed to give triple length product
	movl $WSIZE, %ecx
	add  %ecx, %ebx
	mov  (%ebx), %edx
	cmpl $0, %edx
	setl %al
	add  %ecx, %ebx
	mov  (%ebx), %edx
	cmpl $0, %edx
	setl %ah
	xorb %ah, %al      # sign of result
	andl $1, %eax
	push %eax
	LDSP
	_ABS
	INC_DSP
        STSP
	call L_dabs
#	LDSP
	DEC_DSP
	STSP
	call L_udmstar
#	LDSP
	pop  %eax
	cmpl $0, %eax
	jne dsstar1
	NEXT
dsstar1:
	TNEG
	NEXT

L_umslashmod:
# Divide unsigned double length by unsigned single length to
# give unsigned single quotient and remainder. A "Divide overflow"
# error results if the quotient doesn't fit into a single word.
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %ecx
	cmpl $0, %ecx
	jz   E_div_zero
	add  %eax, %ebx
	movl $0, %edx
	mov  (%ebx), %eax
	divl %ecx
	cmpl $0, %eax
	jne E_div_overflow
	mov  (%ebx), %edx
	INC_DSP
	mov  (%ebx), %eax
	divl %ecx	
	mov  %edx, (%ebx)
	DEC_DSP
	mov  %eax, (%ebx)
	DEC_DSP
	xor  %eax, %eax		
	NEXT

L_uddivmod:
# Divide unsigned double length by unsigned single length to
# give unsigned double quotient and single remainder.
        LDSP
        movl $WSIZE, %eax
        add %eax, %ebx
        mov (%ebx), %ecx
        cmpl $0, %ecx
        jz E_div_zero
        add %eax, %ebx
        movl $0, %edx
        mov (%ebx), %eax
        divl %ecx
        push %edi
        mov %eax, %edi  # %edi = hi quot
        INC_DSP
        mov (%ebx), %eax
        divl %ecx
        mov %edx, (%ebx)
        DEC_DSP
        mov %eax, (%ebx)
        DEC_DSP
        mov %edi, (%ebx)
        pop %edi
        DEC_DSP
        STSP
        xor %eax, %eax
        ret

L_mstar:
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  (%ebx), %ecx
	add  %eax, %ebx
	mov  %ecx, %eax
	imull (%ebx)
	mov  %eax, (%ebx)
	DEC_DSP
	mov  %edx, (%ebx)
	DEC_DSP
	xor  %eax, %eax		
	NEXT

L_mplus:
	STOD
	DPLUS
	NEXT

L_mslash:
	movl $WSIZE, %eax
	add  %eax, %ebx
        mov  (%ebx), %ecx
	add  %eax, %ebx
        cmpl $0, %ecx
	je   E_div_zero
        mov  (%ebx), %edx
	add  %eax, %ebx
	mov  (%ebx), %eax
        idivl %ecx
        mov  %eax, (%ebx)
	DEC_DSP
	xor  %eax, %eax		
	NEXT

L_udmstar:
# Multiply unsigned double and unsigned single to give 
# the triple length product.
	LDSP
	INC_DSP
	mov  (%ebx), %ecx
	INC_DSP
	mov  (%ebx), %eax
	mull %ecx
	movl %edx, -WSIZE(%ebx)
	mov  %eax, (%ebx)
	INC_DSP
	mov  %ecx, %eax
	mull (%ebx)
	mov  %eax, (%ebx)
	DEC_DSP
	mov  (%ebx), %eax
	DEC_DSP
	clc
	add  %edx, %eax
	movl %eax, WSIZE(%ebx)
	mov  (%ebx), %eax
	adcl $0, %eax
	mov  %eax, (%ebx)
        DEC_DSP
	xor  %eax, %eax
	ret

L_utsslashmod:
# Divide unsigned triple length by unsigned single length to
# give an unsigned triple quotient and single remainder.
	INC_DSP
	mov  (%ebx), %ecx		# divisor in ecx
	cmpl $0, %ecx
	jz   E_div_zero
	INC_DSP
	mov  (%ebx), %eax		# ut3
	movl $0, %edx
	divl %ecx			# ut3/u
	call utmslash1
	LDSP
	movl WSIZE(%ebx), %eax
	mov  %eax, (%ebx)
	INC_DSP
	movl WSIZE(%ebx), %eax
	mov  %eax, (%ebx)
	INC_DSP	
	movl -17*WSIZE(%ebx), %eax       # r7
	mov  %eax, (%ebx)
	subl $3*WSIZE, %ebx
	movl -5*WSIZE(%ebx), %eax        # q3
	mov  %eax, (%ebx)
	DEC_DSP
	STSP
	xor  %eax, %eax	
	ret

L_tabs:
# Triple length absolute value (needed by L_stsslashrem, STS/REM)
        movl WSIZE(%ebx), %ecx
        mov  %ecx, %eax
        cmpl $0, %eax
        jl tabs1
        xor  %eax, %eax
        ret
tabs1:
        addl $3*WSIZE, %ebx
        mov  (%ebx), %eax
        clc
        subl $1, %eax
        not  %eax
        mov  %eax, (%ebx)
	DEC_DSP
	mov  (%ebx), %eax
	sbbl $0, %eax
	not  %eax
	mov  %eax, (%ebx)
        mov  %ecx, %eax
        sbbl $0, %eax
        not  %eax
        movl %eax, -WSIZE(%ebx)
	subl $2*WSIZE, %ebx
#	STSP
        xor  %eax, %eax
        ret

L_stsslashrem:
# Divide signed triple length by signed single length to give a
# signed triple quotient and single remainder, according to the
# rule for symmetric division.
	INC_DSP
	mov  (%ebx), %ecx		# divisor in ecx
	cmpl $0, %ecx
	jz   E_div_zero
	movl WSIZE(%ebx), %eax		# t3
	push %eax
	cmpl $0, %eax
	movl $0, %eax
	setl %al
	neg  %eax
	mov  %eax, %edx
	cmpl $0, %ecx
	movl $0, %eax
	setl %al
	neg  %eax
	xor  %eax, %edx			# sign of quotient
	push %edx
	call L_tabs
	DEC_DSP
	_ABS
	STSP
	call L_utsslashmod
        LDSP
	pop  %edx
	cmpl $0, %edx
	jz stsslashrem1
	TNEG
stsslashrem1:	
	pop  %eax
	cmpl $0, %eax
	jz stsslashrem2
#	LDSP
	addl $4*WSIZE, %ebx
	negl (%ebx)	
stsslashrem2:
	xor  %eax, %eax
	ret

L_utmslash:
# Divide unsigned triple length by unsigned single to give 
# unsigned double quotient. A "Divide Overflow" error results
# if the quotient doesn't fit into a double word.
	LDSP
	INC_DSP
	mov  (%ebx), %ecx		# divisor in ecx
	cmpl $0, %ecx
	jz   E_div_zero
	INC_DSP
#	movl (%ebx), %eax		# ut3
#	movl $0, %edx
	mov  (%ebx), %edx		# ut3
	movl WSIZE(%ebx), %eax          # ut2
	divl %ecx			# ut3:ut2/u  INT 0 on overflow
#	cmpl $0, %eax
#	jnz  E_div_overflow
	xor  %edx, %edx
	mov  (%ebx), %eax
	divl %ecx
	xor  %eax, %eax
utmslash1:	 
	push %ebx			# keep local stack ptr
	LDSP
	movl %eax, -4*WSIZE(%ebx)	# q3
	movl %edx, -5*WSIZE(%ebx)	# r3
	pop  %ebx
	INC_DSP
	mov  (%ebx), %eax		# ut2
	movl $0, %edx
	divl %ecx			# ut2/u
	push %ebx
	LDSP
	movl %eax, -2*WSIZE(%ebx)	# q2
	movl %edx, -3*WSIZE(%ebx)	# r2
	pop  %ebx
	INC_DSP
	mov  (%ebx), %eax		# ut1
	movl $0, %edx
	divl %ecx			# ut1/u
	push %ebx
	LDSP
	mov  %eax, (%ebx)		# q1
	movl %edx, -WSIZE(%ebx)		# r1
	movl -5*WSIZE(%ebx), %edx	# r3 << 32
	movl $0, %eax
	divl %ecx			# (r3 << 32)/u
	movl %eax, -6*WSIZE(%ebx)	# q4
	movl %edx, -7*WSIZE(%ebx)	# r4
	movl -3*WSIZE(%ebx), %edx	# r2 << 32
	movl $0, %eax
	divl %ecx			# (r2 << 32)/u
	movl %eax, -8*WSIZE(%ebx)	# q5
	movl %edx, -9*WSIZE(%ebx)	# r5
	movl -7*WSIZE(%ebx), %edx	# r4 << 32
	movl $0, %eax
	divl %ecx			# (r4 << 32)/u
	movl %eax, -10*WSIZE(%ebx)	# q6
	movl %edx, -11*WSIZE(%ebx)	# r6
	movl $0, %edx
	movl -WSIZE(%ebx), %eax		# r1
	addl -9*WSIZE(%ebx), %eax	# r1 + r5
	jnc  utmslash2
	inc  %edx
utmslash2:
	addl -11*WSIZE(%ebx), %eax	# r1 + r5 + r6
	jnc  utmslash3
	incl %edx
utmslash3:
	divl %ecx
	movl %eax, -12*WSIZE(%ebx)      # q7
	movl %edx, -13*WSIZE(%ebx)      # r7	
	movl $0, %edx
	addl -10*WSIZE(%ebx), %eax	# q7 + q6
	jnc  utmslash4
	inc  %edx
utmslash4:	
	addl -8*WSIZE(%ebx), %eax	# q7 + q6 + q5
	jnc  utmslash5
	inc  %edx
utmslash5:	
	addl (%ebx), %eax		# q7 + q6 + q5 + q1
	jnc  utmslash6
	inc  %edx
utmslash6:	
	pop  %ebx
	mov  %eax, (%ebx)
	DEC_DSP
	push %ebx
	LDSP
	movl -2*WSIZE(%ebx), %eax	# q2
	addl -6*WSIZE(%ebx), %eax	# q2 + q4
	add  %edx, %eax
	pop  %ebx
	mov  %eax, (%ebx)
	DEC_DSP
	STSP
	xor  %eax, %eax
	ret

L_mstarslash:
	LDSP
	INC_DSP
	movl (%ebx), %eax
        cmpl $0, %eax
        jz E_div_zero
	INC_DSP
        movl (%ebx), %eax
        INC_DSP
	xorl (%ebx), %eax
	shrl $31, %eax
	push %eax	# keep sign of result -- negative is nonzero
	subl $2*WSIZE, %ebx
	_ABS
	INC_DSP
	STSP
	call L_dabs
#	LDSP
	DEC_DSP
	STSP
	call L_udmstar
#	LDSP
	DEC_DSP
	STSP
	call L_utmslash
	LDSP
	pop  %eax
	cmpl $0, %eax
	jnz  mstarslash_neg
	xor  %eax, %eax
	ret
mstarslash_neg:
	DNEGATE
	xor  %eax, %eax
	ret
	
L_fmslashmod:
	movl $WSIZE, %eax
	add  %eax, %ebx
	STSP
	movl (%ebx), %ecx
	cmpl $0, %ecx
	jz   E_div_zero
	add  %eax, %ebx
	movl (%ebx), %edx
	add  %eax, %ebx
	movl (%ebx), %eax
	idivl %ecx
	mov  %edx, (%ebx)
	DEC_DSP
	mov  %eax, (%ebx)
	cmpl $0, %ecx
	jg fmslashmod2
	cmpl $0, %edx
	jg fmslashmod3
	LDSP
	xor  %eax, %eax
	NEXT
fmslashmod2:		
	cmpl $0, %edx
	jge fmslashmodexit
fmslashmod3:	
	dec  %eax		# floor the result
	mov  %eax, (%ebx)
	INC_DSP
	add  %ecx, (%ebx)
fmslashmodexit:
	LDSP
	xor  %eax, %eax
	NEXT

L_smslashrem:
	movl $WSIZE, %eax
	add  %eax, %ebx
	STSP
	movl (%ebx), %ecx
	cmpl $0, %ecx
	jz   E_div_zero
	add  %eax, %ebx
	movl (%ebx), %edx
	add  %eax, %ebx
	movl (%ebx), %eax
	idivl %ecx
	mov  %edx, (%ebx)
	DEC_DSP
	mov  %eax, (%ebx)
	LDSP
	xor  %eax, %eax		
	NEXT

L_stof:
	movl $WSIZE, %eax
	mov  %ebx, %ecx
        add  %eax, %ecx
        fildl (%ecx)
        fstpl (%ebx)
        sub  %eax, %ebx
	xor  %eax, %eax
        NEXT

L_dtof:
	movl $WSIZE, %eax
	movl %ebx, %ecx
	add  %eax, %ecx
	movl (%ecx), %eax
	xchgl WSIZE(%ecx), %eax
	mov  %eax, (%ecx)
        fildq (%ecx)
        fstpl (%ecx)
	xor  %eax, %eax	
	NEXT
	
L_froundtos:
	movl $WSIZE, %eax
        add  %eax, %ebx
	mov  %ebx, %ecx
        fldl (%ecx)
        add  %eax, %ecx
        fistpl (%ecx)
	xor  %eax, %eax
        NEXT

L_ftrunctos:
	movl $WSIZE, %eax
	add  %eax, %ebx
	fldl (%ebx)
	fnstcw (%ebx)
	movl (%ebx), %ecx	# save NDP control word		
	mov  %ecx, %edx	
	movb $12, %dh
	mov  %edx, (%ebx)
	fldcw (%ebx)
	add  %eax, %ebx	
	fistpl (%ebx)
	sub  %eax, %ebx
	mov  %ecx, (%ebx)
	fldcw (%ebx)		# restore NDP control word
	xor  %eax, %eax	
	NEXT
	
L_ftod:
	movl $WSIZE, %eax
	add  %eax, %ebx
	fldl (%ebx)
	sub  %eax, %ebx
	fnstcw (%ebx)
	movl (%ebx), %ecx	# save NDP control word	
	mov  %ecx, %edx
	movb $12, %dh		
	mov  %edx, (%ebx)
	fldcw (%ebx)
	add  %eax, %ebx	
	fistpq (%ebx)
	sub  %eax, %ebx
	mov  %ecx, (%ebx)
	fldcw (%ebx)		# restore NDP control word
	add  %eax, %ebx 
	movl (%ebx), %eax
	xchgl WSIZE(%ebx), %eax
	mov  %eax, (%ebx)
	LDSP
	xor  %eax, %eax	
	NEXT

L_fne:
	FREL_DYADIC xorb $64 setnz	
	NEXT

L_feq:
	FREL_DYADIC andb $64 setnz
	NEXT

L_flt:
	FREL_DYADIC andb $65 setz
	NEXT

L_fgt:
	FREL_DYADIC andb $1 setnz
	NEXT

L_fle:
	FREL_DYADIC xorb $1 setnz
	NEXT

L_fge:
	FREL_DYADIC andb $65 setnz
	NEXT

L_fzeroeq:
	movl $WSIZE, %eax
	add  %eax, %ebx
	movl (%ebx), %ecx
	mov  %ebx, %edx
	add  %eax, %ebx
	movl (%ebx), %eax
	shll $1, %eax
	or   %ecx, %eax
	movl $0, %eax
	setz %al
	neg  %eax
	mov  %eax, (%ebx)
	mov  %edx, %ebx
	xor  %eax, %eax
	NEXT

L_fzerolt:
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  %ebx, %ecx 
	fldl (%ebx)
	add  %eax, %ebx
	fldz
	fcompp	
	fnstsw %ax
	andb $69, %ah
	movl $0, %eax
	setz %al
	neg  %eax
	mov  %eax, (%ebx)
	mov  %ecx, %ebx
	xor  %eax, %eax
	NEXT

L_fzerogt:
	movl $WSIZE, %eax
	add  %eax, %ebx
	mov  %ebx, %ecx
	fldz
	fldl (%ebx)
	add  %eax, %ebx
	fucompp	
	fnstsw %ax
	sahf 
	movl $0, %eax
	seta %al
	neg  %eax
	mov  %eax, (%ebx)
	mov  %ecx, %ebx
	xor  %eax, %eax
	NEXT

L_fsincos:
	fldl WSIZE(%ebx)
	fsincos
	fstpl -WSIZE(%ebx)
	fstpl WSIZE(%ebx)
	subl $2*WSIZE, %ebx	
	NEXT

L_pi:
#       LDSP
        DEC_DSP
        fldpi
        fstpl (%ebx)
        DEC_DSP
#       STSP
        NEXT

L_fatan2:
#       LDSP
        addl $2*WSIZE, %ebx
        fldl WSIZE(%ebx)
        fldl -WSIZE(%ebx)
        fpatan
        fstpl WSIZE(%ebx)
#       STSP
#       INC2_DTSP
        NEXT

L_fadd:
#       LDSP
        movl $WSIZE, %eax
        add  %eax, %ebx
        fldl (%ebx)
        sall $1, %eax
        add  %eax, %ebx
        faddl (%ebx)
        fstpl (%ebx)
        DEC_DSP
#       STSP
#       INC2_DTSP
        xor  %eax, %eax
        NEXT

L_fsub:
#       LDSP
        movl $3*WSIZE, %eax
        add  %eax, %ebx
        fldl (%ebx)
        subl $WSIZE, %eax
        sub  %eax, %ebx
        fsubl (%ebx)
        add  %eax, %ebx
        fstpl (%ebx)
        DEC_DSP
#       STSP
#       INC2_DTSP
        xor  %eax, %eax
        NEXT

L_fmul:
#       LDSP
        movl $WSIZE, %eax
        add  %eax, %ebx
        fldl (%ebx)
        add  %eax, %ebx
        mov  %ebx, %ecx
        add  %eax, %ebx
        fmull (%ebx)
        fstpl (%ebx)
        mov  %ecx, %ebx
#       STSP
#       INC2_DTSP
        xor  %eax, %eax
        NEXT

L_fdiv:
#       LDSP
        movl $WSIZE, %eax
        add  %eax, %ebx
        fldl (%ebx)
        add  %eax, %ebx
        mov  %ebx, %ecx
        add  %eax, %ebx
        fdivrl (%ebx)
        fstpl (%ebx)
        mov  %ecx, %ebx
#       STSP
#       INC2_DTSP
        xor  %eax, %eax
        NEXT

L_fplusstore:
#       LDSP
        INC_DSP
        movl (%ebx), %ecx
        INC_DSP
        fldl (%ebx)
        INC_DSP
        fldl (%ecx)
        faddp
        fstpl (%ecx)
#       STSP
        NEXT

