\ simple-typeset-x11.4th
\
\ Simplified typesetting of text in X11 windows.
\
\   Copyright (c) 2012--2020 Krishna Myneni
\
\   This code may be used for any purpose, provided the copyright
\   notice above is included.
\
\ Provides:
\
\   draw-centered-text  ( y caddr u -- )
\   place-centered-text ( n caddr u -- )
\   draw-hbox-wrapped-text ( x y w caddr u -- )
\
\ Requires:
\
\   font-strings-x11.4th
\   simple-graphics-x11.4th
\   simple-fonts-x11.4th
\

Module: simple-typeset-x11

Also font-strings-x11
Also simple-graphics-x11
Also simple-fonts-x11

Begin-Module

variable cx0
variable cy0
variable cx
variable cy

Public:

\ Compute the vertical window coordinate for the nth line of
\ text in the current font. The first line is n=1, placed at the
\ top of the window.
: line>y ( n -- y ) 
    1- 0 max current-font-height * current-font-ascent + ;


: draw-centered-text ( y caddr u -- )
    dup 0> invert IF drop 2drop EXIT THEN
    2>r cy0 ! 2r@ get-string-box drop    \ strwidth  R: caddr u
    get-window-size drop                 \ strwidth winwidth
    2dup > IF  2drop 0 
    ELSE       swap - 2/ 
    THEN  cy0 @ 2r> draw-text
;

\ Display text, centered horizontally in the window, on the
\ nth line from the top of window. The first line is n=1.

: place-centered-text ( n caddr u -- )  
    2>r line>y 2r> draw-centered-text ;

Private:

variable hbox_w     \ horizontal box width  (pix)

variable i_start
variable i_left
variable i_right

\ Adjust count of a string to the nearest word boundary. For a string,
\ (caddr umax), starting at the position u1, look towards both the
\ beginning of the string and towards the end of the string to find the
\ nearest word boundary. Return the left substring which breaks at the
\ end of a word, closest in size to (caddr u1).
: adjust-to-word ( caddr u1 umax -- caddr u2 )
    >r dup i_start !
    2dup 2>r           \ caddr u1   R: umax caddr u1
    \ Find word boundary towards beginning of string
    BEGIN  
      dup 0> >r     
      2dup + c@ 32 <>
      r> and
    WHILE  1- REPEAT
    i_left ! drop
    2r>                \ caddr u1  R: umax
\ ." Left i: " i_left ? cr
    \ Find word boundary towards end of string
    BEGIN
      dup r@ < >r
      2dup + c@ 32 <>
      r> and
    WHILE 1+ REPEAT
    i_right !
    r> drop
\ ." Right i: " i_right ? cr
    i_left @ 0= IF  i_right @ EXIT  THEN  \ no word break towards beg.

    \ Always choose to underfill box when there is a word break
    dup i_right @ get-string-box drop hbox_w @ > IF
      i_left @ EXIT
    THEN

    i_start @  i_left  @ -
    i_right @  i_start @ -
    > IF  i_right @  ELSE  i_left @  THEN
;

\ Split a line of text at the break where one line fits 
\ approximately within the current hbox.
: hbox-split ( caddr1 u1 -- caddr1 u1p caddr2 u2 )
    2dup  
    2dup get-string-box drop hbox_w @ <= IF
      dup /string
    ELSE
      2dup   \ caddr1 u1 caddr1 u1 caddr1 u1
      BEGIN
        2dup get-string-box drop 
        dup hbox_w @ >    \ caddr1 u1 caddr1 u1 caddr1 u2 swidth flag
      WHILE
        \ caddr1 u1 caddr1 u1 caddr1 u2 swidth
        >r hbox_w @ r> */
      REPEAT
      drop nip  \ caddr1 u1 caddr1 u1 u2
      swap adjust-to-word  \ caddr1 u1 caddr1 u1p
      dup >r 2swap r> 1+ /string 0 max
    THEN
\ ." remaining: " dup . cr
;

Public:

\ Draw text starting at the specified window position, within
\ box of horizontal width, w, wrapping it as needed to show the
\ text in the current font. There is no guarantee that text
\ will not overflow the hbox on the right, but the algorithm will
\ try to minimize the overflow. The text is left-aligned to the hbox.
: draw-hbox-wrapped-text ( x y w caddr u -- )
    dup 0> invert IF 2drop drop 2drop EXIT THEN
    2>r
    \ Check valid box width 
    dup 0> invert IF drop 2drop 2r> 2drop EXIT THEN hbox_w ! 
    current-font-ascent + cy0 ! cx0 !
    2r@ get-string-box drop
    hbox_w @ < IF
      cx0 @ cy0 @ 2r> draw-text
    ELSE
      cy0 @ cy !    \ --  ; R: caddr u
      BEGIN
        2r> hbox-split 2>r
        dup IF cx0 @ cy @ 2swap draw-text  ELSE 2drop  THEN
        cy @ current-font-height + cy !
        2r@ nip 0=
      UNTIL
      2r> 2drop
    THEN
;

End-Module

