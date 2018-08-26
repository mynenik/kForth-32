\ libXft.4th
\
\ From: /usr/X11/Xft/Xft.h
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
\   2012-06-02  km  created

[undefined] struct [IF] s" struct.4th" included     [THEN]
[undefined] int16: [IF] s" struct-ext.4th" included [THEN]

get-current

Vocabulary Xft
Also Xft Definitions

ptr curr_wcl

0 value hndl_Xft
s" libXft.so.2" open-lib        \ change if library name is different 
dup 0= [IF] check-lib-error [THEN]
to hndl_Xft
cr .( Openend the Xft library )

include libs/x11/Xrender.4th
include libs/x11/Xft.4th

\ xftcolor.c

s" XftColorAllocName"  C-word  XftColorAllocName ( adpy avisual ncmap \
   aname aresult -- n )
s" XftColorAllocValue"  C-word XftColorAllocValue ( adpy avisual ncmap \
   acolor aresult -- n )
s" XftColorFree" C-word XftColorFree ( adpy  avisual ncmap acolor -- )


\ xftdpy.c

s" XftDefaultHasRender"  C-word  XftDefaultHasRender ( adpy -- n )
s" XftDefaultSet"        C-word  XftDefaultSet ( adpy adefaults -- n )
s" XftDefaultSubstitute" C-word  XftDefaultSubstitute ( adpy nscreen \
    apattern -- )

\ xftdraw.c

s" XftDrawCreate" C-word XftDrawCreate ( adpy ndrawable avisual \
     ncolormap -- axftdraw )
s" XftDrawCreateBitmap" C-word  XftDrawCreateBitmap ( adpy nbitmap -- adraw )
s" XftDrawCreateAlpha"  C-word  XftDrawCreateAlpha ( adpy npixmap ndepth -- adraw )
s" XftDrawChange"       C-word  XftDrawChange ( adraw ndrawable -- )
s" XftDrawDisplay"      C-word  XftDrawDisplay ( adraw -- adpy )
s" XftDrawDrawable"     C-word  XftDrawDrawable ( adraw -- ndrawable )
s" XftDrawColormap"     C-word  XftDrawColormap ( adraw -- ncolormap )
s" XftDrawVisual"       C-word  XftDrawVisual ( adraw -- avisual )
s" XftDrawDestroy"      C-word  XftDrawDestroy ( adraw -- )
s" XftDrawPicture"      C-word  XftDrawPicture ( adraw -- npicture )
s" XftDrawSrcPicture"   C-word  XftDrawSrcPicture ( adraw acolor -- npicture )
s" XftDrawGlyphs"       C-word  XftDrawGlyphs ( adraw  acolor apub \
     nx  ny  aglyphs  nglyphs -- )
s" XftDrawString8"      C-word  XftDrawString8 ( adraw  acolor  apub  \
   nx  ny  astring  nlen -- )
s" XftDrawString16"     C-word  XftDrawString16 ( adraw  acolor  apub \
   nx  ny  astring  nlen -- )
s" XftDrawString32"     C-word  XftDrawString32 ( adraw  acolor apub \
   nx  ny  astring  nlen -- )
s" XftDrawStringUtf8"   C-word  XftDrawStringUtf8 ( adraw  acolor  apub \
   nx  ny  astring  nlen -- )
s" XftDrawStringUtf16"  C-word  XftDrawStringUtf16 ( adraw  acolor  apub  \ 
   nx  ny  astring  nendian  nlen -- )
s" XftDrawCharSpec"     C-word  XftDrawCharSpec ( adraw  acolor  apub \
   achars  nlen -- )
s" XftDrawCharFontSpec" C-word  XftDrawCharFontSpec ( adraw  acolor \
   achars  nlen -- )
s" XftDrawGlyphSpec"    C-word  XftDrawGlyphSpec ( adraw  acolor  apub \
   aglyphs  nlen -- )
s" XftDrawGlyphFontSpec" C-word XftDrawGlyphFontSpec ( adraw  acolor \
   aglyphs  nlen -- )
s" XftDrawRect"         C-word  XftDrawRect ( adraw  acolor \
   nx  ny  nwidth  nheight -- )
s" XftDrawSetClip"      C-word  XftDrawSetClip ( adraw  nr -- nflag )
s" XftDrawSetClipRectangles" C-word XftDrawSetClipRectangles ( adraw \
   nxOrigin  nyOrigin  arects  n -- nflag )
s" XftDrawSetSubwindowMode" C-word XftDrawSetSubwindowMode ( adraw  nmode -- )


\ xftextent.c

s" XftGlyphExtents"     C-word  XftGlyphExtents ( adpy  apub \
   aglyphs  nglyphs  aextents -- )
s" XftTextExtents8"     C-word  XftTextExtents8 ( adpy  apub \
   astring  nlen  aextents -- )
s" XftTextExtents16"    C-word  XftTextExtents16 ( adpy  apub \
   astring  nlen  aextents -- )
s" XftTextExtents32"    C-word  XftTextExtents32 ( adpy  apub \
   astring  nlen  aextents -- )
s" XftTextExtentsUtf8"  C-word  XftTextExtentsUtf8 ( adpy  apub \
   astring  nlen  aextents -- )
s" XftTextExtentsUtf16" C-word  XftTextExtentsUtf16 ( adpy  apub \
   astring  nendian  nlen  aextents -- )

\ xftfont.c

s" XftFontMatch" C-word XftFontMatch ( adpy  nscreen \
   apattern  aresult -- apattern )

\ XftFont *  XftFontOpen (Display *dpy, int screen, ...) _X_SENTINEL(0);

s" XftFontOpenName" C-word XftFontOpenName ( adpy  nscreen  aname -- afont )
s" XftFontOpenXlfd" C-word XftFontOpenXlfd ( adpy  nscreen axlfd -- afont )


\ xftfreetype.c

s" XftLockFace"        C-word  XftLockFace ( apub -- n )
s" XftUnlockFace"      C-word  XftUnlockFace ( apub -- )
s" XftFontInfoCreate"  C-word  XftFontInfoCreate ( adpy  apat -- afi )
s" XftFontInfoDestroy" C-word  XftFontInfoDestroy ( adpy afi -- )
s" XftFontInfoHash"    C-word  XftFontInfoHash ( afi -- n )
s" XftFontInfoEqual"   C-word  XftFontInfoEqual ( afi_a  afi_b -- n )
s" XftFontOpenInfo"    C-word  XftFontOpenInfo  ( adpy  apat  afi -- afont )
s" XftFontOpenPattern" C-word  XftFontOpenPattern ( adpy  apat -- afont )
s" XftFontCopy"        C-word  XftFontCopy ( adpy  apub -- afont )
s" XftFontClose"       C-word  XftFontClose ( adpy  apub -- )
s" XftInitFtLibrary"   C-word  XftInitFtLibrary ( -- n )


\ xftglyphs.c

s" XftFontLoadGlyphs"   C-word  XftFontLoadGlyphs ( adpy  apub \
   need_bmps  aglyphs  nglyph -- )
s" XftFontUnloadGlyphs" C-word  XftFontUnloadGlyphs ( adpy  apub \
   aglyphs  nglyph -- )

256  constant  XFT_NMISSING            

s" XftFontCheckGlyph"  C-word  XftFontCheckGlyph ( adpy  apub \
   need_bmps  nglyph  amissing  anmissing -- n )
s" XftCharExists"      C-word  XftCharExists ( adpy  apub  nucs4 -- n )
s" XftCharIndex"       C-word  XftCharIndex  ( adpy  apub  nucs4 -- n )

\ xftinit.c

s" XftInit"        C-word  XftInit ( aconfig -- n )
s" XftGetVersion"  C-word  XftGetVersion ( -- n )

\ xftlist.c

\ FcFontSet * XftListFonts (Display *dpy, int screen, ...) _X_SENTINEL(0);

\ xftname.c

s" XftNameParse"  C-word  XftNameParse ( aname -- apat )


\ xftrender.c

s" XftGlyphRender"     C-word XftGlyphRender ( adpy  nop  nsrc  apub \
   ndst  nsrcx  nsrcy  nx  ny  aglyphs  nglyphs -- )
s" XftGlyphSpecRender" C-word  XftGlyphSpecRender ( adpy  nop  nsrc  apub \
   ndst  nsrcx  nsrcy  aglyphs  nglyphs -- )
s" XftCharSpecRender"  C-word  XftCharSpecRender ( adpy  nop  nsrc  apub \
   ndst  nsrcx  nsrcy  achars  nlen -- )
s" XftGlyphFontSpecRender" C-word  XftGlyphFontSpecRender ( adpy  nop  \ 
   nsrc  ndst  nsrcx  nsrcy  aglyphs  nglyphs -- )
s" XftCharFontSpecRender"  C-word  XftCharFontSpecRender ( adpy  nop \
   nsrc  ndst  nsrcx  nsrcy  achars  nlen -- )
s" XftTextRender8"     C-word  XftTextRender8 ( adpy  nop  nsrc  apub \
   ndst  nsrcx  nsrcy  nx  ny  astring  nlen -- )
s" XftTextRender16"    C-word  XftTextRender16 ( adpy  nop  nsrc  apub \
   ndst  nsrcx  nsrcy  nx  ny  astring  nlen -- )
s" XftTextRender16BE"  C-word  XftTextRender16BE ( adpy  nop  nsrc  apub \
   ndst  nsrcx  nsrcy  nx  ny  astring  nlen -- )
s" XftTextRender16LE"  C-word  XftTextRender16LE ( adpy  nop  nsrc  apub \
   ndst  nsrcx  nsrcy  nx  ny  astring  nlen -- )
s" XftTextRender32"    C-word  XftTextRender32 ( adpy  nop  nsrc  apub \
   ndst  nsrcx  nsrcy  nx  ny  astring  nlen -- )
s" XftTextRender32BE"  C-word  XftTextRender32BE ( adpy  nop  nsrc  apub \
   ndst  nsrcx  nsrcy  nx  ny  astring  nlen -- )
s" XftTextRender32LE"  C-word  XftTextRender32LE ( adpy  nop  nsrc  apub \
   ndst  nsrcx  nsrcy  nx  ny  astring  nlen -- )
s" XftTextRenderUtf8"  C-word  XftTextRenderUtf8 ( adpy  nop  nsrc  apub \
   ndst  nsrcx  nsrcy  nx  ny  astring  nlen -- )
s" XftTextRenderUtf16" C-word  XftTextRenderUtf16 ( adpy  nop  nsrc  apub \
   ndst  nsrcx  nsrcy  nx  ny  astring  nendian nlen -- )

\ xftxlfd.c 

s" XftXlfdParse"  C-word  XftXlfdParse ( axlfd_orig \
   nignore_scalable  ncomplete -- apat )


curr_wcl set-current
previous



