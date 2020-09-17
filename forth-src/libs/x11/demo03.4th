\ simple-drawing.4th 
\
\  Use X image functions to demonstrate creating and displaying a gray scale 
\  pattern in a window. Also demonstrate setting the cursor shape within a
\  window.
\
\  This code may be used as a prototype for displaying gray scale images.
\
\  Copyright (c) 2009--202 Krishna Myneni
\
\  This program may be used for any purpose as long as the copyright
\  notice above is preserved. 

include ans-words
include modules.fs
include syscalls
include mc
include asm
include strings
include lib-interface
include libs/x11/libX11
include libs/x11/Xatom
include libs/x11/fontcursor
include dump

Also X11

variable display       \ pointer to X Display structure
0 value root_win       \ parent window ID
0 value win            \ window ID of newly created window
0 value screen_num
0 value cursor         \ cursor to use in new window
0 value disp_width
0 value disp_height
0 value nx
0 value ny
0 value width
0 value height         \ height and width for the new window
0 value colormap
0 value black
0 value white

variable gcvalues      \ initial values for the GC
0 value gc             \ GC (graphics context) used for drawing in our window

XColor color_exact
XColor color_screen

\ Allocate a color by its name
: get-color ( addr u -- pixel )
    $>zstr display @ colormap rot color_screen color_exact XAllocNamedColor
    IF    color_screen XColor->pixel @
    ELSE  cr ." Failed to lookup color"  black
    THEN
;

\ Obtain a 100-element gray scale

create gray-scale 100 cells allot

: get-gray-scale ( -- )
    100 0 DO 
	s" gray" I u>string count strcat get-color 
	gray-scale I cells + !  
    LOOP
;

variable xi            \ pointer to XImage structure

: H. base @ swap hex 8 u.r base ! ;
 
\ print the image properties of an XImage structure
: print-image-properties ( aXImage -- )
    cr ." Window image properties:" cr
    dup cr ." Width:            "  XImage->width ?
    dup cr ." Height:           "  XImage->height ?
    dup cr ." X offset:         "  XImage->xoffset ?
    dup cr ." Format:           "  XImage->format ?
    dup cr ." Data Ptr:         "  XImage->data @ H. 
    dup cr ." Byte order:       "  XImage->byte_order ?
    dup cr ." Bitmap unit:      "  XImage->bitmap_unit ?
    dup cr ." Bitmap bit order: "  XImage->bitmap_bit_order ?
    dup cr ." Bitmap pad:       "  XImage->bitmap_pad ?
    dup cr ." Image depth:      "  XImage->depth ?
    dup cr ." Bytes per line:   "  XImage->bytes_per_line ?
    dup cr ." Bits per pixel:   "  XImage->bits_per_pixel ?
    dup cr ." Red mask:         "  XImage->red_mask @ H.
    dup cr ." Green mask:       "  XImage->green_mask @ H. 
    dup cr ." Blue mask:        "  XImage->blue_mask @ H.
    drop cr
;

\ Generate a gray scale image and display it in the window
: show-image ( -- )
    xi @ IF
      \ Use XPutPixel to set the pixel values in the image
      \ (we may also be able to directly set the data area of the
      \  image structure, if we understand its format).
      height 0 DO  
	 width 0 DO
           xi @ I J gray-scale I 2/ 2/ cells + @ XPutPixel drop
         LOOP
      LOOP
      \ Dump some of the image data contents to see its format
      \ xi a@ XImage->data a@ 512 dump

      display @ win gc xi @ 0 0 0 0 width height XPutImage drop
    THEN
;

XEvent event           \ structure containing info about events.
XStandardColormap xcmap

: demo ( -- )			
    \ Open connection with the X server.
    s" :0.0" $>zstr XOpenDisplay dup display !
    0= IF
      cr ." cannot connect to X server" cr
      ABORT
    THEN

    \ Obtain display size and allocate gray-scale colors
    display @ XDefaultScreen  to screen_num
    display @ screen_num
    2dup XRootWindow to root_win
    2dup XDisplayWidth  to disp_width 
    2dup XDisplayHeight to disp_height
    2dup XBlackPixel to black
    2dup XWhitePixel to white
    2dup XDefaultColormap to colormap
    2drop
    get-gray-scale

    \ Create a window
    400 to width
    100 to height
    disp_width  width  - 2/ to nx
    disp_height height - 2/ to ny

    display @ root_win nx ny  width height  0  black  white  
    XCreateSimpleWindow  to win

    \ Set a crosshair cursor for the window
    display @ XC_crosshair  XCreateFontCursor to cursor
    display @ win cursor    XDefineCursor drop

    \ Obtain MapNotify, Key press, Window resize events
    display @ win
    ExposureMask KeyPressMask or StructureNotifyMask or XSelectInput drop

    \ Make the window actually appear on the screen. 
    display @ win XMapWindow drop

    \ Allocate a new GC (graphics context) for drawing in the window.
    display @ win 0 gcvalues XCreateGC to gc

    \ Obtain an image of the entire window area; first, we must wait
    \   for the window to become visible.
    BEGIN
      display @ event XNextEvent drop
      event @ MapNotify = 
    UNTIL
    display @ win 0 0 width height AllPlanes XYPixmap  XGetImage  xi !
    xi @ 0= IF  cr ." Unable to get image of the window!"  THEN

    xi a@ print-image-properties

    \ Event loop
    BEGIN
      display @ event XNextEvent drop
      event @ 
      CASE
        Expose  OF  show-image  ENDOF
      ENDCASE
      event @ Keypress =
    UNTIL

    \ Free resources and close the connection to the X server
    display @ cursor XFreeCursor drop
    display @ gc XFreeGC drop
    display @ XCloseDisplay drop
;

demo


