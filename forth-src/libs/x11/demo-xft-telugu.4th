\ demo-xft-telugu.4th 
\
\ Display the Telugu alphabet in a regularly spaced grid,
\ using the Xft library.
\
\ Copyright (c) 2017--2020 Krishna Myneni
\
\ This code may be used for any purpose, provided attribution
\ of the source is included.
\
\ Notes:
\
\   1) The Xft library does not support complex character
\      composition, i.e. rendering characters which are
\      constructed from multiple code points and rules
\      for composing the glyphs. Here, the base characters
\      of the Telugu alphabet, each of which is represented
\      by a single code point, are displayed. Each of these
\      characters has the same UTF-8 encoding length, which
\      is not true for text in Telugu, in general.
\
\   2) This program can be used as a framework for a program
\      to teach the Telugu alphabet, using text or speech.
\      It may also be generalizable to handle other or multiple
\      alphabets which don't require complex character
\      composition.
\
\ References:
\
\ 1. Unicode entity codes for Telugu Script, Penn State
\    University, http://symbolcodes.tlt.psu.edu/bylanguage/teluguchart.html
\

include ans-words
include modules
include syscalls
include mc
include asm
include xchars
include strings
include lib-interface
include libs/x11/libX11
include libs/x11/libXft

true value  XK_MISCELLANY
include libs/x11/keysymdef

Also X11
Also Xft

1 constant DEFAULT_BDWIDTH  \ border width
3 constant BY/CHAR          \ bytes per character for utf-8 encoding

\ utf-8 encoded string containing Telugu alphabet characters.
z" అఆఇఈఉఊఋౠఌౡఎఏఐఒఓఔకఖగఘఙచఛజఝఞటఠడఢణతథదధనపఫబభమయరఱలళవశషసహ" 
ptr telugu_alphabet

\ Font
z" Lohit Telugu-24" ptr font_name

0 value   mainW
0 value   screen
0 value   root_win
0 value   visual
0 value   colormap
0 value   font
0 value   ftdraw

0 value   Done

variable  dpy
variable  w        \ max character width
variable  h        \ max character height
variable  w_cell   \ grid cell width
variable  h_cell   \ grid cell height
variable  nx_grid  \ number of horizontal grid cells
variable  ny_grid  \ number of vertical grid cells
variable  nameW    \ window name

XTextProperty name_prop
XRenderColor  xrcolor
XftColor      txtcolor
XGlyphInfo    extents
XEvent        event

: alloc-ftcolor ( red green blue alpha acolor -- )
    >r
    xrcolor XRenderColor->alpha w!
    xrcolor XRenderColor->blue  w!
    xrcolor XRenderColor->green w!
    xrcolor XRenderColor->red   w!
    dpy @  visual colormap xrcolor r>  XftColorAllocValue drop    
;

: set-max-extents ( az -- )
   0 h ! 0 w !
   dup ( strlen BY/CHAR /) dup strlen xc-len
   0 DO
     dup >r 
     dpy @ font r> BY/CHAR extents XftTextExtentsUtf8
     extents XGlyphInfo->height w@ h @ max h !
     extents XGlyphInfo->width  w@ w @ max w !
     BY/CHAR +
   LOOP
   drop
;

: draw-utf8 ( x y az u -- )
    2>r 2>r
    ftdraw txtcolor font 2r> 2r> XftDrawStringUtf8  ;

: draw-letter ( u -- )
    >r
    r@ nx_grid @ mod w_cell @ * w @ 2/ +         \ x
    r@ nx_grid @ /   h_cell @ * h @ +  h @ 2/ +  \ y
    telugu_alphabet 
    r> BY/CHAR * + BY/CHAR draw-utf8
;


\ Event Handlers

: on-keypress ( -- )
    dpy @  event XKeyEvent->keycode @  0 XKeyCodeToKeysym
    XK_Escape = to Done ;

: on-buttonpress ( -- )
;

: on-pointermove ( -- )
;

: resize-grid ( w h -- )
    h_cell @ / 1 max ny_grid !
    w_cell @ / 1 max nx_grid !
;

: draw-window ( -- )
    dpy @ mainW XClearWindow drop
    telugu_alphabet strlen BY/CHAR / 
    0 ?DO  I draw-letter  LOOP
;

HEX
0       constant  FG_COLOR  
E0E0E0  constant  BG_COLOR
DECIMAL

: telugu ( -- )

   \ open connection to X display
   0 XOpenDisplay dup dpy !
   0= IF  cr ." cannot connect to X server" cr ABORT  THEN
 
   dpy @ XDefaultScreen to screen
   dpy @ screen
   2dup XDefaultVisual   to visual
   2dup XRootWindow      to root_win
   2dup XDefaultColormap to colormap
   2dup font_name  XftFontOpenName to font
   2drop

   \ set grid cell dims from max height and width of chars
   telugu_alphabet set-max-extents
   h @ 2* h_cell !
   w @ 2* w_cell !

   \ initial grid layout
   6 nx_grid !  10 ny_grid !
  
   \ create top level window
   dpy @  root_win 10 10 w_cell @ nx_grid @ * h_cell @ ny_grid @ *
   DEFAULT_BDWIDTH FG_COLOR BG_COLOR XCreateSimpleWindow  to mainW

   \ set window name
   z" Telugu Alphabet" nameW !
   nameW 1 name_prop XStringListToTextProperty
   IF dpy @ mainW name_prop XSetWMName THEN

   \ Xft draw context
   dpy @ mainW  visual colormap  XftDrawCreate  to ftdraw

   \ allocate text color
[ HEX ]
\  red  green  blue  alpha
   0     0     ffff  ffff  txtcolor  alloc-ftcolor \ Xft text color
[ DECIMAL ]
   
   \ select inputs
   dpy @ mainW
   ExposureMask KeyPressMask or ButtonPressMask or StructureNotifyMask or
   PointerMotionMask or   XSelectInput drop

   \ make window visible
   dpy @ mainW XMapWindow drop
   false to Done
 
   \ retrieve and process events
   BEGIN
     Done invert
   WHILE 
      dpy @ event XNextEvent drop
      event XAnyEvent->window @ mainW =  IF
         event @
         CASE
            Expose      OF  draw-window   ENDOF
            ConfigureNotify OF 
                     event XConfigureRequestEvent->width  @ 
                     event XConfigureRequestEvent->height @
                     resize-grid
		     draw-window
            ENDOF
            Keypress      OF  on-keypress    ENDOF
            MotionNotify  OF  on-pointermove ENDOF
            ButtonPress   OF  on-buttonpress ENDOF
         ENDCASE
      THEN
   REPEAT

   \ close connection to display

   ftdraw  XftDrawDestroy 
   dpy @ visual colormap txtcolor  XftColorFree
   dpy @ mainW XDestroyWindow drop
   dpy @ XCloseDisplay drop         
;

telugu



