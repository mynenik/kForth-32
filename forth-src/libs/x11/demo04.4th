\ demo04.4th 
\
\  Wire frame drawing of space shuttle from a 3d model.
\  
\ Copyright (c) 2009 Krishna Myneni, Creative Consulting for Research & Education
\ krishna.myneni@ccreweb.org
\
\ Notes:
\
\   1. 3d model of the space shuttle is from the NASA website:
\      http://www.nasa.gov/multimedia/3d_resources/assets/orbiter.html
\
\   2. A text data file, STS.dat, is generated from the original .3ds file
\      by dumping the vertices and polygons to the text file. The beginnings
\      of a 3ds file reader in Forth are in 3ds.4th, which is used by this code.
\
\   3. Needs hidden line removal
\
\ Revisions: 
\   2009-11-09  km  implemented rotation of object
\   2012-05-04  km  added statement: Also X11

include ans-words
include asm
include strings
include files
include 3ds
include 3ds-transform
include lib-interface
include libs/x11/libX11

Also X11
true value  XK_MISCELLANY
include keysymdef


\ Handy utilities for calls to X drawing functions
: 3dup  dup 2over rot ;
: 3drop 2drop drop ;
: uw@   dup c@ swap 1+ c@ 8 lshift or ;

XPoint% %size constant XPT_SIZE
: XPoint! ( nx ny apoint -- )
   rot over XPoint->x w! XPoint->y w! ;
: XPoints! ( x1 y1 ... xn yn  n apoints -- )
    over 1- XPT_SIZE * +
    swap 0 ?DO  dup >r XPoint! r> XPT_SIZE - LOOP drop ;


10 constant ANGLE_STEP  
: step-phi    ( negstep? -- ) ANGLE_STEP swap IF negate THEN s>f deg>rad phi f@ f+ phi f! ;
: step-theta  ( negstep? -- ) ANGLE_STEP swap IF negate THEN s>f deg>rad theta f@ f+ theta f! ;
: step-psi    ( negstep? -- ) ANGLE_STEP swap IF negate THEN s>f deg>rad psi f@ f+ psi   f! ;


: default-orientation ( -- )
    0e phi f!  0e theta f! 0e psi f!
    update-rotation-matrix
;

default-orientation

\ Set orientation angles; arguments are integer degrees
: set-orientation ( ndeg_phi  ndeg_theta  ndeg_psi -- )
    s>f deg>rad psi f!   s>f deg>rad theta f!   s>f deg>rad phi f!
;

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
    2dup ExposureMask StructureNotifyMask or KeyPressMask or XSelectInput drop

    \ make the window actually appear on the screen. 
    2dup XMapWindow drop

    nip 
;


0 value valuemask                       \ which values in 'gcvalues' to 
                                        \   check when creating the GC.
variable gcvalues                       \ initial values for the GC.
1 value line_width                      \ line width for the GC.

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

create vertices   3ds_Vertex%  %size 1400 * allot
create r_vertices 3ds_Vertex%  %size 1400 * allot
create polygons   3ds_Polygon% %size 2500 * allot
create buf 80 allot

0 value nVertices
0 value nPolygons
0 value fd

: read-vertices ( -- )
   nVertices 0 ?DO
     buf 64 blank
     buf 64 fd read-line 2drop
     buf swap evaluate vertices I VTX_SIZE * + 3ds_Vertex!
   LOOP
;

: read-polygons ( n -- )
    nPolygons 0 ?DO
     buf 64 blank
     buf 64 fd read-line 2drop
     buf swap evaluate polygons I PGN_SIZE * + 3ds_Polygon!
    LOOP
;


: read-3d-data ( a u -- )
   R/O open-file ABORT" Unable to open input file!"
   to fd
   buf 64 blank 
   buf 64 fd read-line 2drop
   buf swap parse_token s" Vertices" compare 0= IF
     strpck string>s to nVertices
     read-vertices
   ELSE
     fd close-file drop
     cr ." Unable to find vertex list!" EXIT
   THEN
   
   buf 64 blank
   buf 64 fd read-line 2drop
   buf swap parse_token s" Polygons" compare 0= IF
     strpck string>s to nPolygons
     read-polygons
   ELSE
     fd close-file drop
     cr ." Unable to find polygon list!" EXIT
   THEN
   fd close-file drop
   cr nVertices . ."  vertices and " nPolygons . ."  polygons read from file."
;


fvariable xmin
fvariable xmax
fvariable ymin
fvariable ymax
fvariable zmin
fvariable zmax
fvariable xdel
fvariable ydel
fvariable zdel

\ Determine min and max for vertices
: vertex-limits ( -- )
     vertices  3ds_Vertex->x sf@
     nVertices 1 ?DO  vertices VTX_SIZE I * + 3ds_Vertex->x sf@ fmin  LOOP
     xmin f!
     vertices  3ds_Vertex->y sf@
     nVertices 1 ?DO  vertices VTX_SIZE I * + 3ds_Vertex->y sf@ fmin  LOOP
     ymin f!
     vertices 3ds_Vertex->z sf@
     nVertices 1 ?DO  vertices VTX_SIZE I * + 3ds_Vertex->z sf@ fmin  LOOP
     zmin f!

     vertices 3ds_Vertex->x sf@
     nVertices 1 ?DO  vertices VTX_SIZE I * + 3ds_Vertex->x sf@ fmax  LOOP
     xmax f!
     vertices  3ds_Vertex->y sf@
     nVertices 1 ?DO  vertices VTX_SIZE I * + 3ds_Vertex->y sf@ fmax  LOOP
     ymax f!
     vertices 3ds_Vertex->z sf@
     nVertices 1 ?DO  vertices VTX_SIZE I * + 3ds_Vertex->z sf@ fmax  LOOP
     zmax f!

     xmax f@ xmin f@ f- xdel f!
     ymax f@ ymin f@ f- ydel f!
     zmax f@ zmin f@ f- zdel f!
;

: TransformToWindow ( fx fy -- x y )
     ymin f@ f- ydel f@ f/ height s>f f* fround>s >r
     \ zmin f@ f- zdel f@ f/ width  s>f f* fround>s r>
     xmin f@ f- xdel f@ f/ width s>f f* fround>s r>
;

\ Scale a 3ds vertex to an xpoint
: 3ds_Vertex>XPoint ( a3dsvertex axpoint -- )
     >r >r
     r@ 3ds_Vertex->z sf@ 
     r> 3ds_Vertex->y sf@
     TransformToWindow r> XPoint!
;    
 
\ points for XDrawLines
create points XPT_SIZE 4 * allot

\ Transform polygon to 4 XPoints
: polygon>points ( a3ds_polygon  -- )
    dup 3ds_Polygon->a uw@ VTX_SIZE * r_vertices +  
    dup points  3ds_Vertex>XPoint
        points XPT_SIZE 3 * + 3ds_Vertex>XPoint
    dup 3ds_Polygon->b uw@ VTX_SIZE * r_vertices +  points  XPT_SIZE + 3ds_Vertex>XPoint
        3ds_Polygon->c uw@ VTX_SIZE * r_vertices +  points  XPT_SIZE 2* + 3ds_Vertex>XPoint
;

\ Wire-frame drawing of the 3d model
: draw-wireframe ( -- )
    update-rotation-matrix
    vertices r_vertices nVertices Rtransform-Vertices
    display @ win XClearWindow drop
    display @ win gc
    nPolygons 0 ?DO
      polygons I PGN_SIZE * + polygon>points
      3dup points 4 CoordModeOrigin XDrawLines drop
    LOOP
    3drop
    display @ XFlush drop
    display @ false XSync drop
;

0 value ksym

\ View 3d model contained in a file
: view-3d-model ( a u -- )
    read-3d-data
    vertex-limits
    		
    \ open connection with the X server.
    s" :0.0" $>zstr XOpenDisplay dup display !
    0= IF
      cr ." cannot connect to X server" cr
      ABORT
    THEN

    \ get the geometry of the default screen for our display, and
    display @ XDefaultScreen  to screen_num 
    display @ screen_num  XDisplayWidth  2/ to width 
    display @ screen_num  XDisplayHeight 3 / to height

    display @ 0 0 width height create-simple-window to  win

    \ allocate a new GC (graphics context) for drawing in the window.
    display @ win 0 create-gc to gc

    \ Event loop
    BEGIN
      display @ event XNextEvent drop
      event @ 
      CASE
        Expose   OF  draw-wireframe  ENDOF
        Keypress OF  display @ event XKeyEvent->keycode @ 0 XKeyCodeToKeysym
                     dup to ksym
                     CASE
                       XK_Up        OF  false step-theta     ENDOF
                       XK_Down      OF  true  step-theta     ENDOF
                       XK_Left      OF  true  step-phi       ENDOF
                       XK_Right     OF  false step-phi       ENDOF
                       XK_Page_Up   OF  false step-psi       ENDOF
                       XK_Page_Down OF  true  step-psi       ENDOF
                       XK_Home      OF  default-orientation  ENDOF
                     ENDCASE
                     draw-wireframe
                 ENDOF 
      ENDCASE
      event @ Keypress =  ksym  XK_Escape = and
    UNTIL

    \ close the connection to the X server.
    display @ gc XFreeGC drop
    display @ XCloseDisplay drop
;

: demo s" STS.dat" view-3d-model ;

demo


