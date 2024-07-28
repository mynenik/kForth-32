\ demo-xft.4th 
\
\ Demonstrate use of Xft library for anti-aliased font rendering.
\
\ Original C Program From:
\   http://forums.nekochan.net/viewtopic.php?f=15&t=8794
\
\ Translated to Forth by Krishna Myneni
\

include ans-words
include modules
include syscalls
include mc
include asm
include strings
include lib-interface
include libs/x11/libX11
include libs/x11/libXft

Also X11
Also Xft

: make-geometry-string ( x y width height -- azstring )
    >r 0 <# # # # #> s" x" strcat
    r> 0 <# # # #>   strcat s" +" strcat
    2swap 
    >r 0 <# # # #>   strcat s" +" strcat
    r> 0 <# # # #>   strcat ( 2dup type cr )
    $>zstr
;

1 constant DEFAULT_BDWIDTH  \ border width

z" Hello Xft" ptr text

0 value   mainW
0 value   screen
0 value   root_win
0 value   visual
0 value   colormap
0 value   font
0 value   ftdraw
0 value   ytext
0 value   wtext
0 value   htext
0 value   fgpix
0 value   bgpix
0 value   Done
0 value   highlight
0 value   geo_mask

variable  dpy
variable  gravity
variable  wtmp
variable  itmp
variable  x
variable  y
variable  w
variable  h
variable  utmp

XSizeHints   xsh
XWMHints     xwmh
XRenderColor xrcolor
XftColor     txtcolor
XftColor     hltcolor
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

: draw-window ( -- )
    dpy @ mainW wtmp itmp itmp w h utmp utmp XGetGeometry IF
      dpy @ mainW XClearWindow drop
      w @ extents XGlyphInfo->width w@ - 2/ x !
      h @ htext - extents XGlyphInfo->height w@ + 2/ htext + y !
      highlight IF 
        ftdraw hltcolor x @ y @ extents XGlyphInfo->height w@ -  
        wtext extents XGlyphInfo->height w@  XftDrawRect
      THEN
      ftdraw txtcolor font x @ y @ text dup strlen  XftDrawString8
    THEN
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
   2dup z" morpheus-18"  XftFontOpenName to font
   2drop

   \ position and size of top window (XSizeHints)

   dpy @  font  text  dup strlen  extents XftTextExtents8
   extents XGlyphInfo->height w@  extents XGlyphInfo->y w@ -  to ytext 
   extents XGlyphInfo->width  w@  extents XGlyphInfo->x w@ -  to wtext

(
." extents height: " extents XGlyphInfo->height w@ . cr
." extents y:      " extents XGlyphInfo->y w@ . cr
." ytext: " ytext . cr
." wtext: " wtext . cr
) 
   ytext 4 + to htext 
   PPosition PSize or PMinSize or xsh XSizeHints->flags !
   htext 10 + xsh XSizeHints->height ! 
   xsh XSizeHints->height @ xsh XSizeHints->min_height !
   wtext xsh XSizeHints->width !
   xsh XSizeHints->width @ xsh XSizeHints->min_width !
   50 xsh XSizeHints->x ! 
   50 xsh XSizeHints->y ! 

   \ construct a geometry string
   xsh XSizeHints->x @       xsh XSizeHints->y @ 
   xsh XSizeHints->width @   xsh XSizeHints->height @
   make-geometry-string >r
    
   \ process geometry specification
   dpy @  screen  r>  0  DEFAULT_BDWIDTH  xsh 
   xsh XSizeHints->x  xsh XSizeHints->y  
   xsh XSizeHints->width  xsh XSizeHints->height
   gravity  XWMGeometry  to geo_mask
   
   \ check geometry bitmask and set size hints
   geo_mask  XValue YValue or  and  IF  
     xsh XSizeHints->flags dup @ USPosition or  swap !  THEN
   geo_mask  WidthValue HeightValue or  and  IF 
     xsh XSizeHints->flags dup @ USSize     or  swap !  THEN

(
." width: "  xsh XSizeHints->width  @ . cr
." height: " xsh XSizeHints->height @ . cr
)
     
   \ create top level window
   dpy @  root_win 
   xsh XSizeHints->x @  
   xsh XSizeHints->y @
   xsh XSizeHints->width @
   xsh XSizeHints->height @
   DEFAULT_BDWIDTH fgpix bgpix  XCreateSimpleWindow  to mainW
   
   \ set window manager properties
   dpy @ mainW z" demo-xft"  z" demo-xft" None 0 0 xsh  
   XSetStandardProperties drop
   
   \ set window manager hints
   InputHint StateHint or xwmh XWMHints->flags ! 
   False                  xwmh XWMHints->input !
   NormalState            xwmh XWMHints->initial_state !
   dpy @ mainW xwmh  XSetWMHints drop

   \ Xft draw context
   dpy @ mainW  visual colormap  XftDrawCreate  to ftdraw

   \ allocate text and highlight color values
[ HEX ]
\  red  green  blue  alpha
   0     0     0     ffff  txtcolor  alloc-ftcolor \ Xft text color
   afff  afff  ffff  ffff  hltcolor  alloc-ftcolor \ Xft highlight color
[ DECIMAL ]
   
   \ select inputs
   dpy @ mainW  ExposureMask ButtonPressMask or 
   EnterWindowMask or LeaveWindowMask or  XSelectInput drop
   
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
            EnterNotify OF  true  to highlight draw-window ENDOF
            LeaveNotify OF  false to highlight draw-window ENDOF
            Expose      OF  draw-window  ENDOF
            ButtonPress OF  true to Done  ." good-bye!" cr  ENDOF
         ENDCASE
      THEN
   REPEAT

   \ close connection to display

   ftdraw  XftDrawDestroy 
   dpy @ visual colormap txtcolor  XftColorFree
   dpy @ visual colormap hltcolor  XftColorFree
   dpy @ mainW XDestroyWindow drop
   dpy @ XCloseDisplay drop         
;

main



