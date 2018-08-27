\ font-properties-x11.4th
\
\ Display loaded font properties of fonts used by simple-frames-x11
\ or other loaded fonts
\

include ans-words
include modules
include asm
include strings
include files
include utils
include lib-interface
include libs/x11/Xatom
include libs/x11/libX11
include font-strings-x11
include simple-graphics-x11
include simple-fonts-x11
include simple-typeset-x11
include simple-frames-x11

Also X11
Also simple-graphics-x11
Also font-strings-x11
Also simple-fonts-x11
Also simple-typeset-x11
Also simple-frames-x11

variable h
variable w
variable wgt
variable res
variable ptsize
variable subx
variable suby

\ Display font properties of the font
: print-font-props ( afontstruct -- )
    get-resolution
    cr ." Screen resolution: xdpi = " swap . 2 spaces ." ydpi = " .
    cr ." current font height (pix) = " current-font-height .   
    cr
    dup XA_X_HEIGHT    h      XGetFontProperty . ." height(x)  = " h ? cr
    dup XA_QUAD_WIDTH  w      XGetFontProperty . ." width(m)   = " w ? cr
    dup XA_WEIGHT      wgt    XGetFontProperty . ." weight     = " wgt ? cr
    dup XA_RESOLUTION  res    XGetFontProperty . ." resolution = " res ?  cr
    dup XA_POINT_SIZE  ptsize XGetFontProperty . ." point size = " ptsize ? cr
    dup XA_SUBSCRIPT_X subx   XGetFontProperty . ." sub x      = " subx ? cr
    dup XA_SUBSCRIPT_Y suby   XGetFontProperty . ." sub y      = " suby ? cr

    drop
    exit-simple-graphics
;

: show-font-info ( -- )
    \ perform other graphics setup
    extra-graphics-setup
    0 TextFonts1 @font-entry drop print-font-props
;

: frame1 ( -- )  ;


' frame1
1 set-frames
\ override default handlers provided by simple-frames-x11
' show-font-info IS user-graphics-init
start-frames

