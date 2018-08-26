\ simple-drawing.4th 
\
\  Demonstrate drawing of pixels, lines, arcs, etc. on a window. 
\  All drawings are done in black color over a white background.
\
\ Adapted from the C program at the link below:
\
\ http://users.actcom.co.il/~choo/lupg/tutorials/xlib-programming/simple-drawing.c
\
\ Krishna Myneni, Creative Consulting for Research & Education
\ krishna.myneni@ccreweb.org
\
\ Revisions:
\   2012-05-03  km  Added statement: Also X11

include ans-words
include asm
include strings
include lib-interface
include libs/x11/libX11

Also X11

\ Handy utilities for calls to X drawing functions
: 3dup  dup 2over rot ;
: 3drop 2drop drop ;

XPoint% %size constant XPT_SIZE
: XPoint! ( nx ny apoint -- )
   rot over XPoint->x w! XPoint->y w! ;

: XPoints! ( x1 y1 ... xn yn  n apoints -- )
    over 1- XPT_SIZE * +
    swap 0 ?DO  dup >r XPoint! r> XPT_SIZE - LOOP drop ;

\ -- end utils --

0 value root_win
0 value black
0 value white

\ Make a simple window with a white background at the specified position,
\ width and height. Use a black border with width of 1. Automatically map
\ the window. Return the window ID.
: create-simple-window ( adisplay  nx  ny  uwidth uheight -- win )
    2>r  2>r
    dup   XDefaultScreen                    \ -- adisplay screen_num 
    2dup  XRootWindow to root_win
    2dup  XBlackPixel to black
    2dup  XWhitePixel to white
    drop

    dup  root_win  2r>  2r>  1  black  white  
    XCreateSimpleWindow  \ -- adisplay win

    \ Obtain MapNotify events
    2dup StructureNotifyMask XSelectInput drop

    \ make the window actually appear on the screen. 
    2dup XMapWindow drop

    nip 
;


0 value valuemask                       \ which values in 'gcvalues' to 
                                        \   check when creating the GC.
variable gcvalues                       \ initial values for the GC.
2 value line_width                      \ line width for the GC.

: create-gc ( adisplay win reverse_video -- nGC )
  >r  
  2dup valuemask gcvalues XCreateGC
  dup 0< ABORT" Unable to create the graphics context!"
  nip                   \ -- adisplay gc 

  \ allocate foreground and background colors for this GC.
  2dup black white  r> IF  swap  THEN
  2over rot  XSetBackground drop  XSetForeground drop  

  \ define the style of lines that will be drawn using this GC.
  2dup line_width LineSolid CapButt JoinBevel XSetLineAttributes drop

  \ define the fill style for the GC to be 'solid filling'.
  2dup FillSolid  XSetFillStyle drop

  nip
;


0 value screen_num
0 value win            \ window ID of newly created window.
0 value gc             \ GC (graphics context) used for drawing in our window.
0 value width
0 value height         \ height and width for the new window.

variable display       \ pointer to X Display structure.
XEvent event           \ structure containing info about events.

create points XPT_SIZE 4 * allot   \ array of 4 XPoints


: simple-drawing ( -- )			
  \ open connection with the X server.
  s" :0.0" $>zstr XOpenDisplay dup display !
  0= IF
    cr ." cannot connect to X server" cr
    ABORT
  THEN

  \ get the geometry of the default screen for our display, and
  \   set the new window height and width to occupy 1/9 of the screen size.
  display @ XDefaultScreen  to screen_num 
  display @ screen_num  XDisplayWidth  3 / to width 
  display @ screen_num  XDisplayHeight 3 / to height

  cr ." window width - " width . 2 spaces ." height - " height . cr

  \ create a simple window, as a direct child of the screen's
  \ root window. Use the screen's white color as the background
  \ color of the window. Place the new window's bottom-left corner 
  \ at the given 'x,y' coordinates.
  display @ 0 0 width height create-simple-window to  win

  \ allocate a new GC (graphics context) for drawing in the window.
  display @ win 0 create-gc to gc

  \ need to wait for map notify event (or expose event) before
  \ drawing into window.
  BEGIN
    display @ event XNextEvent drop
    event @ MapNotify = 
  UNTIL

  \ The following arguments are repeatedly used in X drawing calls
  display @ win gc

  \ draw one pixel near each corner of the window
  3dup  5 5          XDrawPoint  drop
  3dup  5 height 5 - XDrawPoint  drop
  3dup  width 5 - 5  XDrawPoint  drop
  3dup  width 5 - height 5 - XDrawPoint drop

  \ draw two intersecting lines, one horizontal and one vertical,
  \ which intersect at point "50,100".
  3dup  50   0  50 200  XDrawLine drop
  3dup   0 100 200 100  XDrawLine drop

  \ now use the XDrawArc() function to draw a circle whose diameter
  \ is 30 pixels, and whose center is at location '50,100'.
  3dup  50 30 2/ -  100 30 2/ -  30 30 0 360 64 *  XDrawArc drop

  \ draw a small triangle at the top-left corner of the window.
  \ the triangle is made of a set of consecutive lines, whose
  \ end-point pixels are specified in the 'points' array.
   0  0
  15 15
   0 15
   0  0
   4 points XPoints!
  3dup  points 4 CoordModeOrigin  XDrawLines  drop

  \ draw a rectangle whose top-left corner is at '120,150', its width is
  \ 50 pixels, and height is 60 pixels.
  3dup  120 150 50 60  XDrawRectangle drop

  \ draw a filled rectangle of the same size as above, to the left of the
  \ previous rectangle.
  3dup  60 150 50 60  XFillRectangle drop

  \ display text centered in a rectangle at the center of the window
  3dup width 2/ 40 -  height 2/  s" Hello X World!" XDrawString  drop

  
  3drop
  \ flush all pending requests to the X server.
  display @ XFlush drop
  display @ false XSync drop

  \ make a delay for a short period.
  4000000 usleep

  \ close the connection to the X server.
  display @ gc XFreeGC drop
  display @ XCloseDisplay drop
;

simple-drawing

