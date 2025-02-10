// vm32.s
//
// The assembler portion of kForth 32-bit Virtual Machine
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
.include "vm32-common.s"

	.comm GlobalTp,4,4
	.comm GlobalRtp,4,4
	.comm BottomOfTypeStack,4,4
	.comm BottomOfReturnTypeStack,4,4

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro SWAP
        mov %ebx, %edx
        INC_DSP
	movl (%ebx), %eax
	INC_DSP
	movl (%ebx), %ecx
	movl %eax, (%ebx)
	movl %ecx, -WSIZE(%ebx)
# begin ts
        movl GlobalTp, %ebx
        inc  %ebx
	movb (%ebx), %al
	inc  %ebx
	movb (%ebx), %cl
	movb %al, (%ebx)
	movb %cl, -1(%ebx)
# end ts
        mov  %edx, %ebx
        xor  %eax, %eax
.endm

// Regs: eax, ebx, ecx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro OVER
        movl 2*WSIZE(%ebx), %ecx
        movl %ecx, (%ebx)
	DEC_DSP
# begin ts
        movl GlobalTp, %ecx
        movb 2(%ecx), %al
        movb %al, (%ecx)
        decl GlobalTp
# end ts
        xor  %eax, %eax
.endm

// Regs: ebx, ecx
// In: ebx = DSP
// Out: ebx = DSP
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
	movl (%ebx), %edx
	INC_DSP
	movl (%ebx), %eax
	mov  %ecx, %ebx
	movl %eax, (%ebx)
	DEC_DSP
	movl %edx, (%ebx)
	DEC_DSP
        mov  %ebx, %edx
# begin ts
	movl GlobalTp, %ebx
	inc  %ebx
	movw (%ebx), %ax
	subl $2, %ebx
	movw %ax, (%ebx)
	dec  %ebx
	movl %ebx, GlobalTp
# end ts
        mov  %edx, %ebx
	xor  %eax, %eax
.endm

// Regs: eax
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro FDROP
	INC2_DSP
        INC2_DTSP
.endm

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro FSWAP
	movl $WSIZE, %ecx
	add  %ecx, %ebx
	movl (%ebx), %edx
	add  %ecx, %ebx
	movl (%ebx), %eax
	add  %ecx, %ebx
	xchgl %edx, (%ebx)
	add  %ecx, %ebx
	xchgl %eax, (%ebx)
	sub  %ecx, %ebx
	sub  %ecx, %ebx
	movl %eax, (%ebx)
	sub  %ecx, %ebx
	movl %edx, (%ebx)
        sub  %ecx, %ebx
        mov  %ebx, %ecx     # store DSP
# begin ts
	movl GlobalTp, %ebx
	inc  %ebx
	movw (%ebx), %ax
	addl $2, %ebx
	xchgw %ax, (%ebx)
	subl $2, %ebx
	movw %ax, (%ebx)
# end ts
        mov  %ecx, %ebx      # restore DSP
	xor  %eax, %eax
.endm

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro FOVER
	mov  %ebx, %ecx
	addl $3*WSIZE, %ebx
	movl (%ebx), %edx
	INC_DSP
	movl (%ebx), %eax
	mov  %ecx, %ebx
	movl %eax, (%ebx)
	DEC_DSP
	movl %edx, (%ebx)
	DEC_DSP
	mov %ebx, %ecx      # store DSP
# begin ts
	movl GlobalTp, %ebx
	mov  %ebx, %edx
	addl $3, %ebx
	movw (%ebx), %ax
	mov  %edx, %ebx
	dec  %ebx
	movw %ax, (%ebx)
	dec  %ebx
	movl %ebx, GlobalTp
# end ts
        mov  %ecx, %ebx     # restore DSP
	xor  %eax, %eax	
.endm

// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro PUSH_R
	movl $WSIZE, %eax
	add  %eax, %ebx	
	movl (%ebx), %ecx
	movl GlobalRp, %edx
	movl %ecx, (%edx)
	sub  %eax, %edx
	movl %edx, GlobalRp
        mov  %ebx, %ecx       # save DSP
# begin ts
	movl GlobalTp, %ebx
	inc  %ebx
	movl %ebx, GlobalTp
	movb (%ebx), %al
	movl GlobalRtp, %ebx
	movb %al, (%ebx)
	dec  %ebx
	movl %ebx, GlobalRtp
# end ts
        mov  %ecx, %ebx       # restore DSP
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
	movl (%edx), %ecx
	movl %ecx, (%ebx)
	sub  %eax, %ebx
	mov  %ebx, %ecx    # save DSP
# begin ts
	movl GlobalRtp, %ebx
	inc  %ebx
	movl %ebx, GlobalRtp
	movb (%ebx), %al
	movl GlobalTp, %ebx
	movb %al, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp
# end ts
        mov  %ecx, %ebx    # restore DSP
	xor  %eax, %eax
.endm

// Regs: eax, ebx, ecx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro FETCH op
# begin ts
	movl GlobalTp, %ecx
        movb 1(%ecx), %al
        cmpb $OP_ADDR, %al
        jnz E_not_addr
        movb \op, 1(%ecx)
# end ts
        movl WSIZE(%ebx), %eax	
        movl (%eax), %eax
	movl %eax, WSIZE(%ebx)
	xor %eax, %eax
.endm


// Dyadic Logic operators
// Regs: eax, ebx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP	
.macro LOGIC_DYADIC op
	movl $WSIZE, %eax
	add %eax, %ebx
	movl (%ebx), %eax
        \op %eax, WSIZE(%ebx)
# begin ts
	movl GlobalTp, %eax
	inc %eax
	movl %eax, GlobalTp
	movb $OP_IVAL, 1(%eax)
# end ts
	xor %eax, %eax 
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
	movl (%ebx), %eax
	add  %ecx, %ebx
	cmpl %eax, (%ebx)
	movl $0, %eax
	\setx %al
	neg  %eax
	movl %eax, (%ebx)
        sub  %ecx, %ebx
# begin ts
	movl GlobalTp, %eax
	inc  %eax
	movl %eax, GlobalTp
	movb $OP_IVAL, 1(%eax)
# end ts
	xor %eax, %eax
.endm

// Relational operators for zero (single length numbers)
// Regs: eax, ebx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro REL_ZERO setx
	INC_DSP
	movl (%ebx), %eax
	cmpl $0, %eax
	movl $0, %eax
	\setx %al
	neg  %eax
	movl %eax, (%ebx)
        DEC_DSP
# begin ts
	movl GlobalTp, %eax
	movb $OP_IVAL, 1(%eax)
# end ts
	xor %eax, %eax
.endm

// Regs: eax, ebx, ecx
// In: none
// Out: eax = 0
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
	movl %eax, (%ebx)
        subl %ecx, %ebx
# begin ts
	movl GlobalTp, %eax
	addl $3, %eax
	movl %eax, GlobalTp
	movb $OP_IVAL, 1(%eax)
# end ts
	xor  %eax, %eax
.endm
				
# b = (d1.hi < d2.hi) OR ((d1.hi = d2.hi) AND (d1.lo u< d2.lo))
// Regs: eax, ebx, ecx, edx
// In: none
// Out: eax = 0
.macro DLT
	movl $WSIZE, %ecx
	xor  %edx, %edx
	add  %ecx, %ebx
	movl (%ebx), %eax
	cmpl %eax, 2*WSIZE(%ebx)
	sete %dl
	setl %dh
	add  %ecx, %ebx
	movl (%ebx), %eax
	add  %ecx, %ebx
	add  %ecx, %ebx
	cmpl %eax, (%ebx)
	setb %al
	andb %al, %dl
	orb  %dh, %dl
	xor  %eax, %eax
	movb %dl, %al
	negl %eax
	movl %eax, (%ebx)
        sub  %ecx, %ebx
# begin ts
	movl GlobalTp, %eax
	addl $4, %eax
	movb $OP_IVAL, (%eax)
	decl %eax
	movl %eax, GlobalTp
# end ts
	xor  %eax, %eax
.endm

# b = (d1.hi > d2.hi) OR ((d1.hi = d2.hi) AND (d1.lo u> d2.lo))
// Regs: eax, ebx, ecx, edx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro DGT
	movl $WSIZE, %ecx
	xor  %edx, %edx
	add  %ecx, %ebx
	movl (%ebx), %eax
	cmpl %eax, 2*WSIZE(%ebx)
	sete %dl
	setl %dh
	add  %ecx, %ebx
	movl (%ebx), %eax
	add  %ecx, %ebx
	add  %ecx, %ebx
	cmpl %eax, (%ebx)
	setb %al
	andb %al, %dl
	orb  %dh, %dl
	xorl %eax, %eax
	movb %dl, %al
	neg  %eax
	movl %eax, (%ebx)
        sub  %ecx, %ebx
# begin ts
	movl GlobalTp, %eax
	addl $4, %eax
	movb $OP_IVAL, (%eax)
	dec  %eax
	movl %eax, GlobalTp
# end ts
	xor  %eax, %eax
.endm

// Regs: eax, ebx, ecx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro BOOLEAN_QUERY
        DUP
        REL_ZERO setz
        SWAP
        movl $TRUE, (%ebx)
        DEC_DSP
        DEC_DTSP
        REL_DYADIC sete
        _OR
.endm

// Regs: eax, ebx, ecx
// In: ebx = DSP
// Out: eax = 0, ebx = DSP
.macro TWO_BOOLEANS
        TWO_DUP
        BOOLEAN_QUERY
        SWAP
        BOOLEAN_QUERY
        _AND
.endm

// Regs: ebx
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
        mov   %esp, %ebp
        movl  20(%ebp), %ebp     # load the Forth instruction pointer
        movl  %ebp, GlobalIp
	movl  GlobalRp, %eax
	movl  %eax, vmEntryRp
	xor   %eax, %eax
next:
        movb (%ebp), %al         # get the opcode
	movl JumpTable(,%eax,4), %ebx	# machine code address of word
	xor  %eax, %eax          # clear error code
	call *%ebx		 # call the word
	movl GlobalIp, %ebp      # resync ip (possibly changed in call)
	inc  %ebp		 # increment the Forth instruction ptr
	movl %ebp, GlobalIp
	cmpl $0, %eax		 # check for error
	jz next        
exitloop:
        cmpl $OP_RET, %eax       # return from vm?
        jnz vmexit
        xor %eax, %eax           # clear the error
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
        incl GlobalRtp	
	movl GlobalRtp, %ebx
	movb (%ebx), %al
        cmpb $OP_ADDR, %al
        jnz  E_ret_stk_corrupt
	movl (%ecx), %eax
	movl %eax, GlobalIp		# reset the instruction ptr
        xor  %eax, %eax
retexit:
        ret

# L_tobody:
#	LDSP
#	INC_DSP
#	movl (%ebx), %ecx	# code address
#	incl %ecx		# the data address is offset by one
#	movl (%ecx), %ecx
#	movl %ecx, (%ebx)
#	ret
#
L_jz:
        LDSP
        DROP
        STSP
        movl (%ebx), %eax
        cmpl $0, %eax
        jz jz1
        movl $4, %eax
        add  %eax, %ebp       # do not jump
        xor  %eax, %eax
        NEXT
jz1:    mov  %ebp, %ecx
        inc  %ecx
        movl (%ecx), %eax       # get the relative jump count
        dec  %eax
        add  %eax, %ebp
        xor  %eax, %eax
        NEXT

L_vmthrow:      # throw VM error (used as default exception handler)
        LDSP
        DROP
        movl (%ebx), %eax
        STSP
        ret

L_base:
        LDSP
        movl $Base, (%ebx)
        DEC_DSP
        STSP
        STD_ADDR
        NEXT

L_precision:
        LDSP
        movl Precision, %ecx
        movl %ecx, (%ebx)
        DEC_DSP
        STSP
        STD_IVAL
        NEXT

L_setprecision:
        LDSP
        DROP
        STSP
        movl (%ebx), %ecx
        movl %ecx, Precision
        NEXT

L_false:
        LDSP
        movl $FALSE, (%ebx)
        DEC_DSP
        STSP
        STD_IVAL
        NEXT

L_true:
        LDSP
        movl $TRUE, (%ebx)
        DEC_DSP
        STSP
        STD_IVAL
        NEXT

L_bl:
        LDSP
        movl $32, (%ebx)
        DEC_DSP
        STSP
        STD_IVAL
        NEXT

L_lshift:
        LDSP
        DROP
        STSP
        movl (%ebx), %ecx
        cmp $MAX_SHIFT_COUNT, %ecx
        jbe lshift1
        movl $0, WSIZE(%ebx)
        NEXT
lshift1:
        shll %cl, WSIZE(%ebx)
        NEXT

L_rshift:
        LDSP
        DROP
        STSP
        movl (%ebx), %ecx
        cmp $MAX_SHIFT_COUNT, %ecx
        jbe rshift1
        movl $0, WSIZE(%ebx)
        NEXT
rshift1:
        shrl %cl, WSIZE(%ebx)
        NEXT


# For precision delays, use US or MS instead of USLEEP
# Use USLEEP when task can be put to sleep and reawakened by OS
#
L_usleep:
	addl $WSIZE, GlobalSp
	INC_DTSP
	LDSP
	movl (%ebx), %eax
	push %eax
	call usleep
	pop  %eax
	xor  %eax, %eax
	ret

L_ms:
	LDSP
	movl WSIZE(%ebx), %eax
	imull $1000, %eax
	movl %eax, WSIZE(%ebx)
	call C_usec
	ret

L_fill:
        LDSP
	DROP
	movl WSIZE(%ebx), %ecx
	push %ecx         # byte count
	movl (%ebx), %ecx
	push %ecx         # fill byte
	DROP
	movl GlobalTp, %edx
        inc %edx
	movb (%edx), %al
	cmpb $OP_ADDR, %al
	jz fill2
	addl $2*WSIZE, %esp
	jmp E_not_addr
fill2:	DROP
	movl (%ebx), %eax
	push %eax
	call memset   
	addl $3*WSIZE, %esp
        STSP
	xor %eax, %eax
fillexit:	
	ret

L_erase:
	LDSP
	movl $0, (%ebx)
	DEC_DSP
	STSP
	DEC_DTSP
	call L_fill
	ret

L_blank:
	LDSP
	movl $32, (%ebx)
	DEC_DSP
	STSP
	DEC_DTSP
	call L_fill
	ret

L_move:
        LDSP
        DROP
        movl (%ebx), %eax  # count
        push %eax
	DROP
        movl GlobalTp, %edx
        movb 1(%edx), %al   # verify source is type addr
        cmpb $OP_ADDR, %al
        jz move2
        addl $WSIZE, %esp
        movl $E_NOT_ADDR, %eax
        jmp E_not_addr        
move2:
        movl WSIZE(%ebx), %eax  # src addr
        push %eax
        movb (%edx), %al  
        cmpb $OP_ADDR, %al  # verify dest is type addr
        jz move3
        addl $2*WSIZE, %esp
        movl $E_NOT_ADDR, %eax
        jmp E_not_addr
move3:
	movl (%ebx), %eax  # dest addr
	push %eax
	call memmove
	addl $3*WSIZE, %esp
        DROP
        STSP
	xor %eax, %eax
	NEXT

L_cmove:
	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	movl (%ebx), %ecx		# nbytes in ecx
	cmpl $0, %ecx
	jnz  cmove1
	addl $2*WSIZE, %ebx
	STSP
	addl $3, GlobalTp
	xorl %eax, %eax
	NEXT		
cmove1:	INC_DTSP
	addl %eax, %ebx
	movl (%ebx), %edx		# dest addr in edx
	STSP
	INC_DTSP
	movl GlobalTp, %ebx
	movb (%ebx), %al
	cmpb $OP_ADDR, %al
	jz cmove2
	movl $E_NOT_ADDR, %eax
	ret
cmove2:	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	movl (%ebx), %eax		# src addr in eax
	STSP
	INC_DTSP
	movl GlobalTp, %ebx
	movb (%ebx), %bl
	cmpb $OP_ADDR, %bl
	jz cmove3
	movl $E_NOT_ADDR, %eax
	ret
cmove3:	movl %eax, %ebx			# src addr in ebx
cmoveloop: movb (%ebx), %al
	movb %al, (%edx)
	incl %ebx
	incl %edx
	loop cmoveloop
	xor %eax, %eax				
	NEXT				

L_cmovefrom:
	movl $WSIZE, %eax
	addl %eax, GlobalSp
	INC_DTSP
	LDSP
	movl (%ebx), %ecx	# load count register
	addl %eax, GlobalSp
	INC_DTSP
	movl GlobalTp, %ebx
	movb (%ebx), %al
	cmpb $OP_ADDR, %al
	jz cmovefrom2
	movl $E_NOT_ADDR, %eax						
	ret
cmovefrom2:
	LDSP
	movl (%ebx), %ebx
	movl %ecx, %eax
	decl %eax
	addl %eax, %ebx
	movl %ebx, %edx		# dest addr in %edx
	movl $WSIZE, %eax
	addl %eax, GlobalSp
	INC_DTSP
	movl GlobalTp, %ebx
	movb (%ebx), %al
	cmpb $OP_ADDR, %al
	jz cmovefrom3
	movl $E_NOT_ADDR, %eax
	ret
cmovefrom3:
	LDSP
	movl (%ebx), %ebx
	movl %ecx, %eax
	cmpl $0, %eax
	jnz cmovefrom4
	ret
cmovefrom4:	
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
	LDSP
	DROP
        STSP
	movl (%ebx), %ecx
	INC_DSP
	subl %ecx, (%ebx)
	INC_DSP
	addl %ecx, (%ebx)
	NEXT

L_call:
	LDSP
	DROP
        STSP
	jmpl *(%ebx)

L_push_r:
        LDSP
	PUSH_R
        STSP
        NEXT

L_pop_r:
        LDSP
	POP_R
        STSP
	NEXT

L_twopush_r:
	LDSP
	INC_DSP
	movl (%ebx), %edx
	INC_DSP
	movl (%ebx), %eax
	STSP
	movl GlobalRp, %ebx
	movl %eax, (%ebx)
	subl $WSIZE, %ebx
	movl %edx, (%ebx)
	subl $WSIZE, %ebx
	movl %ebx, GlobalRp
	movl GlobalTp, %ebx
	incl %ebx
	movw (%ebx), %ax
	incl %ebx
	movl %ebx, GlobalTp
	movl GlobalRtp, %ebx
	decl %ebx
	movw %ax, (%ebx)
	decl %ebx
	movl %ebx, GlobalRtp
	xor %eax, %eax
	NEXT

L_twopop_r:
	movl GlobalRp, %ebx
	addl $WSIZE, %ebx
	movl (%ebx), %edx
	addl $WSIZE, %ebx
	movl (%ebx), %eax
	movl %ebx, GlobalRp
	LDSP
	movl %eax, (%ebx)
	subl $WSIZE, %ebx
	movl %edx, (%ebx)
	subl $WSIZE, %ebx
	STSP
	movl GlobalRtp, %ebx
	incl %ebx
	movw (%ebx), %ax
	incl %ebx
	movl %ebx, GlobalRtp
	movl GlobalTp, %ebx
	decl %ebx
	movw %ax, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp
	xor %eax, %eax				
	NEXT

L_puship:
        movl %ebp, %eax
        movl GlobalRp, %ebx
        mov %eax, (%ebx)
	movl $WSIZE, %eax
        subl %eax, GlobalRp
        movl GlobalRtp, %ebx
	movb $OP_ADDR, %al
        movb %al, (%ebx)
	decl GlobalRtp
        xor %eax, %eax
        NEXT

L_execute_bc:
        movl %ebp, %ecx
        movl GlobalRp, %ebx
        movl %ecx, (%ebx)
        movl $WSIZE, %eax
        subl %eax, %ebx
        movl %ebx, GlobalRp
        movl GlobalRtp, %ebx
        movb $OP_ADDR, (%ebx)
        decl %ebx
        movl %ebx, GlobalRtp
        LDSP
        addl %eax, %ebx
        STSP
        movl (%ebx), %eax
        decl %eax
        movl %eax, %ebp
        INC_DTSP
        xor %eax, %eax
        NEXT

L_execute:	
        movl %ebp, %ecx
        movl GlobalRp, %ebx
        movl %ecx, (%ebx)
	movl $WSIZE, %eax 
        subl %eax, %ebx 
	movl %ebx, GlobalRp
        movl GlobalRtp, %ebx
	movb $OP_ADDR, (%ebx)
	decl %ebx
        movl %ebx, GlobalRtp
	LDSP
        addl %eax, %ebx
	STSP
        movl (%ebx), %eax
	movl (%eax), %eax
	decl %eax
	movl %eax, %ebp
	INC_DTSP
        xor %eax, %eax
        NEXT

L_definition:
        movl %ebp, %ebx
	movl $WSIZE, %eax
	incl %ebx
	movl (%ebx), %ecx # address to execute
	addl $WSIZE-1, %ebx
	movl %ebx, %edx
	movl GlobalRp, %ebx
	movl %edx, (%ebx)
	subl %eax, %ebx
	movl %ebx, GlobalRp
	movl GlobalRtp, %ebx
	movb $OP_ADDR, (%ebx)
	decl %ebx
	movl %ebx, GlobalRtp
	decl %ecx
	movl %ecx, %ebp
        xor %eax, %eax	
	NEXT
L_rfetch:
        movl GlobalRp, %ebx
        addl $WSIZE, %ebx
        movl (%ebx), %eax
        LDSP
        movl %eax, (%ebx)
	movl $WSIZE, %eax
        subl %eax, GlobalSp
        movl GlobalRtp, %ebx
        incl %ebx
        movb (%ebx), %al
        movl GlobalTp, %ebx
        movb %al, (%ebx)
        DEC_DTSP
        xor %eax, %eax
	NEXT

L_tworfetch:
	movl GlobalRp, %ebx
	addl $WSIZE, %ebx
	movl (%ebx), %edx
	addl $WSIZE, %ebx
	movl (%ebx), %eax
	LDSP
	movl %eax, (%ebx)
	DEC_DSP
	movl %edx, (%ebx)
	DEC_DSP
	STSP
	movl GlobalRtp, %ebx
	incl %ebx
	movw (%ebx), %ax
	incl %ebx
	movl GlobalTp, %ebx
	decl %ebx
	movw %ax, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp
	xor %eax, %eax				
	NEXT

L_rpfetch:
	LDSP
	movl GlobalRp, %eax
	addl $WSIZE, %eax
	movl %eax, (%ebx)
	DEC_DSP
	STSP
	movl GlobalTp, %ebx
	movb $OP_ADDR, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp
	xor %eax, %eax
	NEXT

L_spfetch:
	movl GlobalSp, %eax
	movl %eax, %ebx
	addl $WSIZE, %eax
	movl %eax, (%ebx)
	DEC_DSP
	STSP
	movl GlobalTp, %ebx
	movb $OP_ADDR, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp
	xor %eax, %eax 
	NEXT

L_i:
        movl GlobalRtp, %ebx
        movb 3(%ebx), %al
        movl GlobalTp, %ebx
	movb %al, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp
        movl GlobalRp, %ebx
        movl 3*WSIZE(%ebx), %eax
        LDSP
        movl %eax, (%ebx)
	movl $WSIZE, %eax
        subl %eax, %ebx 
	STSP
        xor %eax, %eax
        NEXT

L_j:
        movl GlobalRtp, %ebx
        movb 6(%ebx), %al
	movl GlobalTp, %ebx
	movb %al, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp
        movl GlobalRp, %ebx
        movl 6*WSIZE(%ebx), %eax
        LDSP
        movl %eax, (%ebx)
	movl $WSIZE, %eax
        subl %eax, %ebx
	STSP
        xor %eax, %eax
        NEXT

L_rtloop:
        movl GlobalRtp, %ebx
        incl %ebx
        movb (%ebx), %al
        cmpb $OP_ADDR, %al
        jnz  E_ret_stk_corrupt
        movl GlobalRp, %ebx	
	movl $WSIZE, %eax
	addl %eax, %ebx
	movl (%ebx), %edx
	addl %eax, %ebx
	movl (%ebx), %ecx
	addl %eax, %ebx
        movl (%ebx), %eax
        incl %eax
	cmpl %ecx, %eax	
        jz L_rtunloop
        movl %eax, (%ebx)	# set loop counter to next value
	movl %edx, %ebp		# set instruction ptr to start of loop
        xorl %eax, %eax
        NEXT

L_rtunloop:
	UNLOOP
	xorl %eax, %eax
        NEXT

L_rtplusloop:
	pushl %ebp
	movl GlobalRtp, %ebx
        incl %ebx
        movb (%ebx), %al
        cmpb $OP_ADDR, %al
        jnz  E_ret_stk_corrupt
	movl $WSIZE, %eax
	LDSP
	addl %eax, %ebx
	movl (%ebx), %ebp	# get loop increment 
	STSP
	INC_DTSP		
        movl GlobalRp, %ebx
	addl %eax, %ebx		# get ip and save in edx
	movl (%ebx), %edx
	addl %eax, %ebx
	movl (%ebx), %ecx	# get terminal count in ecx
	addl %eax, %ebx
	movl (%ebx), %eax	# get current loop index
	addl %ebp, %eax         # new loop index
	cmpl $0, %ebp           
	jl plusloop1            # loop inc < 0?

     # positive loop increment
	cmpl %ecx, %eax
	jl plusloop2            # is new loop index < ecx?
	addl %ebp, %ecx
	cmpl %ecx, %eax
	jge plusloop2            # is new index >= ecx + inc?
	popl %ebp
	xorl %eax, %eax
	UNLOOP
	NEXT

plusloop1:       # negative loop increment
	decl %ecx
	cmpl %ecx, %eax
	jg plusloop2           # is new loop index > ecx-1?
	addl %ebp, %ecx
	cmpl %ecx, %eax
	jle plusloop2           # is new index <= ecx + inc - 1?
	popl %ebp
	xorl %eax, %eax
	UNLOOP
	NEXT

plusloop2:
	popl %ebp
	movl %eax, (%ebx)
	movl %edx, %ebp
	xorl %eax, %eax
	NEXT

L_count:
	movl GlobalTp, %ebx
	movb 1(%ebx), %al
	cmpb $OP_ADDR, %al
	jnz  E_not_addr
	movb $OP_IVAL, (%ebx)
	DEC_DTSP
	LDSP
	movl WSIZE(%ebx), %ebx
	xor %eax, %eax
	movb (%ebx), %al
	LDSP
	incl WSIZE(%ebx)
	movl %eax, (%ebx)
	movl $WSIZE, %eax
	subl %eax, GlobalSp
	xor %eax, %eax
	NEXT

L_ival:
	LDSP
        inc %ebp
        movl (%ebp), %ecx
        addl $WSIZE-1, %ebp
	movl %ecx, (%ebx)
	DEC_DSP
	STSP
	STD_IVAL
	NEXT

L_addr:
	LDSP
        inc %ebp
        movl (%ebp), %ecx
        addl $WSIZE-1, %ebp
	movl %ecx, (%ebx)
	DEC_DSP
	STSP
	STD_ADDR
	NEXT

L_ptr:
	LDSP
	movl %ebp, %ecx
	incl %ecx
	movl (%ecx), %eax
	addl $WSIZE-1, %ecx
	movl %ecx, %ebp
	movl (%eax), %eax
	movl %eax, (%ebx)
	DEC_DSP
	STSP
	STD_ADDR
	xorl %eax, %eax
	NEXT

L_2val:
L_fval:
        movl %ebp, %ebx
        incl %ebx
        movl GlobalSp, %ecx
        subl $WSIZE, %ecx
        movl (%ebx), %eax
	movl %eax, (%ecx)
	movl WSIZE(%ebx), %eax
	movl %eax, WSIZE(%ecx)
	subl $WSIZE, %ecx
	movl %ecx, GlobalSp
	addl $2*WSIZE-1, %ebx
	movl %ebx, %ebp
	movl GlobalTp, %ebx
	movb $OP_IVAL, (%ebx)
	decl %ebx
	movb $OP_IVAL, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp
	xor %eax, %eax
	NEXT

L_and:
        LDSP
	_AND
        STSP
	NEXT

L_or:
        LDSP
	_OR
        STSP
	NEXT

L_not:
        LDSP
	_NOT
        NEXT

L_xor:
        LDSP
	_XOR
        STSP
	NEXT

L_boolean_query:
        LDSP
	BOOLEAN_QUERY
        STSP
        NEXT

L_bool_not:
        LDSP
        DUP
        BOOLEAN_QUERY
        CHECK_BOOLEAN
        _NOT
        STSP
	NEXT

L_bool_and:
        LDSP
        TWO_BOOLEANS
        CHECK_BOOLEAN
        _AND
        STSP
        NEXT

L_bool_or:
        LDSP
        TWO_BOOLEANS
        CHECK_BOOLEAN
        _OR
        STSP
        NEXT

L_bool_xor:
        LDSP
        TWO_BOOLEANS
        CHECK_BOOLEAN
        _XOR
        STSP
        NEXT

L_eq:
        LDSP
	REL_DYADIC sete
        STSP
	NEXT

L_ne:
        LDSP
	REL_DYADIC setne
        STSP
	NEXT

L_ult:
        LDSP
	REL_DYADIC setb
        STSP
	NEXT

L_ugt:
        LDSP
	REL_DYADIC seta
        STSP
	NEXT

L_lt:
        LDSP
	REL_DYADIC setl
        STSP
	NEXT

L_gt:
        LDSP
	REL_DYADIC setg
        STSP
	NEXT

L_le:
        LDSP
	REL_DYADIC setle
        STSP
	NEXT

L_ge:
        LDSP
	REL_DYADIC setge
        STSP
	NEXT

L_zeroeq:
        LDSP
	REL_ZERO setz
	NEXT

L_zerone:
        LDSP
	REL_ZERO setnz
	NEXT

L_zerolt:
        LDSP
	REL_ZERO setl
	NEXT

L_zerogt:
        LDSP
	REL_ZERO setg
	NEXT

L_within:
        LDSP                       # stack: a b c 
        movl 2*WSIZE(%ebx), %ecx   # ecx = b
	movl WSIZE(%ebx), %eax     # eax = c
	subl %ecx, %eax            # eax = c - b
	INC_DSP     
	INC_DSP
	movl WSIZE(%ebx), %edx     # edx = a
        subl %ecx, %edx            # edx = a - b
	cmpl %eax, %edx
	movl $0, %eax
	setb %al
	negl %eax
	movl %eax, WSIZE(%ebx)
	STSP
	movl GlobalTp, %ebx
	addl $3, %ebx
	movb $OP_IVAL, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp
	xorl %eax, %eax
        NEXT

L_deq:
	movl GlobalTp, %ebx
	addl $4, %ebx
	movb $OP_IVAL, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp
	LDSP
	INC_DSP
	movl (%ebx), %edx
	INC_DSP
	movl (%ebx), %ecx
	INC_DSP
	STSP
	movl (%ebx), %eax
	subl %edx, %eax
	INC_DSP
	movl (%ebx), %edx
	subl %ecx, %edx
	orl %edx, %eax
	cmpl $0, %eax
	movl $0, %eax
	setz %al
	negl %eax
	movl %eax, (%ebx)
	xorl %eax, %eax
	NEXT

L_dzeroeq:
	movl GlobalTp, %ebx
	addl $2, %ebx
	movb $OP_IVAL, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp
	LDSP
	INC_DSP
	STSP
	movl (%ebx), %eax
	INC_DSP
	orl (%ebx), %eax
	cmpl $0, %eax
	movl $0, %eax
	setz %al
	negl %eax
	movl %eax, (%ebx)
	xorl %eax, %eax
	NEXT

L_dzerolt:
        LDSP
	REL_ZERO setl
        INC_DSP
	movl (%ebx), %eax
	movl %eax, WSIZE(%ebx)
	STSP
	INC_DTSP
	xor %eax, %eax
	NEXT	

L_dlt:
        LDSP	
	DLT
        STSP
	NEXT

L_dult:	# b = (d1.hi u< d2.hi) OR ((d1.hi = d2.hi) AND (d1.lo u< d2.lo)) 
	LDSP
	movl $WSIZE, %ecx
	xorl %edx, %edx
	addl %ecx, %ebx
	movl (%ebx), %eax
	cmpl %eax, 2*WSIZE(%ebx)
	sete %dl
	setb %dh
	addl %ecx, %ebx
	movl (%ebx), %eax
	addl %ecx, %ebx
	STSP
	addl %ecx, %ebx
	cmpl %eax, (%ebx)
	setb %al
	andb %al, %dl
	orb  %dh, %dl
	xorl %eax, %eax
	movb %dl, %al
	negl %eax
	movl %eax, (%ebx)
	movl GlobalTp, %eax
	addl $4, %eax
	movb $OP_IVAL, (%eax)
	decl %eax
	movl %eax, GlobalTp
	xorl %eax, %eax
	NEXT
	
L_querydup:
	LDSP
	movl WSIZE(%ebx), %eax
	cmpl $0, %eax
	je L_querydupexit
	movl %eax, (%ebx)
	DEC_DSP
	STSP
	movl GlobalTp, %ebx
	movb 1(%ebx), %al
	movb %al, (%ebx)
	DEC_DTSP
	xor %eax, %eax
L_querydupexit:
	NEXT

L_dup:
        LDSP
        DUP
        STSP
        NEXT 

L_drop:
        LDSP 
        DROP
        STSP
        NEXT 

L_swap:
        LDSP
	SWAP
        STSP
        NEXT

L_over:
        LDSP
	OVER
        STSP
        NEXT

L_rot:
	pushl %ebp
	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	movl %ebx, %ebp
	addl %eax, %ebx
	addl %eax, %ebx
	movl (%ebx), %ecx
	movl (%ebp), %edx
	movl %ecx, (%ebp)
	addl %eax, %ebp
	movl (%ebp), %ecx
	movl %edx, (%ebp)
	movl %ecx, (%ebx)
        movl GlobalTp, %ebx
        incl %ebx
	movl %ebx, %ebp
	movw (%ebx), %cx
	addl $2, %ebx
	movb (%ebx), %al
	movb %al, (%ebp)
	incl %ebp
	movw %cx, (%ebp)
	xor %eax, %eax
	popl %ebp
	NEXT

L_minusrot:
	LDSP
	movl WSIZE(%ebx), %eax
	movl %eax, (%ebx)
	INC_DSP
	movl WSIZE(%ebx), %eax
	movl %eax, (%ebx)
	INC_DSP
	movl WSIZE(%ebx), %eax
	movl %eax, (%ebx)
	movl -2*WSIZE(%ebx), %eax
	movl %eax, WSIZE(%ebx)
	movl GlobalTp, %ebx
	movb 1(%ebx), %al
	movb %al, (%ebx)
	incl %ebx
	movw 1(%ebx), %ax
	movw %ax, (%ebx)
	movb -1(%ebx), %al
	movb %al, 2(%ebx)
	xor %eax, %eax
	NEXT

L_nip:
        LDSP
        INC_DSP
        movl (%ebx), %eax
        movl %eax, WSIZE(%ebx)
        STSP
        movl GlobalTp, %ebx
        incl %ebx
        movb (%ebx), %al
        movb %al, 1(%ebx)
        movl %ebx, GlobalTp
        xor %eax, %eax
        NEXT

L_tuck:
        LDSP
        SWAP
        OVER
        STSP
        NEXT

L_pick:
	LDSP
	addl $WSIZE, %ebx
	movl %ebx, %edx
	movl (%ebx), %eax
	incl %eax
	movl %eax, %ecx
	imul $WSIZE, %eax
	addl %eax, %ebx
	movl (%ebx), %eax
	movl %edx, %ebx
	movl %eax, (%ebx)
	movl GlobalTp, %ebx
	incl %ebx
	movl %ebx, %edx
	addl %ecx, %ebx
	movb (%ebx), %al
	movl %edx, %ebx
	movb %al, (%ebx)
	xor %eax, %eax
	NEXT

L_roll:
	movl $WSIZE, %eax
	addl %eax, GlobalSp
	INC_DTSP
	LDSP 
	movl (%ebx), %eax
	incl %eax
	pushl %eax
	pushl %eax
	pushl %eax
	pushl %ebx
	imul $WSIZE, %eax
	addl %eax, %ebx		# addr of item to roll
	movl (%ebx), %eax
	popl %ebx
	movl %eax, (%ebx)
	popl %eax		# number of cells to copy
	movl %eax, %ecx
	imul $WSIZE, %eax
	addl %eax, %ebx
	movl %ebx, %edx		# dest addr
	subl $WSIZE, %ebx	# src addr
rollloop:
	movl (%ebx), %eax
	sub $WSIZE, %ebx
	xchgl %ebx, %edx
	movl %eax, (%ebx)
	sub $WSIZE, %ebx
	xchgl %ebx, %edx
	loop rollloop

	popl %eax		# now we have to roll the typestack
	mov GlobalTp, %ebx	
	addl %eax, %ebx
	movb (%ebx), %al
	movl GlobalTp, %ebx
	movb %al, (%ebx)
	popl %eax
	movl %eax, %ecx
	addl %eax, %ebx
	movl %ebx, %edx
	decl %ebx
rolltloop:
	movb (%ebx), %al
	decl %ebx
	xchgl %ebx, %edx
	movb %al, (%ebx)
	decl %ebx
	xchgl %ebx, %edx
	loop rolltloop
	xor %eax, %eax
	ret

L_depth:
	LDSP
	movl BottomOfStack, %eax
	subl %ebx, %eax
	movl $WSIZE, (%ebx)
	movl $0, %edx
	idivl (%ebx)
	movl %eax, (%ebx)
	movl $WSIZE, %eax
	subl %eax, GlobalSp
	STD_IVAL
	xorl %eax, %eax
        ret

L_2drop:
        LDSP
	FDROP
        STSP
        NEXT

L_f2drop:
        LDSP
	FDROP
	FDROP
        STSP
	NEXT

L_f2dup:
        LDSP
        FOVER
	FOVER
        STSP
	NEXT

L_2dup:
        LDSP
	TWO_DUP
        STSP
        NEXT

L_2swap:
        LDSP
	FSWAP
        STSP	
        NEXT

L_2over:
        LDSP
	FOVER
        STSP
        NEXT

L_2rot:
	LDSP
	INC_DSP
	movl %ebx, %ecx
	movl (%ebx), %edx
	INC_DSP
	movl (%ebx), %eax
	INC_DSP
	xchgl %edx, (%ebx)
	INC_DSP
	xchgl %eax, (%ebx)
	INC_DSP
	xchgl %edx, (%ebx)
	INC_DSP
	xchgl %eax, (%ebx)
	movl %ecx, %ebx
	movl %edx, (%ebx)
	addl $WSIZE, %ebx
	movl %eax, (%ebx)
	movl GlobalTp, %ebx
	incl %ebx
	movl %ebx, %ecx
	movw (%ebx), %ax
	addl $2, %ebx
	xchgw %ax, (%ebx)
	addl $2, %ebx
	xchgw %ax, (%ebx)
	movl %ecx, %ebx
	movw %ax, (%ebx)
	xor %eax, %eax
        NEXT

L_question:
        LDSP
	FETCH $OP_IVAL
	call CPP_dot	
	ret
	
L_ulfetch:
L_slfetch:
L_fetch:
        LDSP
	FETCH $OP_IVAL
	NEXT

L_lstore:
L_store:
        movl GlobalTp, %ecx
        movb 1(%ecx), %al
        cmpb $OP_ADDR, %al
        jnz E_not_addr
        INC2_DTSP
	movl $WSIZE, %eax
	LDSP
        addl %eax, %ebx
        movl (%ebx), %ecx	# address to store to in ecx
	addl %eax, %ebx
	movl (%ebx), %edx	# value to store in edx
	STSP
	movl %edx, (%ecx)
	xor %eax, %eax
	NEXT

L_afetch:
        LDSP
	FETCH $OP_ADDR
	NEXT

L_cfetch:
	movl GlobalTp, %ecx
	movb 1(%ecx), %al
	cmpb $OP_ADDR, %al
	jnz E_not_addr
	movb $OP_IVAL, 1(%ecx)
	LDSP
	movl WSIZE(%ebx), %ecx
	movb (%ecx), %al
	movl %eax, WSIZE(%ebx)
	xor %eax, %eax
        NEXT

L_cstore:
	movl GlobalTp, %edx
	incl %edx
	movb (%edx), %al
	cmpb $OP_ADDR, %al
	jnz E_not_addr
	LDSP
	INC_DSP
	movl (%ebx), %ecx	# address to store
	INC_DSP
	movl (%ebx), %eax	# value to store
	movb %al, (%ecx)
	STSP
	incl %edx
	movl %edx, GlobalTp
	xor %eax, %eax
	NEXT	

L_swfetch:
	movl GlobalTp, %ecx
	movb 1(%ecx), %al
	cmpb $OP_ADDR, %al
	jnz E_not_addr
	movb $OP_IVAL, 1(%ecx)
	LDSP
	movl WSIZE(%ebx), %ecx
	movw (%ecx), %ax
	cwde
	movl %eax, WSIZE(%ebx)
	xor %eax, %eax
        NEXT

L_uwfetch:
	movl GlobalTp, %ecx
	movb 1(%ecx), %al
	cmpb $OP_ADDR, %al
	jnz E_not_addr
	movb $OP_IVAL, 1(%ecx)
	LDSP
	movl WSIZE(%ebx), %ecx
	movw (%ecx), %ax
	movl %eax, WSIZE(%ebx)
	xor %eax, %eax
        NEXT

L_wstore:
	movl $WSIZE, %eax
	addl %eax, GlobalSp
	INC_DTSP
	movl GlobalTp, %ecx
	movb (%ecx), %al
	cmpb $OP_ADDR, %al
	jnz E_not_addr
	LDSP
	movl (%ebx), %eax
	pushl %eax
	INC_DSP
	movl (%ebx), %eax
	pop %ebx
	movw %ax, (%ebx)
	movl $WSIZE, %eax
	addl %eax, GlobalSp
	INC_DTSP
	xor %eax, %eax
        NEXT

L_sffetch:
	movl $WSIZE, %eax
        addl %eax, GlobalSp
        INC_DTSP
        movl GlobalTp, %ebx
        movb (%ebx), %al
        cmpb $OP_ADDR, %al
        jnz E_not_addr
        movb $OP_IVAL, (%ebx)
        decl %ebx
        movb $OP_IVAL, (%ebx)
        DEC_DTSP
	DEC_DTSP
        LDSP
        movl (%ebx), %ebx
        flds (%ebx)
	movl $WSIZE, %eax
        subl %eax, GlobalSp
        LDSP
        fstpl (%ebx)
        subl %eax, GlobalSp
	xor %eax, %eax
        NEXT

L_sfstore:
	movl $WSIZE, %eax
        addl %eax, GlobalSp
        INC_DTSP
        movl GlobalTp, %ebx
        movb (%ebx), %al
        cmpb $OP_ADDR, %al
        jnz E_not_addr
        LDSP
        INC_DSP
        fldl (%ebx)              # load the f number into NDP
        DEC_DSP
        movl (%ebx), %ebx          # load the dest address
        fstps (%ebx)             # store as single precision float
	movl $WSIZE, %eax
	sall $1, %eax
        addl %eax, GlobalSp
	INC2_DTSP
	xor %eax, %eax
        NEXT

L_2fetch:
L_dffetch:	
        movl GlobalTp, %ebx
	incl %ebx
        movb (%ebx), %al
        cmpb $OP_ADDR, %al
        jnz E_not_addr
	movb $OP_IVAL, (%ebx)
	decl %ebx
	movb $OP_IVAL, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp 
	LDSP
	movl %ebx, %edx
	INC_DSP
	movl (%ebx), %ecx
	movl (%ecx), %eax
	movl %eax, (%edx)
	addl $WSIZE, %ecx
	movl (%ecx), %eax
	movl %eax, (%ebx)
	subl $WSIZE, %edx
	movl %edx, GlobalSp
	xor %eax, %eax
	NEXT

L_2store:
L_dfstore:
        movl GlobalTp, %ebx
	incl %ebx
        movb (%ebx), %al
        cmpb $OP_ADDR, %al
        jnz  E_not_addr
	addl $2, %ebx
	movl %ebx, GlobalTp
	LDSP
	movl $WSIZE, %edx
	addl %edx, %ebx
	movl %ebx, %eax
	movl (%ebx), %ebx  # address to store
	addl %edx, %eax
	movl (%eax), %ecx
	movl %ecx, (%ebx)
	addl %edx, %eax
	addl %edx, %ebx
	movl (%eax), %ecx
	movl %ecx, (%ebx)
	movl %eax, GlobalSp
	xor %eax, %eax
	NEXT

L_abs:
        LDSP
	_ABS
        NEXT

L_max:
	LDSP
        movl $WSIZE, %eax
        addl %eax, %ebx
        STSP
        INC_DTSP
	movl (%ebx), %eax
	movl WSIZE(%ebx), %ecx
	cmpl %eax, %ecx
	jl max1
	movl %ecx, WSIZE(%ebx)
        xor %eax, %eax
        NEXT
max1:
	movl %eax, WSIZE(%ebx)
	xor %eax, %eax
        NEXT

L_min:
	LDSP
        movl $WSIZE, %eax
        addl %eax, %ebx
        STSP
        INC_DTSP
	movl (%ebx), %eax
	movl WSIZE(%ebx), %ecx
	cmpl %eax, %ecx
	jg min1
	movl %ecx, WSIZE(%ebx)
	xor %eax, %eax
        NEXT
min1:
	movl %eax, WSIZE(%ebx)
	xor %eax, %eax
        NEXT

L_stod:
        LDSP
        STOD
        STSP
        NEXT

L_dmax:
        LDSP
	FOVER
	FOVER
	DLT
	INC_DTSP
#	LDSP
	INC_DSP
	movl (%ebx), %eax
#       STSP
	cmpl $0, %eax
	jne dmin1
	FDROP
        STSP
	xor %eax, %eax
	NEXT

L_dmin:
        LDSP
	FOVER
	FOVER
	DLT
	INC_DTSP
	movl $WSIZE, %ecx
#	LDSP
	add %ecx, %ebx
	movl (%ebx), %eax
	cmpl $0, %eax
	je dmin1
	FDROP
        STSP
	xor %eax, %eax
	NEXT
dmin1:
	FSWAP
	FDROP
        STSP
	xor %eax, %eax
	NEXT

#  L_dtwostar and L_dtwodiv are valid for two's-complement systems
L_dtwostar:
        LDSP
        INC_DSP
        movl WSIZE(%ebx), %eax
        movl %eax, %ecx
        sall $1, %eax
        movl %eax, WSIZE(%ebx)
        shrl $31, %ecx
        movl (%ebx), %eax
        sall $1, %eax
        orl  %ecx, %eax
        movl %eax, (%ebx)
        xorl %eax, %eax
        NEXT

L_dtwodiv:
	LDSP
	INC_DSP
	movl (%ebx), %eax
        movl %eax, %ecx
        sarl $1, %eax
        movl %eax, (%ebx)
        shll $31, %ecx
        movl WSIZE(%ebx), %eax
        shrl $1, %eax
        orl %ecx, %eax
        movl %eax, WSIZE(%ebx)
        xorl %eax, %eax
        NEXT

L_add:
	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	movl (%ebx), %eax
	addl %eax, WSIZE(%ebx)
	STSP
	movl GlobalTp, %ebx
	incl %ebx
	movl %ebx, GlobalTp
	movw (%ebx), %ax
	andb %ah, %al		# and the two types to preserve addr type
	incl %ebx
	movb %al, (%ebx)
        xor %eax, %eax
        NEXT

L_sub:
        LDSP
        DROP         # result will have type of first operand
        movl (%ebx), %eax
        subl %eax, WSIZE(%ebx)
        xor  %eax, %eax
        STSP
        NEXT

L_mul:
        LDSP
        movl $WSIZE, %ecx
        add  %ecx, %ebx
        STSP
        movl (%ebx), %eax
        add  %ecx, %ebx
        imull (%ebx)
        movl %eax, (%ebx)
        INC_DTSP
        xor  %eax, %eax
        NEXT

L_starplus:
        LDSP
        INC_DSP
        mov (%ebx), %ecx
        INC_DSP
        STSP
        mov (%ebx), %eax
        INC_DSP
        imull (%ebx)
        add %ecx, %eax
        mov %eax, (%ebx)
        INC2_DTSP
        xor %eax, %eax
        NEXT

L_fsl_mat_addr:
        LDSP
        INC_DSP
        mov (%ebx), %ecx   # ecx = j (column index)
        INC_DSP
        STSP
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
        INC2_DTSP
        xor %eax, %eax
        NEXT

L_div:
        LDSP
	INC_DSP
        DIV
        movl %eax, (%ebx)
        DEC_DSP
        STSP
        INC_DTSP
	xor %eax, %eax
        NEXT

L_mod:
	LDSP
        INC_DSP
        DIV
	movl %edx, (%ebx)
        DEC_DSP
	STSP
	INC_DTSP
	xor %eax, %eax
	NEXT

L_slashmod:
	LDSP
	INC_DSP
        DIV
	movl %edx, (%ebx)
	DEC_DSP
        movl %eax, (%ebx)
        DEC_DSP
	STSP
        xor %eax, %eax
	NEXT

L_udivmod:
        LDSP
        INC_DSP
        UDIV
        mov %edx, (%ebx)
        DEC_DSP
        mov %eax, (%ebx)
        DEC_DSP
        STSP
        xor %eax, %eax
        NEXT

L_starslash:
        LDSP
	STARSLASH
        STSP	
	NEXT

L_starslashmod:
        LDSP
	STARSLASH
	movl %edx, (%ebx)
	DROP
	SWAP
        STSP
	ret

L_plusstore:
	movl GlobalTp, %ebx
	movb 1(%ebx), %al
	cmpb $OP_ADDR, %al
	jnz  E_not_addr
	LDSP
        INC_DSP
        movl (%ebx), %edx  # edx = addr
        INC_DSP
	movl (%ebx), %eax
	addl %eax, (%edx)
	STSP
	INC2_DTSP
	xor %eax, %eax
	NEXT

L_dabs:
	LDSP
	INC_DSP
	movl (%ebx), %ecx  # high dword
	movl %ecx, %eax
	cmpl $0, %eax
	jl dabs_go
	xor %eax, %eax
	ret
dabs_go:
        INC_DSP
        movl (%ebx), %eax  # low dword
	clc
	subl $1, %eax
	notl %eax
	movl %eax, (%ebx)
	movl %ecx, %eax
	sbbl $0, %eax
	notl %eax
	movl %eax, -WSIZE(%ebx)
	xor %eax, %eax
	ret

L_dnegate:
        LDSP
	DNEGATE	
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
	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	movl (%ebx), %ecx
	addl %eax, %ebx
	movl %ecx, %eax
	mull (%ebx)
	movl %eax, (%ebx)
	DEC_DSP
	movl %edx, (%ebx)
	xor %eax, %eax				
	NEXT

L_dsstar:
	# multiply signed double and signed to give triple length product
	LDSP
	movl $WSIZE, %ecx
	addl %ecx, %ebx
	movl (%ebx), %edx
	cmpl $0, %edx
	setl %al
	addl %ecx, %ebx
	movl (%ebx), %edx
	cmpl $0, %edx
	setl %ah
	xorb %ah, %al      # sign of result
	andl $1, %eax
	pushl %eax
        LDSP
	_ABS
	INC_DSP
	STSP
	INC_DTSP
	call L_dabs
	LDSP
	DEC_DSP
	STSP
	DEC_DTSP
	call L_udmstar
        LDSP
	popl %eax
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
	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	STSP
	movl (%ebx), %ecx
	cmpl $0, %ecx
	jz   E_div_zero
	addl %eax, %ebx
	movl $0, %edx
	movl (%ebx), %eax
	divl %ecx
	cmpl $0, %eax
	jne  E_div_overflow
	movl (%ebx), %edx
	INC_DSP
	movl (%ebx), %eax
	divl %ecx
	movl %edx, (%ebx)
	DEC_DSP
	movl %eax, (%ebx)
	INC_DTSP
	xor %eax, %eax		
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
        xor %eax, %eax
        ret

L_mstar:
	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	movl (%ebx), %ecx
	addl %eax, %ebx
	movl %ecx, %eax
	imull (%ebx)
	movl %eax, (%ebx)
	DEC_DSP
	movl %edx, (%ebx)
	xor %eax, %eax		
	NEXT

L_mplus:
        LDSP
	STOD
	DPLUS
        STSP
	NEXT

L_mslash:
        LDSP
	movl $WSIZE, %eax
        INC_DTSP
	addl %eax, %ebx
        movl (%ebx), %ecx
	INC_DTSP
	addl %eax, %ebx
	STSP
        cmpl $0, %ecx
	je  E_div_zero
        movl (%ebx), %edx
	addl %eax, %ebx
	movl (%ebx), %eax
        idivl %ecx
        movl %eax, (%ebx)
	xor %eax, %eax		
	NEXT

L_udmstar:
# Multiply unsigned double and unsigned single to give 
# the triple length product.
	LDSP
	INC_DSP
	movl (%ebx), %ecx
	INC_DSP
	movl (%ebx), %eax
	mull %ecx
	movl %edx, -WSIZE(%ebx)
	movl %eax, (%ebx)
	INC_DSP
	movl %ecx, %eax
	mull (%ebx)
	movl %eax, (%ebx)
	DEC_DSP
	movl (%ebx), %eax
	DEC_DSP
	clc
	addl %edx, %eax
	movl %eax, WSIZE(%ebx)
	movl (%ebx), %eax
	adcl $0, %eax
	movl %eax, (%ebx)
	xor %eax, %eax 		
	ret

L_utsslashmod:
# Divide unsigned triple length by unsigned single length to
# give an unsigned triple quotient and single remainder.
	LDSP
	INC_DSP
	movl (%ebx), %ecx		# divisor in ecx
	cmpl $0, %ecx
	jz  E_div_zero
	INC_DSP
	movl (%ebx), %eax		# ut3
	movl $0, %edx
	divl %ecx			# ut3/u
	call utmslash1
	LDSP
	movl WSIZE(%ebx), %eax
	movl %eax, (%ebx)
	INC_DSP
	movl WSIZE(%ebx), %eax
	movl %eax, (%ebx)
	INC_DSP	
	movl -17*WSIZE(%ebx), %eax       # r7
	movl %eax, (%ebx)
	subl $3*WSIZE, %ebx
	movl -5*WSIZE(%ebx), %eax        # q3
	movl %eax, (%ebx)
	DEC_DSP
	STSP
	DEC_DTSP
	DEC_DTSP
	xorl %eax, %eax	
	ret

L_tabs:
# Triple length absolute value (needed by L_stsslashrem, STS/REM)
        LDSP
        INC_DSP
        movl (%ebx), %ecx
        movl %ecx, %eax
        cmpl $0, %eax
        jl tabs1
        xor %eax, %eax
        ret
tabs1:
        addl $2*WSIZE, %ebx
        movl (%ebx), %eax
        clc
        subl $1, %eax
        notl %eax
        movl %eax, (%ebx)
	DEC_DSP
	movl (%ebx), %eax
	sbbl $0, %eax
	notl %eax
	movl %eax, (%ebx)
        movl %ecx, %eax
        sbbl $0, %eax
        notl %eax
        movl %eax, -WSIZE(%ebx)
        xor %eax, %eax
        ret

L_stsslashrem:
# Divide signed triple length by signed single length to give a
# signed triple quotient and single remainder, according to the
# rule for symmetric division.
	LDSP
	INC_DSP
        INC_DTSP
	STSP
	movl (%ebx), %ecx		# divisor in ecx
	cmpl $0, %ecx
	jz   E_div_zero
	movl WSIZE(%ebx), %eax		# t3
	pushl %eax
	cmpl $0, %eax
	movl $0, %eax
	setl %al
	negl %eax
	movl %eax, %edx
	cmpl $0, %ecx
	movl $0, %eax
	setl %al
	negl %eax
	xorl %eax, %edx			# sign of quotient
	pushl %edx
	call L_tabs
        LDSP
	DEC_DSP
	DEC_DTSP
	STSP
	_ABS
	call L_utsslashmod
        LDSP
	popl %edx
	cmpl $0, %edx
	jz stsslashrem1
	TNEG
stsslashrem1:	
	popl %eax
	cmpl $0, %eax
	jz stsslashrem2
	addl $4*WSIZE, %ebx
	negl (%ebx)	
stsslashrem2:
	xorl %eax, %eax
	ret

L_utmslash:
# Divide unsigned triple length by unsigned single to give 
# unsigned double quotient. A "Divide Overflow" error results
# if the quotient doesn't fit into a double word.
	LDSP
	INC_DSP
	movl (%ebx), %ecx		# divisor in ecx
	cmpl $0, %ecx
	jz   E_div_zero	
	INC_DSP
#	movl (%ebx), %eax		# ut3
#	movl $0, %edx
	movl (%ebx), %edx               # ut3
	movl WSIZE(%ebx), %eax          # ut2
	divl %ecx			# ut3:ut2/u  INT 0 on overflow
#	cmpl $0, %eax
#	jnz  E_div_overflow
	xor %edx, %edx
	movl (%ebx), %eax
	divl %ecx
	xor %eax, %eax
utmslash1:	
	pushl %ebx			# keep local stack ptr
	LDSP
	movl %eax, -4*WSIZE(%ebx)	# q3
	movl %edx, -5*WSIZE(%ebx)	# r3
	popl %ebx
	INC_DSP
	movl (%ebx), %eax		# ut2
	movl $0, %edx
	divl %ecx			# ut2/u
	pushl %ebx
	LDSP
	movl %eax, -2*WSIZE(%ebx)	# q2
	movl %edx, -3*WSIZE(%ebx)	# r2
	popl %ebx
	INC_DSP
	movl (%ebx), %eax		# ut1
	movl $0, %edx
	divl %ecx			# ut1/u
	pushl %ebx
	LDSP
	movl %eax, (%ebx)		# q1
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
	jnc   utmslash2
	incl %edx
utmslash2:			
	addl -11*WSIZE(%ebx), %eax	# r1 + r5 + r6
	jnc  utmslash3
	incl %edx
utmslash3:
	divl %ecx
	movl %eax, -12*WSIZE(%ebx)	# q7
	movl %edx, -13*WSIZE(%ebx)	# r7
	movl $0, %edx
	addl -10*WSIZE(%ebx), %eax	# q7 + q6
	jnc  utmslash4
	incl %edx
utmslash4:	
	addl -8*WSIZE(%ebx), %eax	# q7 + q6 + q5
	jnc  utmslash5
	incl %edx
utmslash5:	
	addl (%ebx), %eax		# q7 + q6 + q5 + q1
	jnc utmslash6
	incl %edx
utmslash6:
	popl %ebx
	movl %eax, (%ebx)
	DEC_DSP
	pushl %ebx
	LDSP
	movl -2*WSIZE(%ebx), %eax	# q2
	addl -6*WSIZE(%ebx), %eax	# q2 + q4
	addl %edx, %eax
	popl %ebx
	movl %eax, (%ebx)
	DEC_DSP
	STSP
	INC2_DTSP
	xorl %eax, %eax
	ret

L_mstarslash:
	LDSP
	INC_DSP            
        movl (%ebx), %eax  # eax = +n2
        cmpl $0, %eax
        jz E_div_zero
        INC_DSP            
	movl (%ebx), %eax  # eax = n1
	INC_DSP            
	xorl (%ebx), %eax  
	shrl $8*WSIZE-1, %eax  # eax = sign(n1) xor sign(d1)
	pushl %eax	   # keep sign of result -- negative is nonzero
	subl $2*WSIZE, %ebx
	INC_DTSP
	_ABS               # abs(n1)
	INC_DSP           
	STSP               
	INC_DTSP
	call L_dabs
	LDSP
	DEC_DSP            # TOS = +n2
	STSP
	DEC_DTSP
	call L_udmstar
	LDSP
	DEC_DSP
	STSP
	DEC_DTSP
	call L_utmslash
	popl %eax
	cmpl $0, %eax
	jnz mstarslash_neg
	xor %eax, %eax
	ret
mstarslash_neg:
	DNEGATE
	xor %eax, %eax
	ret
		
L_fmslashmod:
	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	STSP
	movl (%ebx), %ecx
	cmpl $0, %ecx
	jz   E_div_zero
	addl %eax, %ebx
	movl (%ebx), %edx
	addl %eax, %ebx
	movl (%ebx), %eax
	idivl %ecx
	movl %edx, (%ebx)
	DEC_DSP
	movl %eax, (%ebx)
	INC_DTSP
	cmpl $0, %ecx
	jg fmslashmod2
	cmpl $0, %edx
	jg fmslashmod3
	xor %eax, %eax
	NEXT
fmslashmod2:		
	cmpl $0, %edx
	jge fmslashmodexit
fmslashmod3:	
	decl %eax		# floor the result
	movl %eax, (%ebx)
	INC_DSP
	addl %ecx, (%ebx)
fmslashmodexit:
	xor %eax, %eax
	NEXT

L_smslashrem:
	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	STSP
	movl (%ebx), %ecx
	cmpl $0, %ecx
	jz   E_div_zero
	addl %eax, %ebx
	movl (%ebx), %edx
	addl %eax, %ebx
	movl (%ebx), %eax
	idivl %ecx
	movl %edx, (%ebx)
	DEC_DSP
	movl %eax, (%ebx)
	INC_DTSP
	xor %eax, %eax
	NEXT

L_stof:
	movl $WSIZE, %eax
        addl %eax, GlobalSp
        INC_DTSP
        LDSP
        fildl (%ebx)
        movl GlobalTp, %ebx
        movb $OP_IVAL, (%ebx)
        decl %ebx
        movb $OP_IVAL, (%ebx)
	DEC_DTSP
	DEC_DTSP
        LDSP
	movl $WSIZE, %eax
        subl %eax, %ebx
        fstpl (%ebx)
	sall $1, %eax
        subl %eax, GlobalSp
	xor %eax, %eax
        NEXT

L_dtof:
        LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	movl (%ebx), %eax
	xchgl WSIZE(%ebx), %eax
	movl %eax, (%ebx)
        fildq (%ebx)
        fstpl (%ebx)
	xor %eax, %eax	
	NEXT	

L_froundtos:
	movl $WSIZE, %eax
        addl %eax, GlobalSp
        LDSP
        fldl (%ebx)
        addl %eax, %ebx
        fistpl (%ebx)
        INC_DTSP
        movl GlobalTp, %ebx
        incl %ebx
        movb $OP_IVAL, (%ebx)
	xor %eax, %eax
        NEXT

L_ftrunctos:
	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	STSP
	fldl (%ebx)
	fnstcw (%ebx)
	movl (%ebx), %ecx	# save NDP control word		
	movl %ecx, %edx	
	movb $12, %dh
	movl %edx, (%ebx)
	fldcw (%ebx)
	addl %eax, %ebx	
	fistpl (%ebx)
	subl %eax, %ebx
	movl %ecx, (%ebx)
	fldcw (%ebx)		# restore NDP control word
	INC_DTSP
	movl GlobalTp, %ebx
	incl %ebx
	movb $OP_IVAL, (%ebx)
	xor %eax, %eax	
	NEXT
	
L_ftod:
	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	fldl (%ebx)
	subl %eax, %ebx
	fnstcw (%ebx)
	movl (%ebx), %ecx	# save NDP control word	
	movl %ecx, %edx
	movb $12, %dh		
	movl %edx, (%ebx)
	fldcw (%ebx)
	addl %eax, %ebx	
	fistpq (%ebx)
	subl %eax, %ebx
	movl %ecx, (%ebx)
	fldcw (%ebx)		# restore NDP control word
	addl %eax, %ebx 
	movl (%ebx), %eax
	xchgl WSIZE(%ebx), %eax
	movl %eax, (%ebx)
	xor %eax, %eax	
	NEXT

L_fne:
        LDSP
	FREL_DYADIC xorb $64 setnz
        STSP
	NEXT
L_feq:
        LDSP
	FREL_DYADIC andb $64 setnz
        STSP
	NEXT
L_flt:
        LDSP
	FREL_DYADIC andb $65 setz
        STSP
	NEXT
L_fgt:
        LDSP
	FREL_DYADIC andb $1 setnz
        STSP
	NEXT	
L_fle:
        LDSP
	FREL_DYADIC xorb $1 setnz
        STSP
	NEXT
L_fge:
        LDSP
	FREL_DYADIC andb $65 setnz
        STSP
	NEXT
L_fzeroeq:
	LDSP
	movl $WSIZE, %eax
	add  %eax, %ebx
	movl (%ebx), %ecx
	STSP
	add  %eax, %ebx
	movl (%ebx), %eax
	shll $1, %eax
	or   %ecx, %eax
	movl $0, %eax
	setz %al
	neg  %eax
	movl %eax, (%ebx)
frelzero:
	movl GlobalTp, %ebx
	incl %ebx
	movl %ebx, GlobalTp
	incl %ebx
	movb $OP_IVAL, (%ebx)
	xor  %eax, %eax
	NEXT
L_fzerolt:
	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	STSP
	fldl (%ebx)
	addl %eax, %ebx
	fldz
	fcompp	
	fnstsw %ax
	andb $69, %ah
	movl $0, %eax
	setz %al
	negl %eax
	movl %eax, (%ebx)
	jmp frelzero
L_fzerogt:
	LDSP
	movl $WSIZE, %eax
	addl %eax, %ebx
	STSP
	fldz
	fldl (%ebx)
	addl %eax, %ebx
	fucompp	
	fnstsw %ax
	sahf 
	movl $0, %eax
	seta %al
	negl %eax
	movl %eax, (%ebx)
	jmp frelzero

L_fsincos:
	LDSP
	fldl WSIZE(%ebx)
	fsincos
	fstpl -WSIZE(%ebx)
	fstpl WSIZE(%ebx)
	subl $2*WSIZE, %ebx
	STSP
	movl GlobalTp, %ebx
	movb $OP_IVAL, (%ebx)
	decl %ebx
	movb $OP_IVAL, (%ebx)
	decl %ebx
	movl %ebx, GlobalTp	
	NEXT

L_pi:
        LDSP
        DEC_DSP
        fldpi
        fstpl (%ebx)
        DEC_DSP
        STSP
        movl GlobalTp, %ebx
        movb $OP_IVAL, (%ebx)
        decl %ebx
        movb $OP_IVAL, (%ebx)
        decl %ebx
        movl %ebx, GlobalTp
        NEXT

L_fatan2:
        LDSP
        addl $2*WSIZE, %ebx
        fldl WSIZE(%ebx)
        fldl -WSIZE(%ebx)
        fpatan
        fstpl WSIZE(%ebx)
        STSP
        INC2_DTSP
        NEXT

L_fadd:
        LDSP
        movl $WSIZE, %eax
        addl %eax, %ebx
        fldl (%ebx)
        sall $1, %eax
        addl %eax, %ebx
        faddl (%ebx)
        fstpl (%ebx)
        DEC_DSP
        STSP
        INC2_DTSP
        xorl %eax, %eax
        NEXT

L_fsub:
        LDSP
        movl $3*WSIZE, %eax
        addl %eax, %ebx
        fldl (%ebx)
        subl $WSIZE, %eax
        subl %eax, %ebx
        fsubl (%ebx)
        addl %eax, %ebx
        fstpl (%ebx)
        DEC_DSP
        STSP
        INC2_DTSP
        xorl %eax, %eax
        NEXT

L_fmul:
        LDSP
        movl $WSIZE, %eax
        addl %eax, %ebx
        fldl (%ebx)
        addl %eax, %ebx
        movl %ebx, %ecx
        addl %eax, %ebx
        fmull (%ebx)
        fstpl (%ebx)
        movl %ecx, %ebx
        STSP
        INC2_DTSP
        xorl %eax, %eax
        NEXT

L_fdiv:
        LDSP
        movl $WSIZE, %eax
        addl %eax, %ebx
        fldl (%ebx)
        addl %eax, %ebx
        movl %ebx, %ecx
        addl %eax, %ebx
        fdivrl (%ebx)
        fstpl (%ebx)
        movl %ecx, %ebx
        STSP
        INC2_DTSP
        xorl %eax, %eax
        NEXT

L_fplusstore:
        movl GlobalTp, %ebx
        inc %ebx
        movb (%ebx), %al
        cmpb $OP_ADDR, %al
        jnz E_not_addr
        movb $OP_IVAL, (%ebx)
        inc %ebx
        movb $OP_IVAL, (%ebx)
        inc %ebx
        movb $OP_IVAL, (%ebx)
        movl %ebx, GlobalTp
        LDSP
        INC_DSP
        mov (%ebx), %ecx
        INC_DSP
        fldl (%ebx)
        INC_DSP
        fldl (%ecx)
        faddp
        fstpl (%ecx)
        STSP
        xor %eax, %eax
        NEXT

