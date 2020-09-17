\ banner-x11.4th
\
\ Display an animated message in an X11 Window.
\
\ The default message is "Happy Mother's Day" -- tailor as desired.
\
\ Copyright (c) 2012--2020 Krishna Myneni
\
\
include ans-words
include modules
include syscalls
include mc
include asm
include strings
include utils
include lib-interface
include libs/x11/libX11
include x11/font-strings-x11
include x11/simple-graphics-x11
include x11/simple-fonts-x11
include x11/simple-frames-x11

Also font-strings-x11
Also simple-graphics-x11
Also simple-fonts-x11
Also simple-frames-x11


s" Happy Mother's Day, Rama" $constant $message


8 constant ncolors
-1e facos fconstant pi
pi 3e f* fconstant XMAX
XMAX 2e f/ fconstant XMAX2

fvariable dx
create ypos[ 2048 cells allot
create colors[ ncolors cells allot

: ]@ ( a u -- n ) cells + @ ;
: ]! ( n a u -- ) cells + ! ;

s" pink" $constant $BKG_COLOR
0 value bkgcolor

: setup-colors ( -- )
    red     colors[ 0 ]!
    blue    colors[ 1 ]!
    green   colors[ 2 ]!
    magenta colors[ 3 ]!
    grey    colors[ 4 ]!
    yellow  colors[ 5 ]!
    cyan    colors[ 6 ]!
    brown   colors[ 7 ]!

    $BKG_COLOR get-color to bkgcolor
    bkgcolor set-window-background
;

\ The curve along which our banner moves is a decaying sine wave. 
: calc-motion-curve ( -- )
    0e -1.1e 10e 1.1e set-window-limits
    XMAX get-window-size drop 
    dup >r s>f f/ dx f!
    0e 
    r> 0 DO
      fdup fdup fsin fover XMAX2 f/ fnegate fexp f*
      uc>wc ypos[ I ]! drop
      dx f@ f+
    LOOP
    fdrop

    setup-colors
    extra-graphics-setup
;

variable wdx
variable xpos
true value use_colors?

: .message ( -- ) 
    $message
    0 DO
      use_colors? IF
        colors[ I ncolors mod ]@ foreground
      THEN
      dup >r
      xpos @ ypos[ over ]@ r> 1 draw-text
      wdx @ xpos +!
      1+
    LOOP
    drop ; 
   
: frame1 ( -- )
    clear-window
    bold italic 240 TextFonts1 select-font

    $message 2dup get-string-box drop
    swap / 1+ 2* wdx ! drop
    10
    BEGIN
      dup xpos ! true to use_colors?  .message
      flush-window
      80000 usleep
      dup xpos ! false to use_colors?  bkgcolor foreground  .message
      10000 usleep
      wdx @ 4 / +
      dup get-window-size drop  >
    UNTIL
    drop
    1000000 usleep
    exit-simple-graphics
;

' frame1
1 set-frames
' calc-motion-curve IS user-graphics-init
start-frames
