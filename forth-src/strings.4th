\ strings.4th
\
\ String utility words for kForth
\
\ Copyright (c) 1999--2017 Krishna Myneni
\
\ This software is provided under the terms of the
\ GNU General Public License.
\
\ Revisions:
\
\	03-24-1999  created  KM
\	03-25-1999  added number to string conversions  KM
\	08-12-1999  fixed f>string  KM
\	10-11-1999  added blank  KM
\	12-12-1999  fixed f>string for zero case  KM
\	12-22-1999  added -trailing, scan, and skip  KM
\	01-23-2000  replaced char with [char] for ANS Forth compatibility  KM
\	06-16-2000  added isdigit and modified string>s and string>f  KM
\	09-02-2000  fixed u>string to work over full range  KM
\	07-12-2001  used built-in Forth words <# #s #> for conversions,
\	              added ud>string and d>string. f>string now can handle
\                     decimal places greater than 8  KM
\	09-21-2001  changed occurences of DO to ?DO  KM
\	10-02-2001  added parse_args  KM
\	10-10-2001  fixed problem with f>string when number is 0e  KM
\	10-15-2001  added /STRING  KM
\	03-28-2002  added SEARCH, PARSE_TOKEN, PARSE_LINE, IS_LC_ALPHA  KM
\	07-31-2002  added SLITERAL; removed SEARCH since SEARCH and
\		      COMPARE are now part of kForth  KM
\       28-03-2008  removed SLITERAL, now intrinsic to kForth KM
\       19-09-2009  removed BLANK, now intrinsic to kForth  KM
\       26-09-2009  removed /STRING, now intrinsic to kForth  KM
\       01-10-2009  revised definition of STRLEN  KM
\       11-24-2009  revised definitions of -trailing, scan, skip,
\                     is_lc_alpha, and is_digit  KM
\       12-02-2009  removed -TRAILING, now intrinsic to kForth  KM
\       04-17-2017  added STRING>UD and STRING>D ; rewrote
\                     STRING>F using >FLOAT km
\       04-30-2017  fixed F>STRING for deprecated word, "
\       07-25-2017  added F>FPSTR and F.RD  km

BASE @
DECIMAL

: scan ( a1 n1 c -- a2 n2 | search for first occurence of character c )
	\ a1 n1 are the address and count of the string to be searched, 
	\ a2 n2 are the address and count of the substring starting with character c
	over 0> IF
	  over 0 DO   \ -- a1 n1 c
	    >r over c@ r@ = 
	    IF  r> leave  ELSE  1 /string  r>  THEN
	  LOOP
	THEN
	drop ;

: skip ( a1 n1 c -- a2 n2 | search for first occurence of character not equal to c )
	\ a1 n1 are the address and count of the string to be searched,
	\ a2 n2 are the adress and count of the substring
	over 0> IF
	  over 0 DO  \ -- a1 n1 c
	    >r over c@ r@ <> 
	    IF  r> leave  ELSE  1 /string r>  THEN
	  LOOP
	THEN
	drop ; 


: parse_token ( a u -- a2 u2 a3 u3)
	\ parse next token from the string; a3 u3 is the token string
	BL SKIP 2DUP BL SCAN 2>R R@ - 2R> 2SWAP ;

: parse_line ( a u -- a1 u1 a2 u2 ... n )
	( -trailing)
	0 >r
	begin
	  parse_token
	  dup
	while
	  r> 1+ >r
	  2swap
	repeat  
	2drop 2drop r> ;

: is_lc_alpha ( u -- flag | true if u is a lower case alphabetical character)
	[char] a [ char z 1+ ] literal within ;	
	
: isdigit ( u -- flag | return true if u is ascii value of '0' through '9' )
        [char] 0 [ char 9 1+ ] literal within ;

: strcpy ( ^str addr -- | copy a counted string to addr )
	>r dup c@ 1+ r> swap cmove ;

\ Length of a null-terminated string
: strlen ( addr -- len )
        0
        begin over c@
        while 1+ >r 1+ r>
        repeat
        nip ;


16384 constant STR_BUF_SIZE
create string_buf STR_BUF_SIZE allot	\ dynamic string buffer
variable str_buf_ptr
string_buf str_buf_ptr !

: adjust_str_buf_ptr ( u -- | adjust pointer to accomodate u bytes )
	str_buf_ptr a@ swap +
	string_buf STR_BUF_SIZE + >=
	if
	  string_buf str_buf_ptr !	\ wrap pointer
	then ;

: strbufcpy ( ^str1 -- ^str2 | copy a counted string to the dynamic string buffer )
	dup c@ 1+ dup adjust_str_buf_ptr
	swap str_buf_ptr a@ strcpy
	str_buf_ptr a@ dup rot + str_buf_ptr ! ;

: strcat ( addr1 u1 addr2 u2 -- addr3 u3 )
	rot 2dup + 1+ adjust_str_buf_ptr 
	-rot
	2swap dup >r
	str_buf_ptr a@ swap cmove
	str_buf_ptr a@ r@ +
	swap dup r> + >r
	cmove 
	str_buf_ptr a@
	dup r@ + 0 swap c!
	dup r@ + 1+ str_buf_ptr !
	r> ;

: strpck ( addr u -- ^str | create counted string )
	255 min dup 1+ adjust_str_buf_ptr 
	dup str_buf_ptr a@ c!
	tuck str_buf_ptr a@ 1+ swap cmove
	str_buf_ptr a@ over + 1+ 0 swap c!
	str_buf_ptr a@
	dup rot 1+ + str_buf_ptr ! ;

\
\ Base 10 number to string conversions and vice-versa
\

32 constant NUMBER_BUF_LEN
create number_buf NUMBER_BUF_LEN allot

create fnumber_buf 64 allot
variable number_sign
variable number_val
variable fnumber_sign
fvariable fnumber_val
fvariable fnumber_divisor
variable fnumber_power
variable fnumber_digits
variable fnumber_whole_part

variable number_count

: u>string ( u -- ^str | create counted string to represent u in base 10 )
    base @ swap decimal 0 <# #s #> strpck swap base ! ;

: ud>string ( ud -- ^str | create counted string to represent ud in base 10 )
    base @ >r decimal <# #s #> strpck r> base ! ;

: string>ud ( ^str -- ud | convert counted string to unsigned double in base 10 )
    count base @ >r decimal 0 0 2swap >number 2drop r> base ! ;

: d>string ( d -- ^str | create counted string to represent d in base 10 )
    dup >r dabs ud>string r> 0< if s" -" rot count strcat strpck then ;

: string>d ( ^str -- d | convert counted string to signed double in base 10 )
    base @ >r decimal number? drop r> base ! ;

: s>string ( n -- ^str | create counted string to represent n in  base 10 )
    dup >r abs u>string r> 0< if 
	  s" -" rot count strcat strpck
    then ;

: string>s ( ^str -- n | always interpret in base 10 )
	0 number_val !
	false number_sign !
	count
	0 ?do
	  dup c@
	  case
	    [char] -  of true number_sign ! endof 
	    [char] +  of false number_sign ! endof 
	    dup isdigit 
	    if
	      dup [char] 0 - number_val @ 10 * + number_val !
	    then
	  endcase
	  1+
	loop
	drop
	number_val @ number_sign @ if negate then ;

\ Convert r to a formatted fixed point string with
\ n decimal places
: f>fpstr ( r n -- a u )
    1 swap dup >r 0 ?do 10 * loop 
    s>f f* fround f>d dup -rot dabs
    <# r> 0 ?do # loop [char] . hold #s rot sign #> ; 

\ Print an fp number as a fixed point string with
\ n decimal places, right-justified in a field of width, w
: f.rd ( r w n -- )
    swap >r f>fpstr r> over - 
    dup 0> IF spaces ELSE drop THEN type ;

\ Convert r to a counted string in scientific notation
\ with n decimal places
: f>string ( r n -- ^str )
	>r fdup f0=
	if
	  f>d <# r> 0 ?do # loop #> s" e0" strcat 
	  s"  0." 2swap strcat strpck exit	  
	then
	r>
	dup 16 swap u< if drop fdrop c" ******" exit then  \ test for invalid n
	fnumber_digits !
	0 fnumber_power !
	fdup 0e f< if true else false then fnumber_sign ! 
	fabs
	fdup 1e f<
	if
	  fdup 0e f>
	  if
	    begin
	      10e f* -1 fnumber_power +!
	      fdup 1e f>=
	    until
	  then
	else
	  fdup 
	  10e f>=
	  if
	    begin
	      10e f/ 1 fnumber_power +!
	      fdup 10e f<
	    until
	  then
	then
	10e fnumber_digits @ s>f f**
	f* floor f>d d>string
	count drop dup fnumber_buf
	fnumber_sign @ 
	if [char] - else bl then 
	swap c!
	fnumber_buf 1+ 1 cmove
	1+
	[char] . fnumber_buf 2+ c!
	fnumber_buf 3 + fnumber_digits @ cmove
	fnumber_buf fnumber_digits @ 3 +	
	s" e" strcat
	fnumber_power @ s>string count strcat
	strpck 	;

	 
: string>f ( ^str -- r )
    count base @ >r decimal >float drop r> base ! ;


: parse_args ( a u -- r1 ... rn n | parse a string delimited by spaces into fp args )
	0 >r 
	2>r
	begin
	  r@ 0>
	while
	  2r> bl skip 
	  2dup 
	  bl scan 2>r
	  r@ - dup 0= 
	  if drop r> 0 >r then
	  strpck string>f
	  2r> r> 
	  1+ >r 2>r
	repeat
	2r> 2drop r> ;

BASE !
