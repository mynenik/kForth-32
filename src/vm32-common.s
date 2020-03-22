// vm32-common.s
//
// Common declarations and data for kForth 32-bit Virtual Machine
//
// Copyright (c) 1998--2020 Krishna Myneni,
//   <krishna.myneni@ccreweb.org>
//
// This software is provided under the terms of the GNU
// Affero General Public License (AGPL), v3.0 or later.
//

.equ WSIZE,	4
.equ TRUE,     -1
.equ FALSE,     0
.equ OP_ADDR,	65
.equ OP_FVAL,	70
.equ OP_IVAL,	73
.equ OP_RET,	238
.equ SIGN_MASK,	0x80000000
	
// Error Codes

.equ E_NOT_ADDR,	1
.equ E_DIV_ZERO,	4
.equ E_RET_STK_CORRUPT,	5
.equ E_UNKNOWN_OP,	6
.equ E_DIV_OVERFLOW,   20
	
.data
NDPcw: .int 0
FCONST_180: .double 180.

// Jump table is read-only
.section        .rodata
.align 32
JumpTable: .long L_false, L_true, L_cells, L_cellplus # 0 -- 3
           .long L_dfloats, L_dfloatplus, CPP_case, CPP_endcase  # 4 -- 7
           .long CPP_of, CPP_endof, C_open, C_lseek     # 8 -- 11
           .long C_close, C_read, C_write, C_ioctl # 12 -- 15
           .long L_usleep, L_ms, C_msfetch, C_syscall  # 16 -- 19
           .long L_fill, L_cmove, L_cmovefrom, CPP_dotparen # 20 -- 23
           .long C_bracketsharp, L_nop, C_fsync, C_sharpbracket  # 24 -- 27
           .long C_sharps, CPP_squote, CPP_cr, L_bl    # 28 -- 31
           .long CPP_spaces, L_store, CPP_cquote, C_sharp # 32 -- 35
           .long C_sign, L_mod, L_and, CPP_tick    # 36 -- 39
           .long CPP_lparen, C_hold, L_mul, L_add  # 40 -- 43
           .long L_nop, L_sub, CPP_dot, L_div  # 44 -- 47
           .long L_dabs, L_dnegate, L_umstar, L_umslashmod   # 48 -- 51
           .long L_mstar, L_mplus, L_mslash, L_mstarslash # 52 -- 55
           .long L_fmslashmod, L_smslashrem, CPP_colon, CPP_semicolon # 56 -- 59
           .long L_lt, L_eq, L_gt, L_question      # 60 -- 63
           .long L_fetch, L_addr, L_base, L_call   # 64 -- 67
           .long L_definition, L_erase, L_fval, L_calladdr # 68 -- 71
           .long L_tobody, L_ival, CPP_evaluate, C_key     # 72 -- 75
           .long L_lshift, L_slashmod, L_ptr, CPP_dotr     # 76 -- 79
           .long CPP_ddot, C_keyquery, L_rshift, CPP_dots  # 80 -- 83
           .long C_accept, CPP_char, CPP_bracketchar, C_word  # 84 -- 87
           .long L_starslash, L_starslashmod, CPP_udotr, CPP_lbracket  # 88 -- 91
           .long L_backslash, CPP_rbracket, L_xor, CPP_literal  # 92 -- 95
           .long CPP_queryallot, CPP_allot, L_binary, L_count # 96 -- 99
           .long L_decimal, CPP_emit, CPP_fdot, CPP_cold # 100 -- 103
           .long L_hex, L_i, L_j, CPP_brackettick         # 104 -- 107
           .long CPP_fvariable, L_2store, CPP_find, CPP_constant # 108 -- 111
           .long CPP_immediate, CPP_fconstant, CPP_create, CPP_dotquote  # 112 -- 115
           .long CPP_type, CPP_udot, CPP_variable, CPP_words # 116 -- 119
           .long CPP_does, L_2val, L_2fetch, C_search   # 120 -- 123
           .long L_or, C_compare, L_not, L_move    # 124 -- 127
           .long L_fsin, L_fcos, C_ftan, C_fasin   # 128 -- 131
           .long C_facos, C_fatan, C_fexp, C_fln   # 132 -- 135
           .long C_flog, L_fatan2, L_ftrunc, L_ftrunctos    # 136 -- 139
           .long C_fmin, C_fmax, L_floor, L_fround # 140 -- 143
           .long L_dlt, L_dzeroeq, L_deq, L_twopush_r  # 144 -- 147
           .long L_twopop_r, L_tworfetch, L_stod, L_stof # 148 -- 151
           .long L_dtof, L_froundtos, L_ftod, L_degtorad  # 152 -- 155
           .long L_radtodeg, L_dplus, L_dminus, L_dult   # 156 -- 159
           .long L_inc, L_dec, L_abs, L_neg        # 160 -- 163
           .long L_min, L_max, L_twostar, L_twodiv # 164 -- 167
           .long L_twoplus, L_twominus, L_cfetch, L_cstore  # 168 -- 171
           .long L_swfetch, L_wstore, L_dffetch, L_dfstore  # 172 -- 175
           .long L_sffetch, L_sfstore, L_spfetch, L_plusstore # 176 -- 179
           .long L_fadd, L_fsub, L_fmul, L_fdiv    # 180 -- 183
           .long L_fabs, L_fneg, C_fpow, L_fsqrt   # 184 -- 187
           .long CPP_spstore, CPP_rpstore, L_feq, L_fne  # 188 -- 191
           .long L_flt, L_fgt, L_fle, L_fge        # 192 -- 195
           .long L_fzeroeq, L_fzerolt, L_fzerogt, L_nop # 196 -- 199
           .long L_drop, L_dup, L_swap, L_over     # 200 -- 203
           .long L_rot, L_minusrot, L_nip, L_tuck  # 204 -- 207
           .long L_pick, L_roll, L_2drop, L_2dup   # 208 -- 211
           .long L_2swap, L_2over, L_2rot, L_depth # 212 -- 215
           .long L_querydup, CPP_if, CPP_else, CPP_then # 216 -- 219
           .long L_push_r, L_pop_r, L_puship, L_rfetch # 220 -- 223
           .long L_rpfetch, L_afetch, CPP_do, CPP_leave # 224 -- 227
           .long CPP_querydo, CPP_abortquote, L_jz, L_jnz  # 228 -- 231
           .long L_jmp, L_loop, L_plusloop, L_unloop  # 232 -- 235
           .long L_execute, CPP_recurse, L_ret, L_abort  # 236 -- 239
           .long L_quit, L_ge, L_le, L_ne          # 240 -- 243
           .long L_zeroeq, L_zerone, L_zerolt, L_zerogt # 244 -- 247
           .long L_ult, L_ugt, CPP_begin, CPP_while    # 248 -- 251
           .long CPP_repeat, CPP_until, CPP_again, CPP_bye  # 252 -- 255
	   .long L_utmslash, L_utsslashmod, L_stsslashrem, L_udmstar   # 256 -- 259
	   .long CPP_included, CPP_include, CPP_source, CPP_refill # 260--263
	   .long CPP_state, CPP_allocate, CPP_free, CPP_resize  # 264--267
	   .long L_cputest, L_dsstar, CPP_compilecomma, L_nop   # 268--271
	   .long CPP_postpone, CPP_nondeferred, CPP_forget, C_forth_signal # 272--275
	   .long C_raise, C_setitimer, C_getitimer, C_us2fetch  # 276--279
	   .long C_tofloat, L_fsincos, C_facosh, C_fasinh # 280--283
	   .long C_fatanh, C_fcosh, C_fsinh, C_ftanh   # 284--287
	   .long C_falog, L_dzerolt, L_dmax, L_dmin    # 288--291
	   .long L_dtwostar, L_dtwodiv, CPP_uddot, L_within  # 292--295
	   .long CPP_twoliteral, C_tonumber, C_numberquery, CPP_sliteral   # 296--299
           .long CPP_fliteral, CPP_twovariable, CPP_twoconstant, L_nop     # 300--303
           .long CPP_tofile, CPP_console, L_nop, L_nop            # 304--307
           .long L_nop, L_nop, L_nop, L_blank          # 308--311
           .long L_slashstring, C_trailing, C_parse, L_nop  # 312--315
	   .long L_nop, L_nop, L_nop, L_nop            # 316--319
           .long C_dlopen, C_dlerror, C_dlsym, C_dlclose # 320--323
	   .long C_usec, CPP_alias, C_system, C_chdir    # 324--327
           .long C_timeanddate, L_nop, CPP_wordlist, CPP_forthwordlist  # 328--331
           .long CPP_getcurrent, CPP_setcurrent, CPP_getorder, CPP_setorder  # 332--335
           .long CPP_searchwordlist, CPP_definitions, CPP_vocabulary, L_nop  # 336--339
           .long CPP_only, CPP_also, CPP_order, CPP_previous                 # 340--343
           .long CPP_forth, CPP_assembler, L_nop, L_nop        # 344--347
           .long L_nop, L_nop, CPP_defined, CPP_undefined      # 348--351
           .long L_nop, L_nop, L_nop, L_nop            # 352--355
           .long L_nop, L_nop, L_nop, L_nop            # 356--359
           .long L_precision, L_setprecision, L_nop, CPP_fsdot   # 360--363
	   .long L_nop, L_nop, C_fexpm1, C_flnp1      # 364--367
	   .long L_nop, L_nop, L_f2drop, L_f2dup      # 368--371
           .long L_nop, L_nop, L_nop, L_nop           # 372--375
           .long L_nop, L_nop, L_nop, L_nop           # 376--379
           .long L_nop, L_nop, L_nop, L_nop           # 380--383
           .long L_nop, L_nop, L_nop, L_nop           # 384--387
           .long L_nop, L_nop, L_nop, L_nop           # 388--391
           .long L_nop, L_nop, L_nop, L_nop           # 392--395
           .long L_nop, L_nop, L_nop, L_nop           # 396--399
           .long L_nop, L_nop, L_nop, L_nop           # 400--403   
           .long L_nop, L_uwfetch, L_ulfetch, L_slfetch  # 404--407
           .long L_lstore, L_nop, L_nop, L_nop        # 408--411

.text
	.align 4
.global JumpTable
.global L_initfpu, L_depth, L_quit, L_abort, L_ret
.global L_dabs, L_dplus, L_dminus, L_dnegate
.global L_mstarslash, L_udmstar, L_utmslash

.macro LDSP                      # load stack ptr into ebx reg
  .ifndef __FAST__
        movl GlobalSp, %ebx
  .endif
.endm

.macro STSP
  .ifndef __FAST__
	movl %ebx, GlobalSp
  .endif
.endm

.macro INC_DSP
	addl $WSIZE, %ebx
.endm

.macro DEC_DSP            # decrement DSP by 1 cell; assume DSP in ebx reg
	subl $WSIZE, %ebx
.endm

.macro INC2_DSP           # increment DSP by 2 cells; assume DSP in ebx reg
	addl $2*WSIZE, %ebx
.endm

.macro INC_DTSP
  .ifndef __FAST__
       incl GlobalTp
  .endif
.endm

.macro DEC_DTSP
  .ifndef __FAST__
	decl GlobalTp
  .endif
.endm

.macro INC2_DTSP
  .ifndef __FAST__
	addl $2, GlobalTp
  .endif
.endm

.macro STD_IVAL
  .ifndef __FAST__
	movl GlobalTp, %edx
	movb $OP_IVAL, (%edx)
	decl GlobalTp
  .endif
.endm

.macro STD_ADDR
  .ifndef __FAST__
	movl GlobalTp, %edx
	movb $OP_ADDR, (%edx)
	decl GlobalTp
  .endif
.endm

.macro UNLOOP
	addl $3*WSIZE, GlobalRp  # terminal count reached, discard top 3 items
  .ifndef __FAST__
        addl $3, GlobalRtp
  .endif
.endm

.macro NEXT
	incl %ebp		 # increment the Forth instruction ptr
	movl %ebp, GlobalIp
  .ifdef  __FAST__
	movl %ebx, GlobalSp
  .endif
	movb (%ebp), %al         # get the opcode
	movl JumpTable(,%eax,4), %ecx	# machine code address of word
	xorl %eax, %eax	
	jmpl *%ecx		# jump to next word
.endm


.macro DROP                     # increment DSP by 1 cell; assume DSP in ebx reg
        INC_DSP
	STSP
	INC_DTSP
.endm


.macro DUP                      # assume DSP in ebx reg
        movl WSIZE(%ebx), %ecx
        movl %ecx, (%ebx)
	DEC_DSP
	STSP
  .ifndef __FAST__
        movl GlobalTp, %ecx
        movb 1(%ecx), %al
        movb %al, (%ecx)
	xorl %eax, %eax
   .endif
        DEC_DTSP
.endm


.macro _NOT                   # assume DSP in ebx reg
	notl WSIZE(%ebx)
.endm


.macro STOD
	LDSP
	movl $WSIZE, %ecx
	movl WSIZE(%ebx), %eax
	cdq
	movl %edx, (%ebx)
	subl %ecx, %ebx
	STSP
	STD_IVAL
	xorl %eax, %eax
.endm


.macro DPLUS
	LDSP
	INC2_DSP
	movl (%ebx), %eax
	clc
	addl 2*WSIZE(%ebx), %eax
	movl %eax, 2*WSIZE(%ebx)
	movl WSIZE(%ebx), %eax
	adcl -WSIZE(%ebx), %eax
	movl %eax, WSIZE(%ebx)
	STSP
	INC2_DTSP
	xor %eax, %eax
.endm

.macro DMINUS
	LDSP
	INC2_DSP
	movl 2*WSIZE(%ebx), %eax
	clc
	subl (%ebx), %eax
	movl %eax, 2*WSIZE(%ebx)
	movl WSIZE(%ebx), %eax
	sbbl -WSIZE(%ebx), %eax
	movl %eax, WSIZE(%ebx)
	STSP
	INC2_DTSP
	xor %eax, %eax
.endm

// Error jumps
E_not_addr:
        movl $E_NOT_ADDR, %eax
        ret

E_ret_stk_corrupt:
        movl $E_RET_STK_CORRUPT, %eax
        ret

E_div_zero:
	movl $E_DIV_ZERO, %eax
	ret

E_div_overflow:
	movl $E_DIV_OVERFLOW, %eax
	ret

L_cputest:
	ret

# set kForth's default fpu settings
L_initfpu:
	movl GlobalSp, %ebx
	fnstcw NDPcw           # save the NDP control word
	movl NDPcw, %ecx
	andb $240, %ch         # mask the high byte
        orb  $2,  %ch          # set double precision, round near
        movl %ecx, (%ebx)
	fldcw (%ebx)
	ret

L_nop:
        movl $E_UNKNOWN_OP, %eax   # unknown operation
        ret
L_quit:
	movl BottomOfReturnStack, %eax	# clear the return stacks
	movl %eax, GlobalRp
	movl %eax, vmEntryRp
  .ifndef __FAST__
	movl BottomOfReturnTypeStack, %eax
	movl %eax, GlobalRtp
  .endif
	movl $8, %eax		# exit the virtual machine
	ret
L_abort:
	movl BottomOfStack, %eax
	movl %eax, GlobalSp
  .ifndef __FAST__
	movl BottomOfTypeStack, %eax
	movl %eax, GlobalTp
  .endif
	jmp L_quit

L_jz:
        LDSP
	DROP
        movl (%ebx), %eax
        cmpl $0, %eax
        jz jz1
	movl $4, %eax
        addl %eax, %ebp       # do not jump
	xorl %eax, %eax
        NEXT
jz1:    movl %ebp, %ecx
        incl %ecx
        movl (%ecx), %eax       # get the relative jump count
        decl %eax
        addl %eax, %ebp
	xorl %eax, %eax
        NEXT

L_jnz:				# not implemented
	ret

L_jmp:
        movl %ebp, %ecx
        incl %ecx
        movl (%ecx), %eax       # get the relative jump count
        addl %eax, %ecx
        subl $2, %ecx
        movl %ecx, %ebp		# set instruction ptr
	xorl %eax, %eax
        NEXT

L_calladdr:
	incl %ebp
	movl %ebp, %ecx # address to execute (intrinsic Forth word or other)
	addl $3, %ebp
	movl %ebp, GlobalIp
	call *(%ecx)
	movl GlobalIp, %ebp
	ret

L_binary:
	movl $Base, %ecx
	movl $2, (%ecx)
	NEXT
L_decimal:	
	movl $Base, %ecx
	movl $10, (%ecx)
	NEXT
L_hex:	
	movl $Base, %ecx
	movl $16, (%ecx)
	NEXT

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
	movl (%ebx), %ecx
	movl %ecx, Precision
	NEXT

L_false:
	LDSP
	movl $0, (%ebx)
	DEC_DSP
	STSP
	STD_IVAL
	NEXT

L_true:
	LDSP
	movl $-1, (%ebx)
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

L_cellplus:
	LDSP
	addl $WSIZE, WSIZE(%ebx)
	NEXT

L_cells:
	LDSP
	sall $2, WSIZE(%ebx)
	NEXT

L_dfloatplus:	
	LDSP
	addl $2*WSIZE, WSIZE(%ebx)
	NEXT				

L_dfloats:	
	LDSP
	sall $3, WSIZE(%ebx)
	NEXT

L_dup:
	LDSP
	DUP
        NEXT

L_drop:
	LDSP
        DROP
        NEXT

L_inc:
	LDSP
        incl WSIZE(%ebx)
        NEXT

L_dec:
	LDSP
        decl WSIZE(%ebx)
        NEXT

L_neg:
	LDSP
	negl WSIZE(%ebx)
        NEXT

L_lshift:
	LDSP
	DROP
	movl (%ebx), %ecx
	shll %cl, WSIZE(%ebx)
	NEXT

L_rshift:
	LDSP
	DROP
	movl (%ebx), %ecx
	shrl %cl, WSIZE(%ebx)
	NEXT

L_twoplus:
	LDSP
	incl WSIZE(%ebx)
	incl WSIZE(%ebx)
	NEXT

L_twominus:
	LDSP
	decl WSIZE(%ebx)
	decl WSIZE(%ebx)
	NEXT

L_twostar:
	LDSP
	sall $1, WSIZE(%ebx)
	NEXT

L_twodiv:
	LDSP
	sarl $1, WSIZE(%ebx)
	NEXT

L_sub:
	LDSP
	DROP         # result will have type of first operand
	movl (%ebx), %eax
	subl %eax, WSIZE(%ebx)	
        xorl %eax, %eax
        NEXT

L_mul:
	LDSP
	movl $WSIZE, %ecx
	addl %ecx, %ebx
	STSP
	movl (%ebx), %eax
	addl %ecx, %ebx
	imull (%ebx)
	movl %eax, (%ebx)
   .ifdef __FAST__
        subl %ecx, %ebx
   .endif
	INC_DTSP
	xorl %eax, %eax
        NEXT

L_stod:
	STOD
	NEXT

L_fabs:
	LDSP
        fldl WSIZE(%ebx)
        fabs
        fstpl WSIZE(%ebx)
        NEXT
L_fneg:
        LDSP
        fldl WSIZE(%ebx)
        fchs
        fstpl WSIZE(%ebx)
        NEXT

L_fsqrt:
	LDSP
	fldl WSIZE(%ebx)
	fsqrt
	fstpl WSIZE(%ebx)
	NEXT

L_degtorad:
	LDSP
	fldl FCONST_180
	INC_DSP
	fldl (%ebx)
	fdivp %st, %st(1)
	fldpi
	fmulp %st, %st(1)
	fstpl (%ebx)
	DEC_DSP
	NEXT

L_radtodeg:
	LDSP
	INC_DSP
	fldl (%ebx)
	fldpi
	fxch
	fdivp %st, %st(1)
	fldl FCONST_180
	fmulp %st, %st(1)
	fstpl (%ebx)
	DEC_DSP
	NEXT

L_fcos:
	LDSP
	INC_DSP
	movl WSIZE(%ebx), %eax
	pushl %ebx
	pushl %eax
	movl (%ebx), %eax
	pushl %eax
	call cos
	addl $8, %esp
	popl %ebx
	fstpl (%ebx)
	DEC_DSP
	xorl %eax, %eax
	NEXT

// For native x86 FPU fcos instruction, use FSINCOS
//
// L_fcos:
//	LDSP
//	fldl WSIZE(%ebx)
//	fcos
//	fstpl WSIZE(%ebx)
//	NEXT

L_fsin:
	LDSP
	INC_DSP
	movl WSIZE(%ebx), %eax
	pushl %ebx
	pushl %eax
	movl (%ebx), %eax
	pushl %eax
	call sin
	addl $8, %esp
	popl %ebx
	fstpl (%ebx)
	DEC_DSP
	xorl %eax, %eax
	NEXT

// For native x86 FPU fsin instruction, use FSINCOS
//
// L_fsin:
//	LDSP
//	fldl WSIZE(%ebx)
//	fsin
//	fstpl WSIZE(%ebx)
//	NEXT

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

L_floor:
	LDSP
	INC_DSP
	movl WSIZE(%ebx), %eax
	pushl %ebx
	pushl %eax
	movl (%ebx), %eax
	pushl %eax
	call floor
	addl $8, %esp
	popl %ebx
	fstpl (%ebx)
	DEC_DSP
	xorl %eax, %eax		
	NEXT

L_fround:
	LDSP
	INC_DSP
	fldl (%ebx)
	frndint
	fstpl (%ebx)
	DEC_DSP
	NEXT

L_ftrunc:
	LDSP
	INC_DSP
	fldl (%ebx)
	fnstcw NDPcw            # save NDP control word
        movl NDPcw, %ecx
	movb $12, %ch
	movl %ecx, (%ebx)
	fldcw (%ebx)
	frndint
        fldcw NDPcw             # restore NDP control word
	fstpl (%ebx)
	DEC_DSP
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

L_backslash:
        movl pTIB, %ecx
        movb $0, (%ecx)
        NEXT


	.comm GlobalSp,4,4
	.comm GlobalIp,4,4
	.comm GlobalRp,4,4
	.comm BottomOfStack,4,4
	.comm BottomOfReturnStack,4,4
	.comm vmEntryRp,4,4
	.comm Base,4,4
	.comm State,4,4
	.comm Precision,4,4
	.comm pTIB,4,4
	.comm TIB,256,1
	.comm WordBuf,256,1
	.comm ParseBuf,1024,1
	.comm NumberCount,4,4
	.comm NumberBuf,256,1

	
