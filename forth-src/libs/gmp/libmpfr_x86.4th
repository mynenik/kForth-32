(     Title:  kForth bindings for the GNU Multiple
              Precision Floatint-Point Reliable Library, 
              for GNU MPFR Ver. >= 3.0.0
       File:  libmpfr.4th
  Test file:  gmpr-test.fs
     Author:  David N. Williams
    License:  LGPL
    Version:  0.8.4c
    Started:  March 25, 2011 
    Revised:  July 10, 2011 -- adapted for kForth by K. Myneni,
                2015-02-08 fixed problem with mpfr_div_d.
                2023-03-18 use Forth 200x structures.

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

vocabulary mpfr
also mpfr definitions

0 value hndl_MPFR
s" libmpfr.so" open-lib
dup 0= [IF] check-lib-error [THEN]
to hndl_MPFR
cr .( Opened the MPFR library )

[UNDEFINED] begin-structure [IF] 
s" struct-200x.4th" included
[THEN]

BEGIN-STRUCTURE mpfr_struct%
  4 +FIELD   mpfr_struct->mpfr_prec
  4 +FIELD   mpfr_struct->mpfr_sign
  4 +FIELD   mpfr_struct->mpfr_exp
    FIELD:   mpfr_struct->mpfr_d
END-STRUCTURE

mpfr_struct%  constant /MPFR

\ Create and allot a mpfr number type
: mpfr_t create mpfr_struct% allot ;


          2  constant  MPFR_PREC_MIN
-1 1 rshift  constant  MPFR_PREC_MAX


 0  constant  MPFR_RNDN   \ round to nearest, with ties to even
 1  constant  MPFR_RNDZ   \ round toward zero
 2  constant  MPFR_RNDU   \ round toward +Inf
 3  constant  MPFR_RNDD   \ round toward -Inf
 4  constant  MPFR_RNDA   \ round away from zero

MPFR_RNDN  constant  GMP_RNDN
MPFR_RNDZ  constant  GMP_RNDZ
MPFR_RNDU  constant  GMP_RNDU
MPFR_RNDD  constant  GMP_RNDD
MPFR_RNDA  constant  GMP_RNDA


\ libmpfr 3.0.1 functions

\ 5.1 Initialization

s" mpfr_init"              C-word  mpfr_init              ( a -- )
s" mpfr_init2"             C-word  mpfr_init2             ( a n -- )
s" mpfr_clear"             C-word  mpfr_clear             ( a -- )
s" mpfr_set_default_prec"  C-word  mpfr_set_default_prec  ( n -- )
s" mpfr_get_default_prec"  C-word  mpfr_get_default_prec  ( -- n )
s" mpfr_set_prec"          C-word  mpfr_set_prec          ( a n -- )
s" mpfr_get_prec"          C-word  mpfr_get_prec          ( a -- n )

\ 5.2 Assignment

s" mpfr_set"             C-word   mpfr_set     ( a a n -- n )
s" mpfr_set_ui"          C-word   mpfr_set_ui  ( a n n -- n )
s" mpfr_set_si"          C-word   mpfr_set_si  ( a n n -- n )
s" __gmpfr_set_uj"       C-word   mpfr_set_uj  ( a n n -- n )
s" __gmpfr_set_sj"       C-word   mpfr_set_sj  ( a n n -- n )
s" mpfr_set_flt"         C-word   mpfr_set_flt ( a s n -- n )

s" mpfr_set_d"           C-word   _mpfr_set_d   ( a r n -- n )
: mpfr_set_d >r swap r> _mpfr_set_d ;

\ s" mpfr_set_ld" C-word  mpfr_set_ld  ( a ld n -- n ) \ long double not supported

s" mpfr_set_z"           C-word   mpfr_set_z   ( a a n -- n )
s" mpfr_set_q"           C-word   mpfr_set_q   ( a a n -- n )
s" mpfr_set_f"           C-word   mpfr_set_f   ( a a n -- n )

s" mpfr_set_ui_2exp"     C-word  mpfr_set_ui_2exp  ( a n n n -- n )
s" mpfr_set_si_2exp"     C-word  mpfr_set_si_2exp    ( a n n n -- n )
s" __gmpfr_set_uj_2exp"  C-word  mpfr_set_uj_2exp  ( a n n n -- n )
s" __gmpfr_set_sj_2exp"  C-word  mpfr_set_sj_2exp  ( a n n n -- n )
s" mpfr_set_z_2exp"      C-word  mpfr_set_z_2exp   ( a a n n -- n )

s" mpfr_set_str"         C-word  mpfr_set_str  ( a a n n -- n )
s" mpfr_strtofr"         C-word  mpfr_strtofr  ( a a a n n -- n )

s" mpfr_set_nan"         C-word  mpfr_set_nan  ( a -- )
s" mpfr_set_inf"         C-word  mpfr_set_inf  ( a n -- )
s" mpfr_set_zero"        C-word  mpfr_set_zero ( a n -- )

s" mpfr_swap"            C-word  mpfr_swap     ( a a -- )

\ 5.3 Combined initialization and assignment

: mpfr_init_set    ( ax ay nrnd -- n ) 2>r dup mpfr_init  2r> mpfr_set ;
: mpfr_init_set_ui ( a  n  nrnd -- n ) 2>r dup mpfr_init  2r> mpfr_set_ui ;
: mpfr_init_set_si ( a  n  nrnd -- n ) 2>r dup mpfr_init  2r> mpfr_set_si ;
: mpfr_init_set_d  ( a  r  nrnd -- n ) >r 2>r dup mpfr_init 2r> swap r> _mpfr_set_d ;

\ : mpfr_init_set_ld ;  ( long double not supported ) 

: mpfr_init_set_z  ( a1 a2 nrnd -- n ) 2>r dup mpfr_init  2r> mpfr_set_z ;
: mpfr_init_set_q  ( a1 a2 nrnd -- n ) 2>r dup mpfr_init  2r> mpfr_set_q ; 
: mpfr_init_set_f  ( a1 a2 nrnd -- n ) 2>r dup mpfr_init  2r> mpfr_set_f ;


s" mpfr_init_set_str"     C-word  mpfr_init_set_str  ( a a n n -- n )

\ 5.4 Conversion

s" mpfr_get_flt"          C-word  mpfr_get_flt  ( a n -- r )
s" mpfr_get_d"            C-word  mpfr_get_d    ( a n -- r )

\ s" mpfr_get_ld" C-word  mpfr_get_ld   ( a n -- ld )  \ long double not supported

s" mpfr_get_si"           C-word  mpfr_get_si   ( a n -- n )
s" mpfr_get_ui"           C-word  mpfr_get_ui   ( a n -- n )
s" __gmpfr_mpfr_get_sj"   C-word  mpfr_get_sj   ( a n -- n )
s" __gmpfr_mpfr_get_uj"   C-word  mpfr_get_uj   ( a n -- n )

s" mpfr_get_d_2exp"       C-word  mpfr_get_d_2exp  ( a a n -- r )

\ s" mpfr_get_ld_2exp" C-word mpfr_get_ld_2exp  ( a a n -- ld ) \ long double not supported

s" mpfr_get_z_2exp"       C-word  mpfr_get_z_2exp  ( a a -- n )

s" mpfr_get_z"            C-word  mpfr_get_z  ( a a n -- n )
s" mpfr_get_f"            C-word  mpfr_get_f  ( a a n -- n )

s" mpfr_get_str"          C-word mpfr_get_str  ( a a n n a n -- a )
s" mpfr_free_str"         C-word mpfr_free_str  ( a -- )

s" mpfr_fits_ulong_p"     C-word  mpfr_fits_ulong_p   ( a n -- n )
s" mpfr_fits_slong_p"     C-word  mpfr_fits_slong_p   ( a n -- n )
s" mpfr_fits_uint_p"      C-word  mpfr_fits_uint_p    ( a n -- n )
s" mpfr_fits_sint_p"      C-word  mpfr_fits_sint_p    ( a n -- n )
s" mpfr_fits_ushort_p"    C-word  mpfr_fits_ushort_p  ( a n -- n )
s" mpfr_fits_sshort_p"    C-word  mpfr_fits_sshort_p  ( a n -- n )
s" mpfr_fits_uintmax_p"   C-word  mpfr_fits_uintmax_p ( a n -- n )
s" mpfr_fits_intmax_p"    C-word  mpfr_fits_intmax_p  ( a n -- n )

\ 5.5 Basic Arithmetic

s" mpfr_add"       C-word  mpfr_add        ( a a a n -- n )
s" mpfr_add_ui"    C-word  mpfr_add_ui     ( a a n n -- n )
s" mpfr_add_si"    C-word  mpfr_add_si     ( a a n n -- n )
s" mpfr_add_d"     C-word  _mpfr_add_d     ( a a r n -- n )
: mpfr_add_d  >r swap r> _mpfr_add_d ;

s" mpfr_add_z"     C-word  mpfr_add_z      ( a a a n -- n )
s" mpfr_add_q"     C-word  mpfr_add_q      ( a a a n -- n )

s" mpfr_sub"       C-word  mpfr_sub        ( a a a n -- n )
s" mpfr_ui_sub"    C-word  mpfr_ui_sub     ( a n a n -- n )
s" mpfr_sub_ui"    C-word  mpfr_sub_ui     ( a a n n -- n )
s" mpfr_si_sub"    C-word  mpfr_si_sub     ( a n a n -- n )
s" mpfr_sub_si"    C-word  mpfr_sub_si     ( a a n n -- n )
s" mpfr_d_sub"     C-word  _mpfr_d_sub     ( a r a n -- n )
: mpfr_d_sub 2>r swap 2r> _mpfr_d_sub ;

s" mpfr_sub_d"     C-word  _mpfr_sub_d     ( a a r n -- n )
: mpfr_sub_d >r swap r> _mpfr_sub_d ;

s" mpfr_sub_z"     C-word  mpfr_sub_z      ( a a a n -- n )
s" mpfr_sub_q"     C-word  mpfr_sub_q      ( a a a n -- n )

s" mpfr_mul"       C-word  mpfr_mul        ( a a a n -- n )
s" mpfr_mul_ui"    C-word  mpfr_mul_ui     ( a a n n -- n )
s" mpfr_mul_si"    C-word  mpfr_mul_si     ( a a n n -- n )
s" mpfr_mul_d"     C-word  _mpfr_mul_d     ( a a r n -- n )
: mpfr_mul_d >r swap r> _mpfr_mul_d ;

s" mpfr_mul_z"     C-word  mpfr_mul_z      ( a a a n -- n )
s" mpfr_mul_q"     C-word  mpfr_mul_q      ( a a a n -- n )

s" mpfr_sqr"       C-word  mpfr_sqr        ( a a n -- n )

s" mpfr_div"       C-word  mpfr_div        ( a a a n -- n )
s" mpfr_ui_div"    C-word  mpfr_ui_div     ( a n a n -- n )
s" mpfr_div_ui"    C-word  mpfr_div_ui     ( a a n n -- n )
s" mpfr_si_div"    C-word  mpfr_si_div     ( a n a n -- n )
s" mpfr_div_si"    C-word  mpfr_div_si     ( a a n n -- n )
s" mpfr_d_div"     C-word  mpfr_d_div      ( a r a n -- n )
s" mpfr_div_d"     C-word  _mpfr_div_d     ( a a r n -- n )
: mpfr_div_d >r swap r> _mpfr_div_d ;
s" mpfr_div_z"     C-word  mpfr_div_z      ( a a a n -- n )
s" mpfr_div_q"     C-word  mpfr_div_q      ( a a a n -- n )

s" mpfr_sqrt"      C-word  mpfr_sqrt       ( a a n -- n )
s" mpfr_sqrt_ui"   C-word  mpfr_sqrt_ui    ( a n n -- n )
s" mpfr_rec_sqrt"  C-word  mpfr_rec_sqrt   ( a a n -- n )
s" mpfr_cbrt"      C-word  mpfr_cbrt       ( a a n -- n )
s" mpfr_root"      C-word  mpfr_root       ( a a n n -- n )

s" mpfr_pow"       C-word  mpfr_pow        ( a a a n -- n )
s" mpfr_pow_ui"    C-word  mpfr_pow_ui     ( a a n n -- n )
s" mpfr_pow_si"    C-word  mpfr_pow_si     ( a a n n -- n )
s" mpfr_pow_z"     C-word  mpfr_pow_z      ( a a a n -- n )
s" mpfr_ui_pow_ui" C-word  mpfr_ui_pow_ui  ( a n n n -- n )
s" mpfr_ui_pow"    C-word  mpfr_ui_pow     ( a n a n -- n )

s" mpfr_neg"       C-word  mpfr_neg        ( a a n -- n )
s" mpfr_abs"       C-word  mpfr_abs        ( a a n -- n )

s" mpfr_dim"       C-word  mpfr_dim        ( a a a n -- n )

s" mpfr_mul_2ui"   C-word  mpfr_mul_2ui    ( a a n n -- n )
s" mpfr_mul_2si"   C-word  mpfr_mul_2si    ( a a n n -- n )
s" mpfr_div_2ui"   C-word  mpfr_div_2ui    ( a a n n -- n )
s" mpfr_div_2si"   C-word  mpfr_div_2si    ( a a n n -- n )

\ 5.6 Comparison

s" mpfr_cmp"       C-word  mpfr_cmp        ( a a -- n )
s" mpfr_cmp_ui"    C-word  mpfr_cmp_ui     ( a n -- n )
s" mpfr_cmp_si"    C-word  mpfr_cmp_si     ( a n -- n )
s" mpfr_cmp_d"     C-word  mpfr_cmp_d      ( a r -- n )

\ s" mpfr_cmp_ld"  C-word  mpfr_cmp_ld     ( a ld -- n ) \ long double not supported

s" mpfr_eq"        C-word  mpfr_eq         ( a a n -- n )
s" mpfr_cmp_z"     C-word  mpfr_cmp_z      ( a a -- n )
s" mpfr_cmp_q"     C-word  mpfr_cmp_q      ( a a -- n )
s" mpfr_cmp_f"     C-word  mpfr_cmp_f      ( a a -- n )

s" mpfr_cmp_ui_2exp" C-word  mpfr_cmp_ui_2exp  ( a n  n -- n )
s" mpfr_cmp_si_2exp" C-word  mpfr_cmp_si_2exp  ( a n  n -- n )

s" mpfr_cmpabs"      C-word  mpfr_cmpabs   ( a a -- n )

s" mpfr_nan_p"       C-word  mpfr_nan_p    ( a -- n )
s" mpfr_inf_p"       C-word  mpfr_inf_p    ( a -- n )
s" mpfr_number_p"    C-word  mpfr_number_p ( a -- n )
s" mpfr_zero_p"      C-word  mpfr_zero_p   ( a -- n )
s" mpfr_regular_p"   C-word  mpfr_regular_p ( a -- n )
s" mpfr_sgn"         C-word  mpfr_sgn      ( -- n )

s" mpfr_greater_p"      C-word  mpfr_greater_p       ( a a -- n )
s" mpfr_greaterequal_p" C-word  mpfr_greaterequal_p  ( a a -- n )
s" mpfr_less_p"         C-word  mpfr_less_p          ( a a -- n )
s" mpfr_lessequal_p"    C-word  mpfr_lessequal_p     ( a a -- n )
s" mpfr_equal_p"        C-word  mpfr_equal_p         ( a a -- n )
s" mpfr_lessgreater_p"  C-word  mpfr_lessgreater_p   ( a a -- n )
s" mpfr_unordered_p"    C-word  mpfr_unordered_p     ( a a -- n )


\ 5.7 Special Functions

s" mpfr_log"         C-word  mpfr_log       ( a a n -- n )
s" mpfr_log2"        C-word  mpfr_log2      ( a a n -- n )
s" mpfr_log10"       C-word  mpfr_log10     ( a a n -- n )
s" mpfr_exp"         C-word  mpfr_exp       ( a a n -- n )
s" mpfr_exp2"        C-word  mpfr_exp2      ( a a n -- n )
s" mpfr_exp10"       C-word  mpfr_exp10     ( a a n -- n )
s" mpfr_cos"         C-word  mpfr_cos       ( a a n -- n )
s" mpfr_sin"         C-word  mpfr_sin       ( a a n -- n )
s" mpfr_tan"         C-word  mpfr_tan       ( a a n -- n )
s" mpfr_sin_cos"     C-word  mpfr_sin_cos   ( a a a n -- n )
s" mpfr_sec"         C-word  mpfr_sec       ( a a n -- n )
s" mpfr_csc"         C-word  mpfr_csc       ( a a n -- n )
s" mpfr_cot"         C-word  mpfr_cot       ( a a n -- n )
s" mpfr_acos"        C-word  mpfr_acos      ( a a n -- n )
s" mpfr_asin"        C-word  mpfr_asin      ( a a n -- n )
s" mpfr_atan"        C-word  mpfr_atan      ( a a n -- n )
s" mpfr_atan2"       C-word  mpfr_atan2     ( a a a n -- n )
s" mpfr_cosh"        C-word  mpfr_cosh      ( a a n -- n )
s" mpfr_sinh"        C-word  mpfr_sinh      ( a a n -- n )
s" mpfr_tanh"        C-word  mpfr_tanh      ( a a n -- n )
s" mpfr_sinh_cosh"   C-word  mpfr_sinh_cosh ( a a a n -- n )
s" mpfr_sech"        C-word  mpfr_sech      ( a a n -- n )
s" mpfr_csch"        C-word  mpfr_csch      ( a a n -- n )
s" mpfr_coth"        C-word  mpfr_coth      ( a a n -- n )
s" mpfr_acosh"       C-word  mpfr_acosh     ( a a n -- n )
s" mpfr_asinh"       C-word  mpfr_asinh     ( a a n -- n )
s" mpfr_atanh"       C-word  mpfr_atanh     ( a a n -- n )
s" mpfr_fac_ui"      C-word  mpfr_fac_ui    ( a n n -- n )
s" mpfr_log1p"       C-word  mpfr_log1p     ( a a n -- n )
s" mpfr_expm1"       C-word  mpfr_expm1     ( a a n -- n )
s" mpfr_eint"        C-word  mpfr_eint      ( a a n -- n )
s" mpfr_li2"         C-word  mpfr_li2       ( a a n -- n )
s" mpfr_gamma"       C-word  mpfr_gamma     ( a a n -- n )
s" mpfr_lngamma"     C-word  mpfr_lngamma   ( a a n -- n )
s" mpfr_lgamma"      C-word  mpfr_lgamma    ( a a a n -- n )
s" mpfr_digamma"     C-word  mpfr_digamma   ( a a n -- n )
s" mpfr_zeta"        C-word  mpfr_zeta      ( a a n -- n )
s" mpfr_zeta_ui"     C-word  mpfr_zeta_ui   ( a n n -- n )
s" mpfr_erf"         C-word  mpfr_erf       ( a a n -- n )
s" mpfr_erfc"        C-word  mpfr_erfc      ( a a n -- n )
s" mpfr_j0"          C-word  mpfr_j0        ( a a n -- n )
s" mpfr_j1"          C-word  mpfr_j1        ( a a n -- n )
s" mpfr_jn"          C-word  mpfr_jn        ( a n a n -- n )
s" mpfr_y0"          C-word  mpfr_y0        ( a a n -- n )
s" mpfr_y1"          C-word  mpfr_y1        ( a a n -- n )
s" mpfr_yn"          C-word  mpfr_yn        ( a n a n -- n )
s" mpfr_fma"         C-word  mpfr_fma       ( a a a a n -- n )
s" mpfr_fms"         C-word  mpfr_fms       ( a a a a n -- n )
s" mpfr_agm"         C-word  mpfr_agm       ( a a a n -- n )
s" mpfr_hypot"       C-word  mpfr_hypot     ( a a a n -- n )
s" mpfr_ai"          C-word  mpfr_ai        ( a a n -- n )

s" mpfr_const_log2"    C-word  mpfr_const_log2    ( a n -- n )
s" mpfr_const_pi"      C-word  mpfr_const_pi      ( a n -- n )
s" mpfr_const_euler"   C-word  mpfr_const_euler   ( a n -- n )
s" mpfr_const_catalan" C-word  mpfr_const_catalan ( a n -- n )

s" mpfr_free_cache"    C-word  mpfr_free_cache    ( -- )

s" mpfr_sum"           C-word  mpfr_sum           ( a a n n -- n )

\ 5.8 Input and output

s" __gmpfr_out_str"      C-word  mpfr_out_str     ( a n n a n -- n )
s" __gmpfr_inp_str"      C-word  mpfr_inp_str     ( a a n n -- n )

\ 5.9 Formatted Output

\ 5.10 Integer and Remainder Related Functions

s" mpfr_rint"        C-word  mpfr_rint    ( a a n -- n )
s" mpfr_ceil"        C-word  mpfr_ceil    ( a a -- n )
s" mpfr_floor"       C-word  mpfr_floor   ( a a -- n )
s" mpfr_round"       C-word  mpfr_round   ( a a -- n )
s" mpfr_trunc"       C-word  mpfr_trunc   ( a a -- n )

s" mpfr_rint_ceil"   C-word  mpfr_rint_ceil   ( a a n -- n )
s" mpfr_rint_floor"  C-word  mpfr_rint_floor  ( a a n -- n )
s" mpfr_rint_round"  C-word  mpfr_rint_round  ( a a n -- n )
s" mpfr_rint_trunc"  C-word  mpfr_rint_trunc  ( a a n -- n )

s" mpfr_frac"        C-word  mpfr_frac        ( a a n -- n )

s" mpfr_modf"        C-word  mpfr_modf        ( a a a n -- n )

s" mpfr_fmod"        C-word  mpfr_fmod        ( a a a n -- n )
s" mpfr_remainder"   C-word  mpfr_remainder   ( a a a n -- n )
s" mpfr_remquo"      C-word  mpfr_remquo      ( a a a a n -- n )

s" mpfr_integer_p"   C-word  mpfr_integer_p   ( a -- n )

\ 5.11 Rounding Related Functions

s" mpfr_set_default_rounding_mode"  C-word  mpfr_set_default_rounding_mode  ( n -- )
s" mpfr_get_default_rounding_mode"  C-word  mpfr_get_default_rounding_mode  ( -- n )

s" mpfr_prec_round"  C-word  mpfr_prec_round  ( a n n -- n )
s" mpfr_can_round"   C-word  mpfr_can_round   ( a n n n n -- n )

s" mpfr_min_prec"    C-word  mpfr_min_prec    ( a -- n )

s" mpfr_print_rnd_mode"  C-word  mpfr_print_rnd_mode  ( n -- a )

\ 5.12 Miscellaneous Functions

s" mpfr_nexttoward"  C-word  mpfr_nexttoward   ( a a -- )
s" mpfr_nextabove"   C-word  mpfr_nextabove    ( a -- )
s" mpfr_nextbelow"   C-word  mpfr_nextbelow    ( a -- )

s" mpfr_min"         C-word  mpfr_min          ( a a a n -- n )
s" mpfr_max"         C-word  mpfr_max          ( a a a n -- n )

s" mpfr_urandomb"    C-word  mpfr_urandomb     ( a a -- n )
s" mpfr_urandom"     C-word  mpfr_urandom      ( a a n -- n )

s" mpfr_get_exp"     C-word  mpfr_get_exp      ( a -- n )
s" mpfr_set_exp"     C-word  mpfr_set_exp      ( a n -- n )

s" mpfr_signbit"     C-word  mpfr_signbit     ( a -- n )
s" mpfr_setsign"     C-word  mpfr_setsign     ( a a n n -- n )
s" mpfr_copysign"    C-word  mpfr_copysign    ( a a a n -- n )

s" mpfr_get_version"  C-word  mpfr_get_version  ( -- a )

\ 5.13 Exception Related Functions

s" mpfr_get_emin"         C-word  mpfr_get_emin          ( -- n )
s" mpfr_get_emax"         C-word  mpfr_get_emax          ( -- n )

s" mpfr_set_emin"         C-word  mpfr_set_emin          ( n -- n )
s" mpfr_set_emax"         C-word  mpfr_set_emax          ( n -- n )

s" mpfr_get_emin_min"     C-word  mpfr_get_emin_min      ( -- n )
s" mpfr_get_emin_max"     C-word  mpfr_get_emin_max      ( -- n )
s" mpfr_get_emax_min"     C-word  mpfr_get_emax_min      ( -- n )
s" mpfr_get_emax_max"     C-word  mpfr_get_emax_max      ( -- n )

s" mpfr_check_range"      C-word  mpfr_check_range       ( a n n -- n )
s" mpfr_subnormalize"     C-word  mpfr_subnormalize      ( a n n -- n )

s" mpfr_clear_underflow"  C-word  mpfr_clear_underflow   ( -- )
s" mpfr_clear_overflow"   C-word  mpfr_clear_overflow    ( -- )
s" mpfr_clear_nanflag"    C-word  mpfr_clear_nanflag     ( -- )
s" mpfr_clear_inexflag"   C-word  mpfr_clear_inexflag    ( -- )
s" mpfr_clear_erangeflag" C-word  mpfr_clear_erangeflag  ( -- )

s" mpfr_set_underflow"    C-word  mpfr_set_underflow     ( -- )
s" mpfr_set_overflow"     C-word  mpfr_set_overflow      ( -- )
s" mpfr_set_nanflag"      C-word  mpfr_set_nanflag       ( -- )
s" mpfr_set_inexflag"     C-word  mpfr_set_inexflag      ( -- )
s" mpfr_set_erangeflag"   C-word  mpfr_set_erangeflag    ( -- )

s" mpfr_clear_flags"      C-word  mpfr_clear_flags       ( -- )

s" mpfr_underflow_p"      C-word  mpfr_underflow_p       ( -- n )
s" mpfr_overflow_p"       C-word  mpfr_overflow_p        ( -- n )
s" mpfr_nanflag_p"        C-word  mpfr_nanflag_p         ( -- n )
s" mpfr_inexflag_p"       C-word  mpfr_inexflag_p        ( -- n )
s" mpfr_erangeflag_p"     C-word  mpfr_erangeflag_p      ( -- n )

\ 5.14 Compatibility With MPF

s" mpfr_reldiff"          C-word  mpfr_reldiff           ( a a a n -- )

\ 5.15 Custom Interface


also forth definitions

