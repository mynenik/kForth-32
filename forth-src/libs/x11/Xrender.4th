\ Xrender.4th
\
\ Based on /usr/include/X11/extensions/Xrender.h
\
\ Original Source Copyright © 2000 SuSE, Inc.
\ Original Author:  Keith Packard, SuSE, Inc.
\
\ Permission to use, copy, modify, distribute, and sell this software and its
\ documentation for any purpose is hereby granted without fee, provided that
\ the above copyright notice appear in all copies and that both that
\ copyright notice and this permission notice appear in supporting
\ documentation, and that the name of SuSE not be used in advertising or
\ publicity pertaining to distribution of the software without specific,
\ written prior permission.  SuSE makes no representations about the
\ suitability of this software for any purpose.  It is provided "as is"
\ without express or implied warranty.
\
\ Forth translation by Krishna Myneni, Creative Consulting for
\   Research and Education, http://ccreweb.org
\  
\ Revisions:
\   2012-06-02  km  created.

struct 
    int16:   XRenderDirF->red
    int16:   XRenderDirF->redMask
    int16:   XRenderDirF->green
    int16:   XRenderDirF->greenMask
    int16:   XRenderDirF->blue
    int16:   XRenderDirF->blueMask
    int16:   XRenderDirF->alpha
    int16:   XRenderDirF->alphaMask
end-struct XRenderDirectF%


struct
    int:  XRenderPictFmt->id
    int:  XRenderPictFmt->type
    int:  XRenderPictFmt->depth
    int:  XRenderPictFmt->direct
    int:  XRenderPictFmt->colormap
end-struct XRenderPictFormat%


1  0 lshift  constant  PictFormatID        
1  1 lshift  constant  PictFormatType      
1  2 lshift  constant  PictFormatDepth     
1  3 lshift  constant  PictFormatRed       
1  4 lshift  constant  PictFormatRedMask   
1  5 lshift  constant  PictFormatGreen     
1  6 lshift  constant  PictFormatGreenMask 
1  7 lshift  constant  PictFormatBlue      
1  8 lshift  constant  PictFormatBlueMask  
1  9 lshift  constant  PictFormatAlpha     
1 10 lshift  constant  PictFormatAlphaMask 
1 11 lshift  constant  PictFormatColormap  

struct
    int:  XRenderPictAttr->repeat
    int:  XRenderPictAttr->alpha_map
    int:  XRenderPictAttr->alpha_x_origin
    int:  XRenderPictAttr->alpha_y_origin
    int:  XRenderPictAttr->clip_x_origin
    int:  XRenderPictAttr->clip_y_origin
    int:  XRenderPictAttr->clip_mask
    int:  XRenderPictAttr->graphics_exposures
    int:  XRenderPictAttr->subwindow_mode
    int:  XRenderPictAttr->poly_edge
    int:  XRenderPictAttr->poly_mode
    int:  XRenderPictAttr->dither
    int:  XRenderPictAttr->component_alpha
end-struct XRenderPictureAttributes%

struct
    int16:  XRenderColor->red
    int16:  XRenderColor->green
    int16:  XRenderColor->blue
    int16:  XRenderColor->alpha
end-struct XRenderColor%


struct
    int16: XGlyphInfo->width
    int16: XGlyphInfo->height
    int16: XGlyphInfo->x
    int16: XGlyphInfo->y
    int16: XGlyphInfo->xOff
    int16: XGlyphInfo->yOff
end-struct XGlyphInfo%

\ Defining words for data structures

: XRenderColor     create XRenderColor% %allot drop ;
: XGlyphInfo       create XGlyphInfo% %allot drop ;




