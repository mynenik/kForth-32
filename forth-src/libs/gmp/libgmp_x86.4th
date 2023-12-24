(     Title:  kForth bindings for the GNU Multiple
              Precision Library, GNU MP 5.0.1
       File:  libgmp.4th
  Test file:  libgmp-test.4th
     Author:  David N. Williams
    License:  LGPL
    Version:  0.7.0
    Started:  February 24, 2011 
    Revised:  March 22, 2011 [ported to kForth by KM]

Any part of this file not derived from the GMP library is
)  
\ Copyright  (C) 2011 by David N. Williams
(  
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or at your option any later version.

This library is distributed in the hope that it will be useful 
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Library General Public License for moref details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free
Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
MA 02111-1307 USA.
)


vocabulary gmp
also gmp definitions

0 value hndl_GMP
s" libgmp.so" open-lib
dup 0= [IF] check-lib-error [THEN]
to hndl_GMP
cr .( Opened the GMP library )

[undefined] struct [IF] 
s" struct.4th" included
s" struct-ext.4th" included
[THEN]

\ from /usr/include/gmp-i386.h
0 constant GMP_ERROR_NONE
1 constant GMP_ERROR_UNSUPPORTED_ARGUMENT
2 constant GMP_ERROR_DIVISION_BY_ZERO
4 constant GMP_ERROR_SQRT_OF_NEGATIVE
8 constant GMP_ERROR_INVALID_ARGUMENT

struct
	int:         mpz_struct->mp_alloc
	int:         mpz_struct->mp_size
	cell% field  mpz_struct->mp_d
end-struct  mpz_struct%


struct
	4 mpz_struct% %size field   mpq_struct->mp_num
	4 mpz_struct% %size field   mpq_struct->mp_den
end-struct  mpq_struct%


struct
	int:         mpf_struct->mp_prec
	int:         mpf_struct->mp_size
	int:         mpf_struct->mp_exp
	cell% field  mpf_struct->mp_d
end-struct  mpf_struct%


\ libgmp 5.0.1 functions

\ 5.1 Initialization

s" __gmpz_init"  C-word  mpz_init   ( a -- )
s" __gmpz_clear" C-word  mpz_clear  ( a -- )

\ 5.2 Assignment

s" __gmpz_set"     C-word  mpz_set      ( a a -- )
s" __gmpz_set_ui"  C-word  mpz_set_ui   ( a n -- )
s" __gmpz_set_si"  C-word  mpz_set_si   ( a n -- )
s" __gmpz_set_d"   C-word  mpz_set_d    ( a r -- )
s" __gmpz_set_q"   C-word  mpz_set_q    ( a a -- )
s" __gmpz_set_f"   C-word  mpz_set_f    ( a a -- )
s" __gmpz_set_str" C-word  mpz_set_str  ( a a n -- n )
s" __gmpz_swap"    C-word  mpz_swap     ( a a -- )

\ 5.3 Combined initialization and assignment

s" __gmpz_init_set"     C-word  mpz_init_set     ( a a -- )
s" __gmpz_init_set_ui"  C-word  mpz_init_set_ui  ( a n -- )
s" __gmpz_init_set_si"  C-word  mpz_init_set_si  ( a n -- )
s" __gmpz_init_set_d"   C-word  mpz_init_set_d   ( a r -- )
s" __gmpz_init_set_str" C-word  mpz_init_set_str ( a a n -- n )

\ 5.4 Conversion

s" __gmpz_get_ui"     C-word  mpz_get_ui      ( a -- n )
s" __gmpz_get_si"     C-word  mpz_get_si      ( a -- n )
s" __gmpz_get_d"      C-word  mpz_get_d       ( a -- r )
s" __gmpz_get_d_2exp" C-word  mpz_get_d_2exp  ( a a -- r )
s" __gmpz_get_str"    C-word  mpz_get_str     ( a n a -- a )

\ 5.5 Arithmetic

s" __gmpz_add"        C-word  mpz_add         ( a a a -- )
s" __gmpz_add_ui"     C-word  mpz_add_ui      ( a a n -- )
s" __gmpz_sub"        C-word  mpz_sub         ( a a a -- )
s" __gmpz_sub_ui"     C-word  mpz_sub_ui      ( a a n -- )
s" __gmpz_ui_sub"     C-word  mpz_ui_sub      ( a n a -- )
s" __gmpz_mul"        C-word  mpz_mul         ( a a a -- )
s" __gmpz_mul_si"     C-word  mpz_mul_si      ( a a n -- )
s" __gmpz_mul_ui"     C-word  mpz_mul_ui      ( a a n -- )
s" __gmpz_addmul"     C-word  mpz_addmul      ( a a a -- )
s" __gmpz_addmul_ui"  C-word  mpz_addmul_ui   ( a a n -- )
s" __gmpz_submul"     C-word  mpz_submul      ( a a a -- )
s" __gmpz_submul_ui"  C-word  mpz_submul_ui   ( a a n -- )
s" __gmpz_mul_2exp"   C-word  mpz_mul_2exp    ( a a n -- )
s" __gmpz_neg"        C-word  mpz_neg         ( a a -- )
s" __gmpz_abs"        C-word  mpz_abs         ( a a -- )

\ 5.6 Division

s" __gmpz_cdiv_q"           C-word  mpz_cdiv_q           ( a a a -- )
s" __gmpz_cdiv_r"           C-word  mpz_cdiv_r           ( a a a -- )
s" __gmpz_cdiv_qr"          C-word  mpz_cdiv_qr          ( a a a a -- )
s" __gmpz_cdiv_q_ui"        C-word  mpz_cdiv_q_ui        ( a a n -- n )
s" __gmpz_cdiv_r_ui"        C-word  mpz_cdiv_r_ui        ( a a n -- n )
s" __gmpz_cdiv_qr_ui"       C-word  mpz_cdiv_qr_ui       ( a a a n -- n )
s" __gmpz_cdiv_ui"          C-word  mpz_cdiv_ui          ( a n -- n )
s" __gmpz_cdiv_q_2exp"      C-word  mpz_cdiv_q_2exp      ( a a n -- )
s" __gmpz_cdiv_r_2exp"      C-word  mpz_cdiv_r_2exp      ( a a n -- )
s" __gmpz_fdiv_q"           C-word  mpz_fdiv_q           ( a a a -- )
s" __gmpz_fdiv_r"           C-word  mpz_fdiv_r           ( a a a -- )
s" __gmpz_fdiv_qr"          C-word  mpz_fdiv_qr          ( a a a a -- )
s" __gmpz_fdiv_q_ui"        C-word  mpz_fdiv_q_ui        ( a a n -- n )
s" __gmpz_fdiv_r_ui"        C-word  mpz_fdiv_r_ui        ( a a n -- n )
s" __gmpz_fdiv_qr_ui"       C-word  mpz_fdiv_qr_ui       ( a a a n -- n )
s" __gmpz_fdiv_ui"          C-word  mpz_fdiv_ui          ( a n -- n )
s" __gmpz_fdiv_q_2exp"      C-word  mpz_fdiv_q_2exp      ( a a n -- )
s" __gmpz_fdiv_r_2exp"      C-word  mpz_fdiv_r_2exp      ( a a n -- )
s" __gmpz_tdiv_q"           C-word  mpz_tdiv_q           ( a a a -- )
s" __gmpz_tdiv_r"           C-word  mpz_tdiv_r           ( a a a -- )
s" __gmpz_tdiv_qr"          C-word  mpz_tdiv_qr          ( a a a a -- )
s" __gmpz_tdiv_q_ui"        C-word  mpz_tdiv_q_ui        ( a a n -- n )
s" __gmpz_tdiv_r_ui"        C-word  mpz_tdiv_r_ui        ( a a n -- n )
s" __gmpz_tdiv_qr_ui"       C-word  mpz_tdiv_qr_ui       ( a a a n -- n )
s" __gmpz_tdiv_ui"          C-word  mpz_tdiv_ui          ( a n -- n )
s" __gmpz_tdiv_q_2exp"      C-word  mpz_tdiv_q_2exp      ( a a n -- )
s" __gmpz_tdiv_r_2exp"      C-word  mpz_tdiv_r_2exp      ( a a n -- )
s" __gmpz_mod"              C-word  mpz_mod              ( a a a -- )

\ __gmpz_fdiv_r_ui same as __gmzp_mod_ui  ( see /usr/include/gmp-i386.h )
s" __gmpz_fdiv_r_ui"        C-word  mpz_mod_ui           ( a a n -- n )

s" __gmpz_divexact"         C-word  mpz_divexact         ( a a a -- )
s" __gmpz_divexact_ui"      C-word  mpz_divexact_ui      ( a a n -- )
s" __gmpz_divisible_p"      C-word  mpz_divisible_p      ( a a -- n )
s" __gmpz_divisible_ui_p"   C-word  mpz_divisible_ui_p   ( a n -- n )
s" __gmpz_divisible_2exp_p" C-word  mpz_divisible_2exp_p ( a n -- n )
s" __gmpz_congruent_p"      C-word  mpz_congruent_p      ( a a a -- n )
s" __gmpz_congruent_ui_p"   C-word  mpz_congruent_ui_p   ( a n n -- n )
s" __gmpz_congruent_2exp_p" C-word  mpz_congruent_2exp_p ( a a n -- n )

\ 5.7 Exponentiation

s" __gmpz_powm"       C-word  mpz_powm       ( a a a a -- )
s" __gmpz_powm_ui"    C-word  mpz_powm_ui    ( a a n a -- )
\ s" __gmpz_powm_sec"   C-word  mpz_powm_sec   ( a a a a -- ) \ only in 5.x
s" __gmpz_pow_ui"     C-word  mpz_pow_ui     ( a a n -- )
s" __gmpz_ui_pow_ui"  C-word  mpz_ui_pow_ui  ( a n n -- )

\ 5.8 Root extraction

s" __gmpz_root"             C-word  mpz_root              ( a a n -- n )
s" __gmpz_rootrem"          C-word  mpz_rootrem           ( a a a n -- )
s" __gmpz_sqrt"             C-word  mpz_sqrt              ( a a -- )
s" __gmpz_sqrtrem"          C-word  mpz_sqrtrem           ( a a a -- )
s" __gmpz_perfect_power_p"  C-word  mpz_perfect_power_p   ( a -- n )
s" __gmpz_perfect_square_p" C-word  mpz_perfect_square_p  ( a -- n )

\ 5.9 Number theoretics

s" __gmpz_probab_prime_p"  C-word  mpz_probab_prime_p  ( a n -- n )
s" __gmpz_nextprime"       C-word  mpz_nextprime       ( a a -- )
s" __gmpz_gcd"             C-word  mpz_gcd             ( a a a -- )
s" __gmpz_gcd_ui"          C-word  mpz_gcd_ui          ( a a n -- n )
s" __gmpz_gcdext"          C-word  mpz_gcdext          ( a a a a a -- )
s" __gmpz_lcm"             C-word  mpz_lcm             ( a a a -- )
s" __gmpz_lcm_ui"          C-word  mpz_lcm_ui          ( a a n -- )
s" __gmpz_invert"          C-word  mpz_invert          ( a a a -- n )
s" __gmpz_jacobi"          C-word  mpz_jacobi          ( a a -- n )
s" __gmpz_legendre"        C-word  mpz_legendre        ( a a -- n )

\ mpz_kronecker is same as mpz_jacobi  (see /usr/include/gmp-i386.h)
s" __gmpz_jacobi"          C-word  mpz_kronecker       ( a a -- n )

s" __gmpz_kronecker_si"    C-word  mpz_kronecker_si    ( a n -- n )
s" __gmpz_kronecker_ui"    C-word  mpz_kronecker_ui    ( a n -- n )
s" __gmpz_si_kronecker"    C-word  mpz_si_kronecker    ( n a -- n )
s" __gmpz_ui_kronecker"    C-word  mpz_ui_kronecker    ( n a -- n )
s" __gmpz_remove"          C-word  mpz_remove          ( a a a -- n )
s" __gmpz_fac_ui"          C-word  mpz_fac_ui          ( a n -- )
s" __gmpz_bin_ui"          C-word  mpz_bin_ui          ( a a n -- )
s" __gmpz_bin_uiui"        C-word  mpz_bin_uiui        ( a n n -- )
s" __gmpz_fib_ui"          C-word  mpz_fib_ui          ( a n -- )
s" __gmpz_fib2_ui"         C-word  mpz_fib2_ui         ( a a n -- )
s" __gmpz_lucnum_ui"       C-word  mpz_lucnum_ui       ( a n -- )
s" __gmpz_lucnum2_ui"      C-word  mpz_lucnum2_ui      ( a a n -- )

\ 5.10 Comparison

s" __gmpz_cmp"       C-word  mpz_cmp         ( a a -- n )
s" __gmpz_cmp_d"     C-word  mpz_cmp_d       ( a r -- n )
s" __gmpz_cmp_si"    C-word  mpz_cmp_si      ( a n -- n )
s" __gmpz_cmp_ui"    C-word  mpz_cmp_ui      ( a n -- n )
s" __gmpz_cmpabs"    C-word  mpz_cmpabs      ( a a -- n )
s" __gmpz_cmpabs_d"  C-word  mpz_cmpabs_d    ( a r -- n )
s" __gmpz_cmpabs_ui" C-word  mpz_cmpabs_ui   ( a n -- n )

: mpz_sgn ( a -- n ) 
    mpz_struct->mp_size @ 
    dup 0<  IF drop -1 ELSE 
      0> IF 1 ELSE 0 THEN 
    THEN ;
       

\ 5.11 Logic and bit manipulation

s" __gmpz_and"       C-word  mpz_and       ( a a a -- )
s" __gmpz_ior"       C-word  mpz_ior       ( a a a -- )
s" __gmpz_xor"       C-word  mpz_xor       ( a a a -- )
s" __gmpz_com"       C-word  mpz_com       ( a a -- )
s" __gmpz_popcount"  C-word  mpz_popcount  ( a -- n )
s" __gmpz_hamdist"   C-word  mpz_hamdist   ( a a -- n )
s" __gmpz_scan0"     C-word  mpz_scan0     ( a n -- n )
s" __gmpz_scan1"     C-word  mpz_scan1     ( a n -- n )
s" __gmpz_setbit"    C-word  mpz_setbit    ( a n -- )
s" __gmpz_clrbit"    C-word  mpz_clrbit    ( a n -- )
s" __gmpz_combit"    C-word  mpz_combit    ( a n -- )
s" __gmpz_tstbit"    C-word  mpz_tstbit    ( a n -- n )

\ 5.12 Input and output

s" __gmpz_out_str"   C-word  mpz_out_str   ( a n a -- n )
s" __gmpz_inp_str"   C-word  mpz_inp_str   ( a a n -- n )
s" __gmpz_out_raw"   C-word  mpz_out_raw   ( a a -- n )
s" __gmpz_inp_raw"   C-word  mpz_inp_raw   ( a a -- n )

\ 5.13 Random numbers

s" __gmpz_urandomb"  C-word  mpz_urandomb  ( a a n -- )
s" __gmpz_urandomm"  C-word  mpz_urandomm  ( a a a -- )
s" __gmpz_rrandomb"  C-word  mpz_rrandomb  ( a a n -- )
s" __gmpz_random"    C-word  mpz_random    ( a n -- )
s" __gmpz_random2"   C-word  mpz_random2   ( a n -- )

\ 5.14 Integer export and import

s" __gmpz_import"    C-word  mpz_import    ( a n n n n n a -- )
s" __gmpz_export"    C-word  mpz_export    ( a a n n n n a -- a )

\ 5.15 Miscellaneous

s" __gmpz_fits_ulong_p"  C-word  mpz_fits_ulong_p    ( a -- n )
s" __gmpz_fits_slong_p"  C-word  mpz_fits_slong_p    ( a -- n )
s" __gmpz_fits_uint_p"   C-word  mpz_fits_uint_p     ( a -- n )
s" __gmpz_fits_sint_p"   C-word  mpz_fits_sint_p     ( a -- n )
s" __gmpz_fits_ushort_p" C-word  mpz_fits_ushort_p   ( a -- n )
s" __gmpz_fits_sshort_p" C-word  mpz_fits_sshort_p   ( a -- n )
\ s" mpz_odd_p"       C-word  mpz_odd_p           ( a -- n )
\ s" mpz_even_p"      C-word  mpz_even_p          ( a -- n )
s" __gmpz_sizeinbase"    C-word  mpz_sizeinbase      ( a n -- n )

\ 5.16 Special

s" __gmpz_array_init"  C-word  mpz_array_init   ( a n n -- )
s" __gmpz_realloc"     C-word  _mpz_realloc     ( a n -- a )
s" __gmpz_getlimbn"    C-word  mpz_getlimbn     ( a n -- n )
s" __gmpz_size"        C-word  mpz_size         ( a -- n )

\ 6 Rationals

s" __gmpq_canonicalize"  C-word  mpq_canonicalize  ( a -- )

\ 6.1 Initialization and assignment

s" __gmpq_init"     C-word  mpq_init     ( a -- )
s" __gmpq_clear"    C-word  mpq_clear    ( a -- )
s" __gmpq_set"      C-word  mpq_set      ( a a -- )
s" __gmpq_set_z"    C-word  mpq_set_z    ( a a -- )
s" __gmpq_set_ui"   C-word  mpq_set_ui   ( a n n -- )
s" __gmpq_set_si"   C-word  mpq_set_si   ( a n n -- )
s" __gmpq_set_str"  C-word  mpq_set_str  ( a a n -- n )
s" __gmpq_swap"     C-word  mpq_swap     ( a a -- )

\ 6.2 Conversion

s" __gmpq_get_d"    C-word  mpq_get_d     ( a -- r )
s" __gmpq_set_d"    C-word  mpq_set_d     ( a r -- )
s" __gmpq_set_f"    C-word  mpq_set_f     ( a a -- )
s" __gmpq_get_str"  C-word  mpq_get_str   ( a n a -- a )

\ 6.3 Arithmetic

s" __gmpq_add"      C-word  mpq_add       ( a a a -- )
s" __gmpq_sub"      C-word  mpq_sub       ( a a a -- )
s" __gmpq_mul"      C-word  mpq_mul       ( a a a -- )
s" __gmpq_mul_2exp" C-word  mpq_mul_2exp  ( a a n -- )
s" __gmpq_div"      C-word  mpq_div       ( a a a -- )
s" __gmpq_div_2exp" C-word  mpq_div_2exp  ( a a n -- )
s" __gmpq_neg"      C-word  mpq_neg       ( a a -- )
s" __gmpq_abs"      C-word  mpq_abs       ( a a -- )
s" __gmpq_inv"      C-word  mpq_inv       ( a a -- )

\ 6.4 Comparison

s" __gmpq_cmp"       C-word  mpq_cmp      ( a a -- n )
s" __gmpq_cmp_ui"    C-word  mpq_cmp_ui   ( a n n -- n )
s" __gmpq_cmp_si"    C-word  mpq_cmp_si   ( a n n -- n )
s" __gmpq_equal"     C-word  mpq_equal    ( a a -- n )

: mpq_sgn ( a -- n ) mpq_struct->mp_num a@ mpz_sgn ;

\ 6.5 Integer functions

\ s" mpq_numref"  C-word  mpq_numref   ( a -- a )
\ s" mpq_denref"  C-word  mpq_denref   ( a -- a )
s" __gmpq_get_num"   C-word  mpq_get_num  ( a a -- )
s" __gmpq_get_den"   C-word  mpq_get_den  ( a a -- )
s" __gmpq_set_num"   C-word  mpq_set_num  ( a a -- )
s" __gmpq_set_den"   C-word  mpq_set_den  ( a a -- )

\ 6.6 Input and output

s" __gmpq_out_str"   C-word  mpq_out_str  ( a n a -- n )
s" __gmpq_inp_str"   C-word  mpq_inp_str  ( a a n -- n )

\ 7 Floating point

\ 7.1 Initialization

s" __gmpf_set_default_prec"  C-word  mpf_set_default_prec  ( n -- )
s" __gmpf_get_default_prec"  C-word  mpf_get_default_prec  ( -- n )
s" __gmpf_init"              C-word  mpf_init              ( a -- )
s" __gmpf_init2"             C-word  mpf_init2             ( a n -- )
s" __gmpf_clear"             C-word  mpf_clear             ( a -- )
s" __gmpf_get_prec"          C-word  mpf_get_prec          ( a -- n )
s" __gmpf_set_prec"          C-word  mpf_set_prec          ( a n -- )
s" __gmpf_set_prec_raw"      C-word  mpf_set_prec_raw      ( a n -- )

\ 7.2 Assignment

s" __gmpf_set"     C-word  mpf_set      ( a a -- )
s" __gmpf_set_ui"  C-word  mpf_set_ui   ( a n -- )
s" __gmpf_set_si"  C-word  mpf_set_si   ( a n -- )
s" __gmpf_set_d"   C-word  mpf_set_d    ( a r -- )
s" __gmpf_set_z"   C-word  mpf_set_z    ( a a -- )
s" __gmpf_set_q"   C-word  mpf_set_q    ( a a -- )
s" __gmpf_set_str" C-word  mpf_set_str  ( a a n -- n )
s" __gmpf_swap"    C-word  mpf_swap     ( a a -- )

\ 7.3 Combined initialization and assignment

s" __gmpf_init_set"     C-word  mpf_init_set     ( a a -- )
s" __gmpf_init_set_ui"  C-word  mpf_init_set_ui  ( a n -- )
s" __gmpf_init_set_si"  C-word  mpf_init_set_si  ( a n -- )
s" __gmpf_init_set_d"   C-word  mpf_init_set_d   ( a r -- )
s" __gmpf_init_set_str" C-word  mpf_init_set_str ( a a n -- n )

\ 7.4 Conversion

s" __gmpf_get_d"        C-word  mpf_get_d        ( a -- r )
s" __gmpf_get_d_2exp"   C-word  mpf_get_d_2exp   ( a a -- r )
s" __gmpf_get_si"       C-word  mpf_get_si       ( a -- n )
s" __gmpf_get_ui"       C-word  mpf_get_ui       ( a -- n )
s" __gmpf_get_str"      C-word  mpf_get_str      ( a a n n a -- a )

\ 7.5 Arithmetic

s" __gmpf_add"      C-word  mpf_add        ( a a a -- )
s" __gmpf_add_ui"   C-word  mpf_add_ui     ( a a n -- )
s" __gmpf_sub"      C-word  mpf_sub        ( a a a -- )
s" __gmpf_ui_sub"   C-word  mpf_ui_sub     ( a n a -- )
s" __gmpf_sub_ui"   C-word  mpf_sub_ui     ( a a n -- )
s" __gmpf_mul"      C-word  mpf_mul        ( a a a -- )
s" __gmpf_mul_ui"   C-word  mpf_mul_ui     ( a a n -- )
s" __gmpf_div"      C-word  mpf_div        ( a a a -- )
s" __gmpf_ui_div"   C-word  mpf_ui_div     ( a n a -- )
s" __gmpf_div_ui"   C-word  mpf_div_ui     ( a a n -- )
s" __gmpf_sqrt"     C-word  mpf_sqrt       ( a a -- )
s" __gmpf_sqrt_ui"  C-word  mpf_sqrt_ui    ( a n -- )
s" __gmpf_pow_ui"   C-word  mpf_pow_ui     ( a a n -- )
s" __gmpf_neg"      C-word  mpf_neg        ( a a -- )
s" __gmpf_abs"      C-word  mpf_abs        ( a a -- )
s" __gmpf_mul_2exp" C-word  mpf_mul_2exp   ( a a n -- )
s" __gmpf_div_2exp" C-word  mpf_div_2exp   ( a a n -- )

\ 7.6 Comparison

s" __gmpf_cmp"      C-word  mpf_cmp        ( a a -- n )
s" __gmpf_cmp_d"    C-word  mpf_cmp_d      ( a r -- n )
s" __gmpf_cmp_ui"   C-word  mpf_cmp_ui     ( a n -- n )
s" __gmpf_cmp_si"   C-word  mpf_cmp_si     ( a n -- n )
s" __gmpf_eq"       C-word  mpf_eq         ( a a n -- n )
s" __gmpf_reldiff"  C-word  mpf_reldiff    ( a a a -- )

: mpf_sgn ( a -- n ) 
    mpf_struct->mp_size @ 
    dup 0<  IF drop -1 ELSE 
      0> IF 1 ELSE 0 THEN 
    THEN ;

\ 7.7 Input and output

s" __gmpf_out_str"  C-word  mpf_out_str    ( a n n a -- n )
s" __gmpf_inp_str"  C-word  mpf_inp_str    ( a a n -- n )

\ 7.8 Miscellaneous

s" __gmpf_ceil"          C-word  mpf_ceil          ( a a -- )
s" __gmpf_floor"         C-word  mpf_floor         ( a a -- )
s" __gmpf_trunc"         C-word  mpf_trunc         ( a a -- )
s" __gmpf_integer_p"     C-word  mpf_integer_p     ( a -- n )
s" __gmpf_fits_ulong_p"  C-word  mpf_fits_ulong_p  ( a -- n )
s" __gmpf_fits_slong_p"  C-word  mpf_fits_slong_p  ( a -- n )
s" __gmpf_fits_uint_p"   C-word  mpf_fits_uint_p   ( a -- n )
s" __gmpf_fits_sint_p"   C-word  mpf_fits_sint_p   ( a -- n )
s" __gmpf_fits_ushort_p" C-word  mpf_fits_ushort_p ( a -- n )
s" __gmpf_fits_sshort_p" C-word  mpf_fits_sshort_p ( a -- n )
s" __gmpf_urandomb"      C-word  mpf_urandomb      ( a a n -- )
s" __gmpf_random2"       C-word  mpf_random2       ( a n n -- )

\ 8 Low level

\ 9 Random number state

\ 9.1 Initialization

s" __gmp_randinit_default"      C-word  gmp_randinit_default       ( a -- )
s" __gmp_randinit_mt"           C-word  gmp_randinit_mt            ( a -- )
s" __gmp_randinit_lc_2exp"      C-word  gmp_randinit_lc_2exp       ( a a n n -- )
s" __gmp_randinit_lc_2exp_size" C-word  gmp_randinit_lc_2exp_size  ( a n -- n )
s" __gmp_randinit_set"          C-word  gmp_randinit_set           ( a a -- )
s" __gmp_randclear"             C-word  gmp_randclear              ( a -- )

\ 9.2 Seeding

s" __gmp_randseed"     C-word  gmp_randseed     ( a a -- )
s" __gmp_randseed_ui"  C-word  gmp_randseed_ui  ( a n -- )

\ 9.3 Miscellaneous

s" __gmp_urandomb_ui"  C-word  gmp_urandomb_ui  ( a n -- n )
s" __gmp_urandomm_ui"  C-word  gmp_urandomm_ui  ( a n -- n )

\ 10 Formatted output

\ 10.1 Format strings

\ 10.2 Functions

\ 11 Formatted input

\ 11.1 Format strings

\ 11.2 Functions

\ libgmp_macros

0 [IF]
\c int mpz_cmp_si_macro (mpz_ptr op1, signed long int op2)
\c { return mpz_cmp_si (op1, op2); }
\c int mpz_cmp_ui_macro (mpz_ptr op1, unsigned long int op2)
\c { return mpz_cmp_ui (op1, op2); }
\c int mpz_odd_p_macro (mpz_ptr op) { return mpz_odd_p (op); }
\c int mpz_even_p_macro (mpz_ptr op) { return mpz_odd_p (op); }
\c int mpq_cmp_ui_macro (mpq_ptr op1, unsigned long int num2, unsigned long int den2)
\c { return mpq_cmp_ui (op1, num2, den2); }
\c int mpq_cmp_si_macro (mpq_ptr op1, long int num2, unsigned long int den2)
\c { return mpq_cmp_si (op1, num2, den2); }
\c mpz_srcptr mpq_numref_macro (mpq_ptr op) { return mpq_numref (op); }
\c mpz_srcptr mpq_denref_macro (mpq_ptr op) { return mpq_denref (op); }
\c int sizeof_mpz (void) { return sizeof (mpz_t); }
\c int sizeof_mpq (void) { return sizeof (mpq_t); }
\c int sizeof_mpf (void) { return sizeof (mpf_t); }
\c int bits_per_mp_limb (void) { return mp_bits_per_limb; }
\c int sizeof_gmp_randstate (void) { return sizeof (gmp_randstate_t); }

C-word mpz_cmp_si mpz_cmp_si_macro a n -- n
C-word mpz_cmp_ui mpz_cmp_ui_macro a n -- n
C-word mpz_odd_p mpz_odd_p_macro a -- n
C-word mpz_even_p mpz_even_p_macro a -- n
C-word mpq_cmp_ui mpq_cmp_ui_macro a n n -- n
C-word mpq_cmp_si mpq_cmp_si_macro a n n -- n
C-word mpq_numref mpq_numref_macro a -- a
C-word mpq_denref mpq_denref_macro a -- a

C-word mp_bits_per_limb bits_per_mp_limb -- n
C-word /GMP-RANDSTATE sizeof_gmp_randstate -- n
[THEN]

: sizeof_mpz ( -- n ) mpz_struct% %size ;
: sizeof_mpq ( -- n ) mpq_struct% %size ;
: sizeof_mpf ( -- n ) mpf_struct% %size ;

sizeof_mpz constant /MPZ
sizeof_mpq constant /MPQ
sizeof_mpf constant /MPF

also forth definitions


