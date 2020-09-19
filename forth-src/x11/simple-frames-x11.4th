\ simple-frames-x11.4th
\
\ A minimal framework for the presentation of sequential x11 graphics,
\ generated as individual frames by user-specified code, and traversable
\ by the user.
\
\   Copyright (c) 2012--2020, K. Myneni
\
\   This code may be used for any purpose, provided the copyright
\   notice above is included.
\ 
\ Notes:
\
\ 0) The user app provides a series of words, e.g. frame1 frame2 ... ,
\    each of which performs the graphics to draw a single frame. To
\    present these frames in the desired sequence, the application
\    first uses SET-FRAMES :
\
\       ' frame1  ' frame2  ' frame3 ...
\       n SET-FRAMES
\
\    where n is the number of frames to be presented. To start the
\    presentation, the user application executes START-FRAMES
\
\       START-FRAMES
\
\    The simple-frames module allows the user to navigate between
\    the frames using the [Page Up] and [Page Down] keys. Also, the
\    [Home] and [End] keys may be used to go to the first and last
\    frames, and the [Escape] key is used to exit the presentation.
\
\ 1) To replace or chain key handling from the user application,
\    define a key-handler in the app, e.g.
\
\      : key-handler ( -- )
\          get-keyinfo
\          CASE
\            XK_A  OF ... ENDOF
\            \ etc.
\          ENDCASE
\       
\          frame-nav  ( optional, to chain the handlers)
\      ;
\
\    Set the key handler in the user app, after SET-FRAMES
\    and before START-FRAMES , e.g.
\
\        ... n SET-FRAMES
\        ' key-handler IS on-keypress
\        START-FRAMES
\

true value  XK_MISCELLANY
include libs/x11/keysymdef

[undefined] font-strings-x11 [if] include font-strings-x11 [then]
[undefined] simple-fonts-x11 [if] include simple-fonts-x11 [then]

Module: simple-frames-x11

Also simple-graphics-x11
Also font-strings-x11
Also simple-fonts-x11

Begin-Module

1 value first_frame
1 value last_frame

variable current_frame
first_frame current_frame !

variable pFrames  \ the frames list

: !frame ( xt u -- )
    1- cells pFrames a@ + ! ;

: @frame ( u -- xt )
    dup first_frame last_frame 1+ within
    IF  1- cells pFrames a@ + a@  ELSE  drop 0  THEN
;

: free-frame-list ( -- )
    pFrames a@ free drop 
    0 pFrames ! ;

\ Font Tables

Public:

FontTable TextFonts1    \ text font family 1
FontTable TextFonts2    \ text font family 2
FontTable SymbolFonts   \ symbol font family
FontTable ExtraFonts    \ extra user font family

\ Graphics initialization

Private:

\ Default text fonts
\ FONT_BITSTREAM_CHARTER  constant  DEF_TEXTFONT_1
\ FONT_COURIER_10_PITCH   constant  DEF_TEXTFONT_2
FONT_STANDARD_SYMBOLS_L constant  DEF_SYMFONT

\ Alternate default text fonts
FONT_TIMES      constant  DEF_TEXTFONT_1
FONT_TIMES      constant  DEF_TEXTFONT_2

: setup-fonts ( -- )
    DEF_TEXTFONT_1  TextFonts1   load-font-table
    invert ABORT" Unable to load text fonts 1!"

    DEF_TEXTFONT_2  TextFonts2   load-font-table
    invert ABORT" Unable to load text fonts 2!"

    \ DEF_SYMFONT    SymbolFonts  load-symbol-font-table
    \ invert ABORT" Unable to load symbol fonts!" 
;

: setup-extra-colors ( -- )
;

Public:

: get-current-frame ( -- u )  current_frame @ ;

: next-frame ( -- ) 
    get-current-frame 1+  last_frame min 
    current_frame ! ;

: previous-frame ( -- ) 
    get-current-frame 1- first_frame max
    current_frame ! ;

: extra-graphics-setup ( -- )
    setup-fonts
    setup-extra-colors
    medium regular 140 TextFonts1 select-font
;

: extra-graphics-cleanup ( -- )
    TextFonts1  unload-font-table
    TextFonts2  unload-font-table
    SymbolFonts unload-font-table
    ExtraFonts  unload-font-table
;

: frame-nav ( -- )
    get-keyinfo
    CASE
      XK_Page_Up    OF   previous-frame  ENDOF
      XK_Page_Down  OF   next-frame      ENDOF
      XK_Home       OF   first_frame current_frame !  ENDOF
      XK_End        OF   last_frame  current_frame !  ENDOF
      XK_Escape     OF   free-frame-list  exit-simple-graphics  EXIT  ENDOF
    ENDCASE
    current_frame @ first_frame max last_frame min 
    dup current_frame ! @frame IS redraw-window
    clear-window
    redraw-window
;

: set-frame-range ( first last -- )
    to last_frame 1 max to first_frame ;

: set-frames ( xt1 xt2 ... xtn n -- )
    dup 1 < ABORT" Must provide a minimum of 1 frame!"
    dup cells allocate ABORT" Unable to allocate frames list!"
    pFrames !
    1 over set-frame-range
    1 swap do I !frame -1 +loop
    1 @frame IS redraw-window
    ['] frame-nav IS on-keypress
    ['] extra-graphics-setup IS user-graphics-init
    ['] extra-graphics-cleanup IS user-graphics-cleanup
;

: start-frames ( -- )
    pFrames @ 0= ABORT" No frames setup!"
    2 2 simple-graphics
;

End-Module

