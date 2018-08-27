\ demo-xft-telugu.4th 
\
\ Demonstrate use of Xft library for UTF-8 telugu alphabet rendering.
\
\ Krishna Myneni, Creative Consulting
\   for Research & Education,  http://ccreweb.org
\
\ Revisions:
\   2017-05-01  km  based on kForth's libs/x11/demo-xft.4th
\   2017-05-03  km  regular grid layout for alphabet

include ans-words
include asm
include strings
include files
include utils
include speech
include lib-interface
include libs/x11/libX11
include libs/x11/libXft

Also X11
Also Xft

1 constant DEFAULT_BDWIDTH  \ border width

\ utf-8 encodings
z" అఆఇఈఉఊఋఌఎఏఐఒఓఔౠౡకఖగఘఙచఛజఝఞటఠడఢణతథదధనపఫబభమయరఱలళవశషసహ" 
ptr telugu_alphabet

\ sounds for festival text to speech synthesizer
c" aaahh"
c" aaaahh"
c" eeee"
c" eeeee"
c" oooh"
c" ooooh"
c" roo"
7 table alphabet_sounds

z" కఁకంకఃకాకికీకుకూకృకౄకెకైకొకోకౌక్కౕకౖ" ptr telugu_diacritics 
\ Font
z" Lohit Telugu-18" ptr font_name

0 value   mainW
0 value   screen
0 value   root_win
0 value   visual
0 value   colormap
0 value   font
0 value   ftdraw
0 value   fgpix
0 value   bgpix
0 value   Done

variable  dpy
variable  x
variable  y
variable  w
variable  h
variable  w_cell
variable  h_cell

XRenderColor xrcolor
XftColor     txtcolor
XGlyphInfo   extents
XEvent       event

: alloc-ftcolor ( red green blue alpha acolor -- )
    >r
    xrcolor XRenderColor->alpha w!
    xrcolor XRenderColor->blue  w!
    xrcolor XRenderColor->green w!
    xrcolor XRenderColor->red   w!
    dpy @  visual colormap xrcolor r>  XftColorAllocValue drop    
;

: draw-utf8 ( x y az u -- )
    2>r 2>r
    ftdraw txtcolor font 2r> 2r> XftDrawStringUtf8  ;

variable nchars

: set-max-extents ( az -- )
   dup strlen 3 / nchars !
   0 h ! 0 w !
   nchars @ 0 DO
     dup >r 
     dpy @ font r> 3 extents XftTextExtentsUtf8
     extents XGlyphInfo->height w@ h @ max h !
     extents XGlyphInfo->width  w@ w @ max w !
     3 +
   LOOP
   drop
;

: handle-button ( -- )
    \ get pointer coordinates
    \ convert to grid coordinates
    \ convert to position in alphabet
    \ retrieve speech text for alphabet letter
    \ say the letter
;

: draw-window ( -- )
    dpy @ mainW XClearWindow drop
    telugu_alphabet strlen 3 / nchars !
    telugu_alphabet
    nchars @ 0 ?DO
      I 10 mod w_cell @ * w @ 2/ + x !
      I 10 /   h_cell @ * h @ +  h @ 2/ + y !
      dup >r
      x @ y @ r> 3 draw-utf8 
      3 +
    LOOP
    drop
;

: main ( -- )

   \ open connection to X display
   0 XOpenDisplay dup dpy !
   0= IF  cr ." cannot connect to X server" cr ABORT  THEN
 
   dpy @ XDefaultScreen to screen
   dpy @ screen
   2dup XDefaultVisual   to visual
   2dup XRootWindow      to root_win
   2dup XBlackPixel      to fgpix
   2dup XWhitePixel      to bgpix
   2dup XDefaultColormap to colormap
   2dup font_name  XftFontOpenName to font
   2drop

   telugu_alphabet set-max-extents
   h @ 2* h_cell !
   w @ 2* w_cell !
     
   \ create top level window
   dpy @  root_win 10 10 w_cell @ 10 * h_cell @ 7 *
   DEFAULT_BDWIDTH fgpix bgpix  XCreateSimpleWindow  to mainW

   \ Xft draw context
   dpy @ mainW  visual colormap  XftDrawCreate  to ftdraw

   \ allocate text color
[ HEX ]
\  red  green  blue  alpha
   0     0     ffff  ffff  txtcolor  alloc-ftcolor \ Xft text color
[ DECIMAL ]
   
   \ select inputs
   dpy @ mainW  ExposureMask ButtonPressMask or 
   XSelectInput drop
   
   \ make window visible
   dpy @ mainW XMapWindow drop
   ." click on the window to exit" cr
 
   \ retrieve and process events
   BEGIN
     Done invert
   WHILE 
      dpy @ event XNextEvent drop
      event XAnyEvent->window @ mainW =  IF
         event @
         CASE
            Expose      OF  draw-window   ENDOF
            ButtonPress OF  true to Done ( handle-button) ENDOF
         ENDCASE
      THEN
   REPEAT

   \ close connection to display

   ftdraw  XftDrawDestroy 
   dpy @ visual colormap txtcolor  XftColorFree
   dpy @ mainW XDestroyWindow drop
   dpy @ XCloseDisplay drop         
;

main



