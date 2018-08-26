\ Xutil.4th
\
\ Based on the C header file, Xutil.h
\
\ Original Copyright Notice:
\
\ Copyright 1987, 1998  The Open Group
\
\ Permission to use, copy, modify, distribute, and sell this software and its
\ documentation for any purpose is hereby granted without fee, provided that
\ the above copyright notice appear in all copies and that both that
\ copyright notice and this permission notice appear in supporting
\ documentation.
\
\ The above copyright notice and this permission notice shall be included in
\ all copies or substantial portions of the Software.
\
\ Adapted to Forth by Krishna Myneni, Creative Consulting for
\   Research & Education, http://ccreweb.org
\
\ Requires:
\   struct.4th, struct-ext.4th
\
\ Revisions:
\   2012-06-01  km  created


\  Bitmask returned by XParseGeometry.  Each bit tells if the corresponding
\  value (x, y, width, height) was found in the parsed string.

HEX
00  constant  NoValue         
01  constant  XValue          
02  constant  YValue          
04  constant  WidthValue      
08  constant  HeightValue     
0F  constant  AllValues       
10  constant  XNegative       
20  constant  YNegative       
DECIMAL


\  new version containing base_width, base_height, and win_gravity fields;
\  used with WM_NORMAL_HINTS.

struct
  int32: XSizeHints->flags  \ marks which fields in this structure are defined
  int:   XSizeHints->x      \ obsolete for new window mgrs, but clients
  int:   XSizeHints->y      \ should set so old wm's don't mess up
  int:   XSizeHints->width         
  int:   XSizeHints->height
  int:   XSizeHints->min_width
  int:   XSizeHints->min_height
  int:   XSizeHints->max_width
  int:   XSizeHints->max_height
  int:   XSizeHints->width_inc
  int:   XSizeHints->height_inc
  int:   XSizeHints->min_aspect->x  \ numerator
  int:   XSizeHints->min_aspect->y  \ denominator
  int:   XSizeHints->max_aspect->x
  int:   XSizeHints->max_aspect->y
  int:   XSizeHints->base_width     \ added by ICCCM version 1 
  int:   XSizeHints->base_height
  int:   XSizeHints->win_gravity    \ added by ICCCM version 1
end-struct XSizeHints%


\  The next block of definitions are for window manager properties that
\  clients and applications use for communication.
\ 

\ flags argument in size hints 
1 0 lshift  constant  USPosition    \ user specified x, y 
1 1 lshift  constant  USSize        \ user specified width, height 
1 2 lshift  constant  PPosition     \ program specified position
1 3 lshift  constant  PSize         \ program specified size
1 4 lshift  constant  PMinSize      \ program specified minimum size
1 5 lshift  constant  PMaxSize      \ program specified maximum size
1 6 lshift  constant  PResizeInc    \ program specified resize increments
1 7 lshift  constant  PAspect       \ program specified min and max aspect ratios
1 8 lshift  constant  PBaseSize     \ program specified base for incrementing
1 9 lshift  constant  PWinGravity   \ program specified window gravity

\ obsolete
PPosition PSize or PMinSize or PMaxSize or PResizeInc or PAspect or 
constant PAllHints 

struct
  int32: XWMHints->flags  \ marks which fields in this structure are defined
  int:   XWMHints->input  \ does this application rely on the window manager to
                          \   get keyboard input?
  int:   XWMHints->initial_state   \ see below 
  int:   XWMHints->icon_pixmap     \ pixmap to be used as icon
  int:   XWMHints->icon_window     \ window to be used as icon
  int:   XWMHints->icon_x          \ initial position of icon
  int:   XWMHints->icon_y
  int:   XWMHints->icon_mask       \ icon mask bitmap
  int:   XWMHints->window_group    \ id of related window group
  \ this structure may be extended in the future
end-struct XWMHints%


\ definition for flags of XWMHints

1 0 lshift  constant  InputHint               
1 1 lshift  constant  StateHint               
1 2 lshift  constant  IconPixmapHint          
1 3 lshift  constant  IconWindowHint          
1 4 lshift  constant  IconPositionHint        
1 5 lshift  constant  IconMaskHint            
1 6 lshift  constant  WindowGroupHint         
InputHint StateHint or IconPixmapHint or IconWindowHint or IconPositionHint or
IconMaskHint or WindowGroupHint or  constant AllHints 
1 8 lshift  constant  XUrgencyHint           

\ definitions for initial window state
0  constant  WithdrawnState        \ for windows that are not mapped
1  constant  NormalState   \ most applications want to start this way
3  constant  IconicState   \ application wants to start as an icon

\ Obsolete states no longer defined by ICCCM

0 constant DontCareState  \  don't know or care
2 constant ZoomState      \ application wants to start zoomed
4 constant InactiveState  \ application believes it is seldom used;
                        \ some wm's may put it on inactive menu


\  new structure for manipulating TEXT properties; used with WM_NAME,
\  WM_ICON_NAME, WM_CLIENT_MACHINE, and WM_COMMAND.

struct 
    int:   XTextProperty->value     \ same as Property routines
    int:   XTextProperty->encoding  \ prop type
    int:   XTextProperty->format    \ prop data format: 8, 16, or 32
    int32: XTextProperty->nitems    \ number of data items in value
end-struct XTextProperty%

-1  constant  XNoMemory 
-2  constant  XLocaleNotSupported 
-3  constant  XConverterNotFound 

0 [IF]
typedef enum {
    XStringStyle               \ STRING 
    XCompoundTextStyle         \ COMPOUND_TEXT
    XTextStyle                 \ text in owner's encoding (current locale)
    XStdICCTextStyle           \ STRING, else COMPOUND_TEXT
    \ The following is an XFree86 extension, introduced in November 2000 
    XUTF8StringStyle            \ UTF8_STRING 
} XICCEncodingStyle
[THEN]

struct
  int:  XIconSize->min_width
  int:  XIconSize->min_height
  int:  XIconSize->max_width
  int:  XIconSize->max_height
  int:  XIconSize->width_inc
  int:  XIconSize->height_inc
end-struct XIconSize%


struct
  int: XClassHint->res_name
  int: XClassHint->res_class
end-struct XClassHint%

\ Return values from XRectInRegion

0  constant  RectangleOut
1  constant  RectangleIn  
2  constant  RectanglePart


\  Information used by the visual utility routines to find desired visual
\  type from the many visuals a display may support.

struct
  int:   XVisualInfo->visual
  int:   XVisualInfo->visualid
  int:   XVisualInfo->screen
  int:   XVisualInfo->depth
  int:   XVisualInfo->class
  int32: XVisualInfo->red_mask
  int32: XVisualInfo->green_mask
  int32: XVisualInfo->blue_mask
  int:   XVisualInfo->colormap_size
  int:   XVisualInfo->bits_per_rgb
end-struct XVisualInfo%

HEX
  0  constant  VisualNoMask
  1  constant  VisualIDMask
  2  constant  VisualScreenMask
  4  constant  VisualDepthMask
  8  constant  VisualClassMask
 10  constant  VisualRedMaskMask
 20  constant  VisualGreenMaskMask
 40  constant  VisualBlueMaskMask
 80  constant  VisualColormapSizeMask
100  constant  VisualBitsPerRGBMask
1FF  constant  VisualAllMask
DECIMAL


\  This defines a window manager property that clients may use to
\  share standard color maps of type RGB_COLOR_MAP:
[UNDEFINED] XStandardColormap% [IF]
struct
  int:   XStandardColormap->colormap
  int32: XStandardColormap->red_max
  int32: XStandardColormap->red_mult
  int32: XStandardColormap->green_max
  int32: XStandardColormap->green_mult
  int32: XStandardColormap->blue_max
  int32: XStandardColormap->blue_mult
  int32: XStandardColormap->base_pixel
  int:   XStandardColormap->visualid        \ added by ICCCM version 1
  int:   XStandardColormap->killid          \ added by ICCCM version 1
end-struct XStandardColormap%
[THEN]

 1 constant  ReleaseByFreeingColormap   \ for killid field above

\ return codes for XReadBitmapFile and XWriteBitmapFile

0  constant  BitmapSuccess
1  constant  BitmapOpenFailed
2  constant  BitmapFileInvalid
3  constant  BitmapNoMemory


\ * Context Management


\ Associative lookup table return codes

0  constant XCSUCCESS   \ No error
1  constant XCNOMEM     \ Out of memory
2  constant XCNOENT     \ No entry in table


\ Defining words for data structures
: XSizeHints      create XSizeHints% %allot drop ;
: XWMHints        create XWMHints% %allot drop ;
: XTextProperty   create XTextProperty% %allot drop ;
: XIconSize       create XIconSize% %allot drop ;
: XClassHint      create XClassHint% %allot drop ;
: XVisualInfo     create XVisualInfo% %allot drop ;
[UNDEFINED] XStandardColormap [IF]
: XStandardColormap create XStandardColormap% %allot drop ;
[THEN]





