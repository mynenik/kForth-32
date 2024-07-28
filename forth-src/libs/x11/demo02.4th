\ demo02.4th 
\
\  Demonstrate refreshed drawing and event handling in X.
\
\ Copyright (c) 2009--2020 Krishna Myneni
\
\ This code may be used for any purpose provided the copyright notice
\ above is preserved.
\
include ans-words
include modules
include syscalls
include mc
include asm
include strings
include random
include lib-interface
include libs/x11/libX11

Also X11

\ ---- Random number generation utilities
-1 0 d>f fconstant RAND_SCALE
: ran0 ( -- f )
    random2 s>f RAND_SCALE f/ 0.5e f+ ;

: rnd() ( n -- f | return random number between 0e0 and [n]e0 )
    s>f ran0 f* ;

time&date 2drop 2drop + seed !
\ -----------------


: 3dup  dup 2over rot ;
: 3drop 2drop drop ;
[UNDEFINED] uw@ [IF]
: uw@   dup c@ swap 1+ c@ 8 lshift or ;
[THEN]

XPoint% %size constant XPT_SIZE
: XPoint! ( nx ny apoint -- )
   rot over XPoint->x w! XPoint->y w! ;
: XPoints! ( x1 y1 ... xn yn  n apoints -- )
    over 1- XPT_SIZE * +
    swap 0 ?DO  dup >r XPoint! r> XPT_SIZE - LOOP drop ;

0 value screen_num     \ number of screen to place the window on.
0 value win            \ window ID of the newly created window.
0 value root_win       \ parent window of new window
0 value gc             \ GC (graphics context) used for drawing in our window.
0 value colormap
0 value width
0 value height         \ height and width for the new window.
0 value xc
0 value yc             \ center coordinates of new window
variable display       \ pointer to X Display structure.
variable gcvalues
0 value colormap

XColor col_exact
0 value red
0 value pink
0 value green
0 value yellow
0 value orange
0 value blue
0 value SkyBlue
0 value black
0 value white

false value smile
XEvent event

\ Allocate a color
: get-color ( addr u -- pixel )
    $>zstr display @ colormap rot col_exact XParseColor
    IF
      display @ colormap col_exact XAllocColor drop
      col_exact XColor->pixel @
    ELSE 
      cr ." Failed to lookup color"
      black
    THEN
;

\ Allocate our colors
: get-colors ( -- )
    s" red"    get-color to  red
    s" pink"   get-color to  pink
    s" green"  get-color to  green
    s" yellow" get-color to  yellow
    s" orange" get-color to  orange
    s" blue"   get-color to  blue
    s" SkyBlue" get-color to SkyBlue
;

\ Show info on a mouse button press event
: button-press-info ( -- )
    cr ." Button "
    event XButtonEvent->button ? ." pressed at x = "
    event XButtonEvent->x ? ."  y = " event XButtonEvent->y ?
;

\ Show info on a keypress event
: key-press-info ( -- )
    cr ." Key pressed with keycode = " event XKeyEvent->keycode ? 
    ."  at time " event XKeyEvent->time ? ." ms"
;

\ Set the foreground color
: foreground ( pixelval -- )
    >r display @ gc r> XSetForeground drop ;

\ Draw a filled circle, centered at x, y, with radius r
: filled-circle ( nx ny nr -- )
    dup >r - swap r@ - swap 2>r 
    display @ win gc 2r> r> 2* dup 0 360 64 * XFillArc drop ;

\ Apply coordinate offsets: x' = x + dx, y' = y + dy
: offset-xy ( nx ny ndx ndy -- nx' ny' )
    rot + >r + r> ;

\ Draw a star as four filled triangles; the first point of each
\   triangle is a common point for the star and must be set to the 
\   absolute position of the star
create star-points XPT_SIZE 12 * allot
\ star triangle 1
 0   0
 0 -12
 8  16
\ star triangle 2
 0   0
 0  -6
10   0
\ star triangle 3
 0   0
 0 -12
-8  16
\ star triangle 4
 0   0
 0  -6
-10  0
12 star-points XPoints!

\ Draw a star at specified window coordinates
0 value star_x
0 value star_y
: star ( x y -- )
    to star_y  to star_x
    pink foreground
    display @ win gc
    4 0 DO
      \ set first point for each filled triangle
      star_x star_y star-points I 3 * XPT_SIZE * + XPoint!  
      3dup star-points I 3 * XPT_SIZE * + 3 NonConvex CoordModePrevious XFillPolygon drop
    LOOP
    3drop ;


\ Draw u stars at random locations within the upper half of the window
: stars ( u -- )
    0 ?DO
      width rnd() fround>s  yc height 2/ rnd() fround>s - star
    LOOP
;


: rainbow ( -- )
    display @ gc 5 LineSolid CapRound JoinRound XSetLineAttributes drop
    display @ win gc
    3dup red    foreground  0 0  width      height      0 180 64 * XDrawArc drop
    3dup orange foreground  5 0  width 10 - height  5 - 0 180 64 * XDrawArc drop
    3dup yellow foreground 10 0  width 20 - height 10 - 0 180 64 * XDrawArc drop
    3dup green  foreground 15 0  width 30 - height 15 - 0 180 64 * XDrawArc drop
    3dup blue   foreground 20 0  width 40 - height 20 - 0 180 64 * XDrawArc drop
    3drop
    display @ gc 1 LineSolid CapRound JoinRound XSetLineAttributes drop
;

: smiley-face ( x y -- )
    2>r
    yellow foreground 
    2r@ 15 filled-circle  \ head
    black  foreground
    2r@ -6 -4 offset-xy 5 filled-circle  \ left eye
    2r@  6 -4 offset-xy 5 filled-circle  \ right eye
    display @ win gc 2r@
    smile IF
       -10 -10 offset-xy 20 20 220 64 * 100 64 *   \ smiley mouth 
    ELSE
       -10   5 offset-xy 20 20 40 64 * 100 64 *    \ frowney mouth
    THEN
    XDrawArc drop
    2r> 2drop
;

: redraw-window ( -- )
    width 2/ to xc
    height 2/ to yc

    display @ win XClearWindow drop

    20 stars
    rainbow

    xc yc 70 - smiley-face
    xc 100 - yc smiley-face
    xc yc 70 + smiley-face
    xc 100 + yc smiley-face
 
;


: demo ( -- )
			
    \ open connection with the X server.
    s" :0.0" $>zstr XOpenDisplay dup display !
    0= IF
      cr ." cannot connect to X server" cr
      ABORT
    THEN

    \ get the default colormap and window size for our display.
    display @ XDefaultScreen to screen_num
    display @ screen_num
    2dup  XDisplayWidth  4 / to width 
    2dup  XDisplayHeight 4 / to height
    2dup  XBlackPixel to black
    2dup  XWhitePixel to white
    2dup  XDefaultColormap to colormap
    2dup  XRootWindow to root_win
    2drop
    get-colors

    display @  root_win  0 0  width height  0  black  SkyBlue
    XCreateSimpleWindow  to win

    \ Obtain MapNotify, Key press, Button press, Window resize, and
    \ Window destroy events
    display @ win
    ExposureMask KeyPressMask or ButtonPressMask or
    StructureNotifyMask or EnterWindowMask or LeaveWindowMask or
    XSelectInput drop

    \ make the window actually appear on the screen. 
    display @ win XMapWindow drop

    \ allocate a new GC (graphics context) for drawing in the window.
    display @ win 0 gcvalues XCreateGC to gc
    gc 0< ABORT" Unable to create the graphics context!"
    display @ gc FillSolid  XSetFillStyle drop

    \ flush all pending requests to the X server.
    display @ XFlush drop
    display @ false XSync drop

    \ Event loop
    BEGIN
      display @ event XNextEvent drop
      event @ 
      CASE
        Expose        OF  redraw-window      ENDOF
        ButtonPress   OF  button-press-info  ENDOF
        KeyPress      OF  key-press-info     ENDOF
        ConfigureNotify OF 
                     event XConfigureRequestEvent->width @ to width
                     event XConfigureRequestEvent->height @ to height
                     ENDOF 
        EnterNotify   OF   true  to smile  redraw-window    ENDOF
        LeaveNotify   OF   false to smile  redraw-window    ENDOF
      ENDCASE
      event @ Keypress =
    UNTIL

    \ close the connection to the X server.
    display @ gc XFreeGC drop
    display @ XCloseDisplay drop
;

demo

