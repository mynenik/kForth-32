\ Xft.4th
\
\ From /usr/include/X11/Xft/Xft.h
\
\ Original Source Copyright © 2000 Keith Packard
\
\ Permission to use, copy, modify, distribute, and sell this software and its
\ documentation for any purpose is hereby granted without fee, provided that
\ the above copyright notice appear in all copies and that both that
\ copyright notice and this permission notice appear in supporting
\ documentation, and that the name of Keith Packard not be used in
\ advertising or publicity pertaining to distribution of the software without
\ specific, written prior permission.  Keith Packard makes no
\ representations about the suitability of this software for any purpose.  It
\ is provided "as is" without express or implied warranty.
\
\ Forth version by Krishna Myneni, Creative Consulting for Research
\   and Education, http://ccreweb.org
\
\ Revisions:
\
z" core"    ptr  XFT_CORE
z" render"  ptr  XFT_RENDER
z" xlfd"    ptr  XFT_XLFD
z" maxglyphmemory" ptr  XFT_MAX_GLYPH_MEMORY
z" maxunreffonts"  ptr  XFT_MAX_UNREF_FONTS


struct 
    int: XftFont->ascent
    int: XftFont->descent
    int: XftFont->height
    int: XftFont->max_advance_width
    int: XftFont->charset
    int: XftFont->pattern
end-struct XftFont%

struct 
    int: XftColor->pixel
    int: XftColor->color
end-struct XftColor%

struct 
    int:   XftCharSpec->ucs4
    int16: XftCharSpec->x
    int16: XftCharSpec->y
end-struct XftCharSpec%

struct 
    int:   XftCharFontSpec->font
    int:   XftCharFontSpec->ucs4
    int16: XftCharFontSpec->x
    int16: XftCharFontSpec->y
end-struct XftCharFontSpec%

struct 
    int:   XftGlyphSpec->glyph
    int16: XftGlyphSpec->x
    int16: XftGlyphSpec->y
end-struct XftGlyphSpec%

struct 
    int:   XftGlyphFontSpec->font
    int:   XftGlyphFontSpec->glyph
    int16: XftGlyphFontSpec->x
    int16: XftGlyphFontSpec->y
end-struct XftGlyphFontSpec%

\ Defining words for data structures
: XftFont          create XftFont% %allot drop ;
: XftColor         create XftColor% %allot drop ;
: XftCharSpec      create XftCharSpec% %allot drop ;
: XftGlyphSpec     create XftGlyphSpec% %allot drop ;
: XftCharFontSpec  create XftCharFontSpec% %allot drop ;
: XftGlyphFontSpec create XftGlyphFontSpec% %allot drop ;





