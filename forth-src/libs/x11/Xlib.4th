\ Xlib.4th
\
\ Selected definitions from /usr/include/Xlib.h
\
\ Copyright 1985, 1986, 1987, 1991, 1998  The Open Group
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
\ Adapted to Forth by:
\
\ Krishna Myneni, Creative Consulting for Research & Education
\ krishna.myneni@ccreweb.org
\
\ Requires:
\   struct.4th, struct-ext.4th
\
\ Revisions:
\   2009-11-05  km  added constant from Xlib.h
\   2011-08-25  km  added structure XExposeEvent
\   2012-06-01  km  conditional defn of XStandardColormap% structure
\                   and defining word, XStandardColormap . These now
\                   also appear in the new Xutil.4th.
\   2012-06-02  km  added structure XClientEvent% 

0  invert  constant  AllPlanes

[UNDEFINED] XStandardColormap% [IF]
\ Standard colormap structure
struct 
        int:  XStandardColormap->colormap
        int32:  XStandardColormap->red_max
        int32:  XStandardColormap->red_mult
        int32:  XStandardColormap->green_max
        int32:  XStandardColormap->green_mult
        int32:  XStandardColormap->blue_max
        int32:  XStandardColormap->blue_mult
        int32:  XStandardColormap->base_pixel
        int:    XStandardColormap->visualid      \ added by ICCCM version 1 
        int:    XStandardColormap->killid        \ added by ICCCM version 1
end-struct XStandardColormap%
[THEN]


\ Data structure for setting window attributes.

struct
    int: XSetWindowAttributes->background_pixmap   \ background or None or ParentRelative 
    int32: XSetWindowAttributes->background_pixel  \ background pixel 
    int: XSetWindowAttributes->border_pixmap       \ border of the window
    int32: XSetWindowAttributes->border_pixel      \ border pixel value
    int: XSetWindowAttributes->bit_gravity         \ one of bit gravity values
    int: XSetWindowAttributes->win_gravity         \ one of the window gravity values
    int: XSetWindowAttributes->backing_store       \ NotUseful, WhenMapped, Always
    int32: XSetWindowAttributes->backing_planes    \ planes to be preseved if possible
    int32: XSetWindowAttributes->backing_pixel     \ value to use in restoring planes
    int: XSetWindowAttributes->save_under          \ should bits under be saved? (popups)
    int32: XSetWindowAttributes->event_mask        \ set of events that should be saved
    int32: XSetWindowAttributes->do_not_propagate_mask \ set of events that should not propagate
    int: XSetWindowAttributes->override_redirect   \ boolean value for override-redirect
    int: XSetWindowAttributes->colormap            \ color map to be associated with window
    int: XSetWindowAttributes->cursor              \ cursor to be displayed (or None)
end-struct XSetWindowAttributes%


struct
    int: XWindowAttributes->x
    int: XWindowAttributes->y              \ location of window
    int: XWindowAttributes->width
    int: XWindowAttributes->height         \ width and height of window
    int: XWindowAttributes->border_width   \ border width of window
    int: XWindowAttributes->depth          \ depth of window
    int: XWindowAttributes->visual         \ the associated visual structure
    int: XWindowAttributes->root           \ root window of screen containing window
    int: XWindowAttributes->class          \ InputOutput, InputOnly
    int: XWindowAttributes->bit_gravity    \ one of bit gravity values
    int: XWindowAttributes->win_gravity    \ one of the window gravity values
    int: XWindowAttributes->backing_store  \ NotUseful, WhenMapped, Always
    int: XWindowAttributes->backing_planes \ planes to be preserved if possible
    int: XWindowAttributes->backing_pixel  \ value to be used when restoring planes
    int: XWindowAttributes->save_under     \ boolean, should bits under be saved?
    int: XWindowAttributes->colormap       \ color map to be associated with window
    int: XWindowAttributes->map_installed  \ boolean, is color map currently installed
    int: XWindowAttributes->map_state      \ IsUnmapped, IsUnviewable, IsViewable
    int32: XWindowAttributes->all_event_masks  \ set of events all people have interest in
    int32: XWindowAttributes->your_event_mask  \ my event mask
    int32: XWindowAttributes->do_not_propagate_mask \ set of events that should not propagate
    int: XWindowAttributes->override_redirect  \ boolean value for override-redirect
    int: XWindowAttributes->screen         \ back pointer to correct screen
end-struct XWindowAttributes%


\ Data structure for host setting; getting routines.

struct
    int: XHostAddress->family   \ for example FamilyInternet
    int: XHostAddress->length   \ length of address, in bytes
    int: XHostAddress->address  \ pointer to where to find the bytes
end-struct XHostAddress%

\ Data structure for ServerFamilyInterpreted addresses in host routines

struct
    int: XServerIntrepretedAddress->typelength     \ length of type string, in bytes
    int: XServerInterpretedAddress->valuelength    \ length of value string, in bytes
    int: XServerInterpretedAddress->type           \ pointer to where to find the type string
    int: XServerIntrepretedAddress->value          \ pointer to where to find the address
end-struct XServerInterpretedAddress%



\ Data structure for "image" data, used by image manipulation routines.

struct
    int: XImage->width 
    int: XImage->height         \ size of image
    int: XImage->xoffset        \ number of pixels offset in X direction
    int: XImage->format         \ XYBitmap, XYPixmap, ZPixmap
    int: XImage->data           \ pointer to image data
    int: XImage->byte_order     \ data byte order, LSBFirst, MSBFirst
    int: XImage->bitmap_unit    \ quant. of scanline 8, 16, 32
    int: XImage->bitmap_bit_order \ LSBFirst, MSBFirst
    int: XImage->bitmap_pad     \ 8, 16, 32 either XY or ZPixmap
    int: XImage->depth          \ depth of image
    int: XImage->bytes_per_line \ accelarator to next line
    int: XImage->bits_per_pixel \ bits per pixel (ZPixmap)
    int: XImage->red_mask       \ bits in z arrangment
    int: XImage->green_mask
    int: XImage->blue_mask
    int: XImage->obdata         \ pointer; hook for the object routines to hang on
\    struct funcs {              \ image manipulation routines
\        struct _XImage *(*create_image)(
\                struct _XDisplay* \ display
\                Visual*         \ visual
\                unsigned int    \ depth
\                int             \ format
\                int             \ offset
\                char*           \ data
\                unsigned int    \ width
\                unsigned int    \ height
\                int             \ bitmap_pad
\                int             \ bytes_per_line
\        int (*destroy_image)        (struct _XImage *);
\        unsigned long (*get_pixel)  (struct _XImage *, int, int);
\        int (*put_pixel)            (struct _XImage *, int, int, unsigned long);
\        struct _XImage *(*sub_image)(struct _XImage *, int, int, unsigned int, unsigned int);
\        int (*add_pixel)            (struct _XImage *, long);
\        } f;
    int: XImage->f->create_image
    int: XImage->f->destroy_image
    int: XImage->f->get_pixel
    int: XImage->f->put_pixel
    int: XImage->f->sub_image
    int: XImage->f->add_pixel
end-struct XImage%


struct
  int32: XColor->pixel
  int16: XColor->red
  int16: XColor->green
  int16: XColor->blue
  byte:  XColor->flags
  byte:  XColor->pad
end-struct XColor%


struct
  int16: XSegment->x1
  int16: XSegment->y1
  int16: XSegment->x2
  int16: XSegment->y2
end-struct XSegment%


struct
  int16: XPoint->x
  int16: XPoint->y
end-struct XPoint%


struct
  int16: XRectangle->x
  int16: XRectangle->y
  int16: XRectangle->width
  int16: XRectangle->height
end-struct XRectangle%


struct
  int16: XArc->x
  int16: XArc->y
  int16: XArc->width
  int16: XArc->height
  int16: XArc->angle1
  int16: XArc->angle2
end-struct XArc%


struct
  int: XKeyboardControl->key_click_percent
  int: XKeyboardControl->bell_percent
  int: XKeyboardControl->bell_pitch
  int: XKeyboardControl->bell_duration
  int: XKeyboardControl->led
  int: XKeyboardControl->led_mode
  int: XKeyboardControl->key
  int: XKeyboardControl->auto_repeat_mode
end-struct XKeyboardControl%


struct
  int: XKeyboardState->key_click_percent
  int: XKeyboardState->bell_percent
  int: XKeyboardState->bell_pitch
  int: XKeyboardState->bell_duration
  int32: led_mask
  int: XKeyboardState->global_auto_repeat
  32 buf: XKeyboardState->auto_repeats
end-struct XKeyboardState%

struct
  int: XTimeCoord->time
  int16: XTimeCoord->x
  int16: XTimeCoord->y
end-struct XTimeCoord%

struct
  int: XModifierKeymap->max_keypermod
  int: XModifierKeymap->modifiermap
end-struct XModifierKeymap%


\ Definitions of specific events

struct
  int: XExposeEvent->type
  int32: XExposeEvent->serial
  int: XExposeEvent->send_event
  int: XExposeEvent->display
  int: XExposeEvent->window
  int: XExposeEvent->x
  int: XExposeEvent->y
  int: XExposeEvent->width
  int: XExposeEvent->height
  int: XExposeEvent->count
end-struct XExposeEvent%

struct
  int: XKeyEvent->type
  int32: XKeyEvent->serial
  int: XKeyEvent->send_event
  int: XKeyEvent->display
  int: XKeyEvent->window
  int: XKeyEvent->root
  int: XKeyEvent->subwindow
  int: XKeyEvent->time
  int: XKeyEvent->x
  int: XKeyEvent->y
  int: XKeyEvent->x_root
  int: XKeyEvent->y_root
  int: XKeyEvent->state
  int: XKeyEvent->keycode
  int: XKeyEvent->same_screen
end-struct XKeyEvent%

struct
  int: XButtonEvent->type
  int32: XButtonEvent->serial
  int: XButtonEvent->send_event
  int: XButtonEvent->display
  int: XButtonEvent->window
  int: XButtonEvent->root
  int: XButtonEvent->subwindow
  int: XButtonEvent->time
  int: XButtonEvent->x
  int: XButtonEvent->y
  int: XButtonEvent->x_root
  int: XButtonEvent->y_root
  int: XButtonEvent->state
  int: XButtonEvent->button
  int: XButtonEvent->same_screen
end-struct XButtonEvent%

struct
  int: XMotionEvent->type
  int32: XMotionEvent->serial
  int: XMotionEvent->send_event
  int: XMotionEvent->display
  int: XMotionEvent->window
  int: XMotionEvent->root
  int: XMotionEvent->subwindow
  int: XMotionEvent->time
  int: XMotionEvent->x
  int: XMotionEvent->y
  int: XMotionEvent->x_root
  int: XMotionEvent->y_root
  int: XMotionEvent->state
  int: XMotionEvent->is_hint
  int: XMotionEvent->same_screen
end-struct XMotionEvent%

struct 
  int: XConfigureRequestEvent->type
  int: XConfigureRequestEvent->serial   \ # of last request processed by server
  int: XConfigureRequestEvent->send_event \ true if this came from a SendEvent request
  int: XConfigureRequestEvent->display    \ Display the event was read from 
  int: XConfigureRequestEvent->parent
  int: XConfigureRequestEvent->window
  int: XConfigureRequestEvent->x
  int: XConfigureRequestEvent->y
  int: XConfigureRequestEvent->width
  int: XConfigureRequestEvent->height
  int: XConfigureRequestEvent->border_width
  int: XConfigureRequestEvent->above
  int: XConfigureRequestEvent->detail   \ Above, Below, TopIf, BottomIf, Opposite
  int: XConfigureRequestEvent->value_mask
end-struct XConfigureRequestEvent%

struct
  int: XClientMessageEvent->type
  int32: XClientMessageEvent->serial   \ # of last request processed by server
  int: XClientMessageEvent->send_event \ true if this came from a SendEvent request
  int: XClientMessageEvent->display    \ Display the event was read from
  int: XClientMessageEvent->window
  int: XClientMessageEvent->message_type
  int: XClientMessageEvent->format
  20 buf: XClientMessageEvent->data
end-struct XClientMessageEvent%

struct
  int: XErrorEvent->type
  int: XErrorEvent->display
  int: XErrorEvent->resourceid
  int32: XErrorEvent->serial
  byte: XErrorEvent->error_code
  byte: XErrorEvent->request_code
  byte: XErrorEvent->minor_code
  byte: XErrorEvent->pad
end-struct XErrorEvent%


struct
  int: XAnyEvent->type
  int32: XAnyEvent->serial
  int: XAnyEvent->send_event
  int: XAnyEvent->display
  int: XAnyEvent->window
end-struct XAnyEvent%


\ per character font metric information.

struct 
    int16: XCharStruct->lbearing       \ origin to left edge of raster
    int16: XCharStruct->rbearing       \ origin to right edge of raster
    int16: XCharStruct->width          \ advance to next char's origin
    int16: XCharStruct->ascent         \ baseline to top edge of raster
    int16: XCharStruct->descent        \ baseline to bottom edge of raster
    int16: XCharStruct->attributes     \ per char flags (not predefined)
end-struct XCharStruct%


struct 
    int: XFontProp->name
    int: XFontProp->card32
end-struct XFontProp%


struct 
    int: XFontStruct->ext_data      \ hook for extension to hang data
    int: XFontStruct->fid           \ Font id for this font
    int: XFontStruct->direction     \ hint about direction the font is painted
    int: XFontStruct->min_char_or_byte2  \ first character
    int: XFontStruct->max_char_or_byte2  \ last character
    int: XFontStruct->min_byte1     \ first row that exists
    int: XFontStruct->max_byte1     \ last row that exists
    int: XFontStruct->all_chars_exist \ flag if all characters have non-zero size
    int: XFontStruct->default_char  \ char to print for undefined character
    int: XFontStruct->n_properties  \ how many properties there are
    int: XFontStruct->properties    \ pointer to array of additional properties
    XCharStruct% %size buf: XFontStruct->min_bounds \ minimum bounds over all existing char
    XCharStruct% %size buf: XFontStruct->max_bounds \ maximum bounds over all existing char
    int: XFontStruct->per_char      \ pointer; first_char to last_char information
    int: XFontStruct->ascent        \ log. extent above baseline for spacing
    int: XFontStruct->descent       \ log. descent below baseline for spacing
end-struct XFontStruct%



\ Ensure that our defined structures have the same
\ sizes as in the C definitions in Xlib.h, compiled
\ under 32-bits.

: check-struct-size ( u1 u2 -- )
     <> ABORT" Incorrect structure size!"
;

\ XStandardColormap%  %size xx check-struct-size
XSetWindowAttributes% %size 60 check-struct-size
XWindowAttributes%    %size 92 check-struct-size
XHostAddress%         %size 12 check-struct-size
XServerInterpretedAddress% %size 16 check-struct-size
XImage%           %size 88 check-struct-size
XColor%           %size 12 check-struct-size
XSegment%         %size  8 check-struct-size
XPoint%           %size  4 check-struct-size
XRectangle%       %size  8 check-struct-size
XArc%             %size 12 check-struct-size
XKeyboardControl% %size 32 check-struct-size
XKeyboardState%   %size 56 check-struct-size
XTimeCoord%       %size  8 check-struct-size
XModifierKeymap%  %size  8 check-struct-size
XKeyEvent%        %size 60 check-struct-size
XButtonEvent%     %size 60 check-struct-size
XMotionEvent%     %size 60 check-struct-size
XErrorEvent%      %size 20 check-struct-size
XAnyEvent%        %size 20 check-struct-size
XCharStruct%      %size 12 check-struct-size
XFontProp%        %size  8 check-struct-size
XFontStruct%      %size 80 check-struct-size

\ Defining words for data structures
[UNDEFINED] XStandardColormap [IF]
: XStandardColormap create XStandardColormap% %allot drop ;
[THEN]
: XImage   create XImage% %allot drop ;
: XColor   create XColor% %allot drop ;
: XSegment create XSegment% %allot drop ;
: XPoint   create XPoint% %allot drop ;
: XArc     create XArc% %allot drop ;
: XKeyboardControl create XKeyboardControl% %allot drop ;
: XKeyboardState   create XKeyboardState% %allot drop ;
: XTimeCoord       create XTimeCoord% %allot drop ;
: XModifierKeymap  create XModifierKeymap% %allot drop ;
: XEvent           create 32 cells allot ;
: XFontStruct      create XFontStruct% %allot drop ;


