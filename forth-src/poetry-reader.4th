\ poetry-reader.4th
\
\ Displays poems from sequentially numbered text files.
\
\  Copyright (c) 2012 Krishna Myneni, Creative Consulting for
\  Research and Education, http://ccreweb.org
\
\  This code may be used for any purpose, provided the copyright
\  notice above is included.
\
\ Notes:
\
\ 1) Poem file names start with a prefix, configurable using
\    $FILE_PREFIX (see below), concatenated with a 3-digit 
\    index number starting at 001.
\
\ 2) All poem files are located in a specified directory, 
\    $POEMS_DIR (see below).
\
\ 3) The output fonts are configurable -- see POETRY_FONT and
\    the list of common fonts in font-strings-x11.4th
\
\ 4) Currently, the program doesn't handle poems longer than
\    will fit in the window height. It may be generalized to
\    do so, easily.
\
\ Revisions:
\   2012-04-30  km  first version.
\   2012-05-01  km  set window background color (see $BKG_COLOR);
\                   implement +/- key handling for increasing/
\                   decreasing poem-font size, and toggling 
\                   font weight and slant; fixed bug in handling
\                   file not found.
\   2012-06-02  km  put poem title in window name; also exit
\                   Forth system when closing window.
\   2016-06-03  km  updated paths of include files

include ans-words
include modules
include asm
include strings
include files
include utils
include lib-interface
include libs/x11/libX11
include x11/font-strings-x11
include x11/simple-graphics-x11
include x11/simple-fonts-x11
include x11/simple-typeset-x11
include x11/simple-frames-x11

Also simple-graphics-x11
Also font-strings-x11
Also simple-fonts-x11
Also simple-typeset-x11
Also simple-frames-x11

s" poems/" $constant $POEMS_DIR
s" poem"   $constant $FILE_PREFIX

\ Set the desired text font family below

FONT_TIMES_NEW_ROMAN constant POETRY_FONT

\ Load the desired poetry font and check to see if
\ we were successful. If not, fall back to the
\ default text fonts.

0 ptr myFonts
s" wheat" $constant $BKG_COLOR

: set-poetry-font ( -- )
    POETRY_FONT  ExtraFonts  load-font-table
    0 ExtraFonts @font-entry drop
    IF  ExtraFonts  ELSE  TextFonts1  THEN
    to myFonts
    
    \ Other graphics setup
    $BKG_COLOR get-color set-window-background
    extra-graphics-setup
;

\ poem font values
140     value font-ptsize
medium  value font-weight
regular value font-slant

: title-font   ( -- ) bold   regular 240 myFonts select-font ;   
: author-font  ( -- ) bold   italic  180 myFonts select-font ;
: poem-font    ( -- ) font-weight font-slant font-ptsize 
                      myFonts select-font ;

: increase-font-size ( -- )
    font-ptsize
    CASE
      100 OF  120  ENDOF
      120 OF  140  ENDOF
      140 OF  180  ENDOF
      180 OF  240  ENDOF
      dup
    ENDCASE
    to font-ptsize
;

: decrease-font-size ( -- )
    font-ptsize
    CASE
      120 OF  100  ENDOF
      140 OF  120  ENDOF
      180 OF  140  ENDOF
      240 OF  180  ENDOF
      dup
    ENDCASE
    to font-ptsize
;

: toggle-font-weight ( -- )
    font-weight medium = IF bold ELSE medium THEN 
    to font-weight ;

: toggle-font-slant ( -- )
    font-slant regular = IF italic ELSE regular THEN
    to font-slant ;

10 constant EOL
create title    256 allot
create author   256 allot
create poemline 256 allot

\ Determine starting line from top of window, based on poem
\ font point size.
: start-line ( -- u )  font-ptsize negate 4 * 140 / 9 + ;

\ Parse subsequent poem text
: poem
    clear-window 
    EOL parse title pack  refill drop
    EOL parse author pack
    title-font  1 title count place-centered-text
    author-font 3 author count place-centered-text
    poem-font
    start-line
    BEGIN
      dup
      refill drop
      EOL parse poemline pack
      poemline count s" fin" compare
    WHILE
      poemline count place-centered-text
      1+
    REPEAT
    2drop
;

variable poem-number
1 poem-number !

: previous-poem ( -- ) poem-number @ 1- 1 max poem-number ! ;
: next-poem     ( -- ) 1 poem-number +! ;

\ Return the current poem file name
: poem-file-name  ( -- caddr u )
    $POEMS_DIR $FILE_PREFIX strcat
    poem-number @ 0 <# # # # #> strcat s" .txt" strcat
;

: poem-file-exists? ( -- flag )  poem-file-name strpck file-exists ;

HEX
 3d constant Key_plus
 2d constant XK_minus
 62 constant XK_b
 69 constant XK_i
DECIMAL

: key-handler ( -- )
    get-keyinfo
    CASE
      XK_Home      OF  1 poem-number !           ENDOF
      XK_Page_Up   OF  previous-poem             ENDOF
      XK_Page_Down OF  next-poem poem-file-exists?
                       0= IF  previous-poem  THEN
                                                 ENDOF
      XK_b         OF  toggle-font-weight        ENDOF
      XK_i         OF  toggle-font-slant         ENDOF
      Key_plus     OF  increase-font-size        ENDOF
      XK_minus     OF  decrease-font-size        ENDOF
      XK_Escape    OF  exit-simple-graphics EXIT ENDOF
    ENDCASE
    redraw-window
;

: frame1 ( -- ) 
    poem-file-exists? IF 
      poem-file-name included
      title count 2dup set-icon-name set-window-name
    ELSE  
      title-font red foreground 
      3 s" Poem file " poem-file-name strcat s"  not found!"
      strcat place-centered-text
    THEN
;


' frame1
1 set-frames

\ override default handlers provided by simple-frames-x11
' key-handler IS on-keypress
' set-poetry-font IS user-graphics-init
2 1 simple-graphics
bye



