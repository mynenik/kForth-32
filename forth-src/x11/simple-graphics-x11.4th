\ simple-graphics-x11.4th
\
\ A simple utility for drawing and interacting with graphics in
\ an X11 window. The utility can be used for data plotting as well.
\
\ Provides:
\
\ Event Handlers and Input Info:
\  redraw-window     ( -- ) user vector for drawing graphics in window
\  user-graphics-init ( -- )  user vector for extra graphics initialization
\  user-graphics-cleanup ( -- ) user vector for graphics cleanup
\  on-keypress       ( -- ) user vector for handling a key press in window
\  on-buttonpress    ( -- ) user vector for handling a button press in window
\  on-pointermove    ( -- ) user vector for handling pointer motion
\  get-keyinfo       ( -- keysym )
\  get-buttoninfo    ( -- button x y )
\  get-pointerinfo   ( -- x y state )
\
\ Window Geometry and Transformations
\  get-window-size   ( -- width height )
\  get-window-limits ( F: -- xmin ymin xmax ymax )
\  set-window-limits ( F: xmin ymin xmax ymax -- )
\  uc>wc             ( F: rx ry -- ) ( -- x y )
\  wc>uc             ( x y -- ) ( F: -- rx ry )
\  udx>wdx           ( F: udx -- ) ( -- wdx )
\  udy>wdy           ( F: udy -- ) ( -- wdy )
\
\ Graphics and Font Config
\  get-resolution    ( -- xdpi ydpi )
\  resize-window     ( newwidth newheight -- )
\  get-color         ( caddr u -- pixval )
\  foreground        ( pixval -- )
\  set-window-background ( pixval -- )
\  set-window-name   ( caddr u -- )
\  set-icon-name     ( caddr u -- )
\  clear-area        ( x y width height exposures -- )
\  clear-window      ( -- )
\  flush-window      ( -- )
\  set-line-type     ( thickness style -- )
\  load-font         ( caddr u -- afontstruct font_id flag )
\  unload-font       ( font_id -- )
\  set-font          ( font_id -- )
\  get-font-ascent   ( afontstruct -- ascent )  \ ascent in pixels
\  get-font-height   ( afontstruct -- height )  \ height in pixels
\ 
\ Window Coordinate Drawing Words: 
\  draw-points       ( apoints u -- )
\  draw-lines        ( apoints u -- )
\  draw-point        ( x y -- )
\  draw-line         ( x1 y1 x2 y2 -- )
\  draw-rectangle    ( x y width height -- )
\  draw-filled-rectangle ( x y width height -- )
\  draw-ellipse      ( x y width height -- )
\  draw-filled-ellipse ( x y width height -- )
\  draw-circle       ( x y diameter -- )
\  draw-filled-circle ( x y diameter -- )
\  draw-text         ( x y caddr u -- )
\
\ User Coordinate Drawing Words:
\  point-plot        ( ax ay u -- )
\  line-plot         ( ax ay u -- )
\  put-point         ( F: x y -- )
\  put-line          ( F: x1 y1 x2 y2 -- )
\  put-rectangle     ( F: x y width height -- )
\  put-filled-rectangle ( F: x y width height -- )
\  put-circle        ( F: x y diameter -- )
\  put-filled-circle ( F: x y diameter -- )
\  put-text          ( F: x y -- ) ( caddr u -- ) or ( x y caddr u -- )
\
\  simple-graphics   ( widthscale heightscale -- )
\  exit-simple-graphics ( -- )
\
\  Defined pixvals: red green blue black white grey brown yellow
\                   cyan magenta
\
\ Requires:
\   ans-words.4th
\   modules.4th
\   syscalls.4th
\   mc.4th
\   asm.4th
\   strings.4th
\   lib-interface.4th
\   libs/x11/libX11.4th
\
\  Copyright (c) 2011--2020 Krishna Myneni
\
\  This code may be used for any purpose, provided the
\  copyright notice above is included.
\

Module: simple-graphics-x11

Also X11

Begin-Module

Private:

fvariable xmin
fvariable ymin
fvariable xmax
fvariable ymax

fvariable xdel
fvariable ydel

-1e xmin f!
-1e ymin f!
 1e xmax f!
 1e ymax f!
 2e xdel f!
 2e ydel f!

0 value width
0 value height         \ height and width for the new window.

fvariable fheight
fvariable fwidth

Public:

: get-window-size ( -- width height ) width height ;

: set-window-size ( width height -- ) 
    2dup to height  to width 
    s>f fheight f! s>f fwidth f! ;

Private:

\ Return true if a <= x <= b; false otherwise
fvariable xhi
: fwithin ( F: x a b -- ) ( -- flag)
    xhi f!
    fover  f<= >r
    xhi f@ f<= r> and ;

Public:

\ User to Window coordinate transform and vice-versa

: uc>wc ( F: rx ry ) ( -- x y ) 
    ymin f@ f-  ydel f@ f/ 1e fswap f- fheight f@ f* fround>s >r
    xmin f@ f-  xdel f@ f/             fwidth  f@ f* fround>s r> ;

: wc>uc ( x y -- ) ( F: -- rx ry )
      >r s>f fwidth  f@ f/    xdel f@ f* xmin f@ f+
   1e r> s>f fheight f@ f/ f- ydel f@ f* ymin f@ f+ ; 

: udx>wdx ( F: udx -- ) ( -- wdx )  fwidth  f@ f* xdel f@ f/ fround>s ;
: udy>wdy ( F: udy -- ) ( -- wdy )  fheight f@ f* ydel f@ f/ fround>s ;


\ Is the point within the window?
: in-window? ( F: x y -- ) ( -- flag)
    ymin f@ ymax f@ fwithin >r
    xmin f@ xmax f@ fwithin r> and ;

\ Get the current window coordinates
: get-window-limits ( F: -- xmin ymin xmax ymax )
    xmin f@  ymin f@  xmax f@  ymax f@ ;

\ Set the window coordinates
: set-window-limits ( F: xmin ymin xmax ymax -- )
    ymax f!  xmax f!  ymin f!  xmin f!
    ymax f@  ymin f@  f-  ydel f!
    xmax f@  xmin f@  f-  xdel f!
;

Private:

0 value screen_num     \ number of screen to place the window on.
0 value win            \ window ID of the newly created window.
0 value root_win       \ parent window of new window
0 value gc             \ GC (graphics context) used for drawing in our window.

variable display       \ pointer to X Display structure.
variable gcvalues
0 value colormap

XColor col_exact


Public:

0 value red
0 value green
0 value blue
0 value black
0 value white
0 value grey
0 value brown
0 value yellow
0 value cyan
0 value magenta

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

Private:

360 64 * constant ARC_FULL

: translate-to-edge ( xc yc width height -- xe ye width height )
    2dup 2>r nip 2/ - swap 2r@ drop 2/ - swap 2r> ;

Public:

\ Drawing in window coordinates

\ Draw a sequence of points. apoints is a pointer to a
\ series of u XPoint structures.
: draw-points ( apoints u -- )
    2>r display @ win gc 2r> CoordModeOrigin XDrawPoints drop ;

: draw-lines ( apoints u -- )
    2>r display @ win gc 2r> CoordModeOrigin XDrawLines drop ;

: draw-point ( x y -- )
    2>r display @ win gc 2r> XDrawPoint drop ;

: draw-line ( x1 y1 x2 y2 -- )
    2>r 2>r display @ win gc 2r> 2r> XDrawLine drop ;

\ x y is the upper left corner
: draw-rectangle ( x y width height -- )
    2>r 2>r display @ win gc 2r> 2r> XDrawRectangle drop ;

: draw-filled-rectangle ( x y width height -- )
    2>r 2>r display @ win gc 2r> 2r> XFillRectangle drop ;

\ x y is the center of the ellipse
: draw-ellipse ( x y width height -- )
   translate-to-edge
   2>r 2>r display @ win gc 2r> 2r> 0 ARC_FULL XDrawArc drop ;

: draw-filled-ellipse ( x y width height -- )
   translate-to-edge
   2>r 2>r display @ win gc 2r> 2r> 0 ARC_FULL XFillArc drop ;

: draw-circle ( x y diameter -- )  dup draw-ellipse ;

: draw-filled-circle ( x y diameter -- ) dup draw-filled-ellipse ;

: draw-text ( x y caddr u -- )
    2>r 2>r display @ win gc 2r> 2r> XDrawString drop ;
     
\ Drawing in user coordinates

Private:
XPoint% %size constant XPT_SIZE
: XPoint! ( nx ny apoint -- )  rot over XPoint->x w! XPoint->y w! ;

variable np
variable pPoints

: @point ( ax ay i -- ) ( F: -- ax[i]  ay[i] )
    floats dup >r + swap r> + >r f@ r> f@ fswap ;

\ Transform user coordinates to window coordinates for a set of points.
: transform-points ( ax ay u -- )
    np !
    np @ 0= IF  2drop EXIT  THEN
    np @ XPT_SIZE * allocate ABORT" allocate error!"
    pPoints !
    np @ 0 DO 
      2dup I @point  uc>wc
      pPoints a@ I XPT_SIZE * + XPoint!
    LOOP
    2drop
;

Public:

: point-plot ( ax ay u -- )
    transform-points
    pPoints a@ np @ draw-points
    pPoints a@ free drop
;

: line-plot ( ax ay u -- )
    transform-points
    pPoints a@ np @ draw-lines
    pPoints a@ free drop
;

: put-point ( F: x y -- )
    uc>wc 2>r
    display @ win gc 2r> XDrawPoint drop
;

: put-line ( F: x1 y1 x2 y2 -- ) 
    uc>wc 2>r  uc>wc 2>r
    display @ win gc 2r> 2r> XDrawLine drop
;

\ x y is lower left corner
: put-rectangle ( F: x y width height -- )
    udy>wdy >r  udx>wdx r> 2>r
    uc>wc 2r> draw-rectangle ;

: put-filled-rectangle ( F: x y width height -- )
    udy>wdy >r udx>wdx r> 2>r
    uc>wc 2r> draw-filled-rectangle ;

: put-circle ( F: x y diameter -- )
    udx>wdx >r uc>wc r> draw-circle ;  

: put-filled-circle ( F: x y diameter -- )
    udx>wdx >r uc>wc r> draw-filled-circle ;

: put-text ( F: x y -- ) ( caddr u -- )  \ ( x y caddr u -- )
    2>r uc>wc 2>r 
    display @ win gc 2r> 2r> XDrawString  drop ;


\ Graphics Setup and Other Graphics Functions

\ Get the dots per inch along x and y for this display
: get-resolution ( -- xdpi ydpi )
    display @ screen_num 2>r
    2r@ XDisplayWidth    254 *  s>f
    2r@ XDisplayWidthMM   10 *  s>f f/ fround>s      \ xdpi
    2r@ XDisplayHeight   254 *  s>f
    2r> XDisplayHeightMM  10 *  s>f f/ fround>s      \ ydpi  
;

: resize-window ( newwidth newheight -- )
    2>r display @ win 2r@ XResizeWindow \ dup . cr 
    0= IF  2r> set-window-size  ELSE  2r> 2drop  THEN ;

\ Set the foreground color
: foreground ( pixelval -- )
    >r display @ gc r> XSetForeground drop ;

: set-window-background ( pixval -- )
    >r display @ win r> XSetWindowBackground drop ;

Private:

variable name_string
variable icon_name_string
XTextProperty name_prop
XTextProperty icon_name_prop

Public:

: set-window-name ( caddr u -- )
    $>zstr name_string !
    name_string 1 name_prop XStringListToTextProperty
    IF  display @ win name_prop XSetWMName
    ELSE ." Error: XStringListToTextProperty!"  cr
    THEN
;

: set-icon-name ( caddr u -- )
    $>zstr icon_name_string !
    icon_name_string 1 icon_name_prop XStringListToTextProperty
    IF display @ win icon_name_prop XSetWMIconName  THEN
;

\ Set the line attributes
\ style: 0 = solid, 1 = dash, 2 = double dash
: set-line-type ( thickness style -- )
    2 min 2>r
    display @ gc 2r> CapButt JoinBevel XSetLineAttributes drop ;

: clear-area ( x y width height exposures -- )
    >r 2>r 2>r display @ win 2r> 2r> r> XClearArea drop ;

: clear-window ( -- ) display @ win XClearWindow drop ;

: flush-window ( -- ) display @ XFlush drop ;

Private:
variable pFontStruct

Public:

\ caddr u is the full font string described by the X Logical Font
\ Description (XLFD) convention, e.g.
\
\     -misc-fixed-medium-r-normal--20-140-100-100-c-100-iso8859-1
\
\ The font must be provided by your X font server. Fields may use
\ wildcards. If successful, flag is TRUE and a font structure pointer
\ and font id are returned. The font id is used to reference the
\ font, subsequently. Before text will appear in the font, the
\ loaded font must be made the current font using SET-FONT.

: load-font ( caddr u -- afontstruct font_id flag)
    strpck 1+ display @ swap XLoadQueryFont 
    dup 0<> >r pFontStruct !   
    pFontStruct a@ r@ 
    IF dup XFontStruct->fid @ ELSE 0 THEN
    r> ;

: unload-font ( font_id -- )  >r display @ r> XUnloadFont drop ;

: set-font ( font_id -- ) >r display @ gc r> XSetFont drop ;

\ Return the font ascent in pixels for a specified font
: get-font-ascent ( afontstruct -- height )
    dup IF  XFontStruct->ascent @ ELSE drop 0 THEN ;

\ Return the font height in pixels for a specified font
: get-font-height ( afontstruct -- height )
    dup IF
      dup >r  XFontStruct->ascent  @  
          r>  XFontStruct->descent @ + 
    ELSE  drop 0
    THEN ;

\ Window control

Private:
XEvent event
false value exit_graphics?

Public:

\ Handlers for window events
\
\ The handlers may be re-vectored by the calling application.
\ Default handlers are provided.

defer redraw-window
defer user-graphics-init        
defer user-graphics-cleanup           
defer on-keypress
defer on-buttonpress
defer on-pointermove

\ Return symbol for last key pressed
: get-keyinfo ( -- keysym )  
    display @  event XKeyEvent->keycode @  0 XKeyCodeToKeysym ;

\ Return button and coordinates for last button press
: get-buttoninfo ( -- button x y )
    event XButtonEvent->button @ 
    event XButtonEvent->x      @ 
    event XButtonEvent->y      @    
;

\ Return pointer coordinates for last pointer move
: get-pointerinfo ( -- x y state )
    event XMotionEvent->x @  event XMotionEvent->y @
    event XMotionEvent->state @
;

\ Set default handler for expose events
' clear-window is redraw-window

: default-key-handler ( -- )  true to exit_graphics? ;
' default-key-handler IS on-keypress

: default-button-handler ( -- )
    get-buttoninfo 2drop drop
;
' default-button-handler IS on-buttonpress

: default-pointermove-handler ( -- )
    get-pointerinfo 2drop drop
;
' default-pointermove-handler IS on-pointermove

: default-user-init ( -- )
;
' default-user-init IS user-graphics-init

: default-user-cleanup ( -- )
;
' default-user-cleanup IS user-graphics-cleanup

: exit-simple-graphics ( -- ) true to exit_graphics? ;

Private:
variable wmDeleteMessage

variable win_update_start
variable win_update_interval
0 win_update_interval !   \ 0 means no forced-redraw

\ Dummy expose event to the graphics window, used for
\ forced redrawing of the window at specified times.
Xevent expEvent
  Expose    expEvent XExposeEvent->type !
  0         expEvent XExposeEvent->serial !
  true      expEvent XExposeEvent->send_event !
  display @ expEvent XExposeEvent->display !
  win       expEvent XExposeEvent->window !
  0         expEvent XExposeEvent->x !
  0         expEvent XExposeEvent->y !
  0         expEvent XExposeEvent->width !
  0         expEvent XExposeEvent->height !
  0         expEvent XExposeEvent->count !

: redraw? ( -- flag )
      win_update_interval @ 0= IF false EXIT THEN
      ms@ win_update_start @ - win_update_interval @ > 
;

Public:

\ set an interval in milli-seconds for forced redraw of the window
: auto-redraw ( n -- )  win_update_interval !  ;

\ ws and hs are integer width and height scale factors for the
\ window: 1 means full width of the display, 2 means half, etc.

: simple-graphics ( ws hs -- )
    2>r 			
    \ open connection with the X server.
    s" :0.0" $>zstr XOpenDisplay dup display !
    0= IF
      cr ." cannot connect to X server" cr
      ABORT
    THEN

    \ get the default colormap and window size for our display.
    display @ XDefaultScreen to screen_num
    display @ screen_num
    2dup  XDisplayWidth  2r@ drop /  to width
    2dup  XDisplayHeight 2r> nip  /  to height
    2dup  XBlackPixel to black
    2dup  XWhitePixel to white
    2dup  XDefaultColormap to colormap
    2dup  XRootWindow to root_win
    2drop
    s" blue"   get-color to  blue
    s" red"    get-color to  red
    s" green"  get-color to  green
    s" grey"   get-color to  grey
    s" brown"  get-color to  brown
    s" yellow" get-color to  yellow
    s" cyan"   get-color to  cyan
    s" magenta" get-color to magenta

    display @  root_win  0 0  width height  0  black  white
    XCreateSimpleWindow  to win

    \ Register to receive delete window message from the Window Manager
    display @ z" WM_DELETE_WINDOW" false XInternAtom wmDeleteMessage !
    display @ win wmDeleteMessage 1 XSetWMProtocols drop

    \ Obtain MapNotify, Key press, Button press, Window resize, and
    \ Pointer motion events
    display @ win
    ExposureMask KeyPressMask or ButtonPressMask or StructureNotifyMask or
    PointerMotionMask or   XSelectInput drop

    \ make the window actually appear on the screen. 
    display @ win XMapWindow drop

    \ allocate a new GC (graphics context) for drawing in the window.
    display @ win 0 gcvalues XCreateGC to gc
    gc 0< ABORT" Unable to create the graphics context!"
    display @ gc FillSolid  XSetFillStyle drop

    \ flush all pending requests to the X server.
    display @ XFlush drop
    display @ false XSync drop

    \ other initialization
    width height set-window-size
    false to exit_graphics?

    user-graphics-init

    ms@ win_update_start !

    \ Event loop
    BEGIN
      display @ event XNextEvent drop
      event @
      CASE
        Expose        OF  event XExposeEvent->count @ 0= IF 
			    redraw-window 			    
			   THEN
	                   ENDOF
        ConfigureNotify OF 
                     event XConfigureRequestEvent->width  @ 
                     event XConfigureRequestEvent->height @
                     set-window-size
                  ENDOF
        Keypress      OF  on-keypress       ENDOF
        ButtonPress   OF  on-buttonpress    ENDOF
        MotionNotify  OF  on-pointermove    ENDOF
        ClientMessage OF  event XClientMessageEvent->data @ 
                          wmDeleteMessage @ = IF exit-simple-graphics THEN
                      ENDOF
      ENDCASE
      
      \ Check if we need to force a redraw by sending the window a new
      \ expose event.      
      redraw? IF
        display @ win false ExposureMask expEvent XSendEvent drop
	ms@ win_update_start !
      THEN

      exit_graphics?
    UNTIL

    \ User-required cleanup (to clean up after user-graphics-init)
    user-graphics-cleanup

    \ close the connection to the X server.
    display @ gc XFreeGC drop
    display @ XCloseDisplay drop
;

End-Module

