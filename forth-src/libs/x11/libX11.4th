\ X11 interface
\
\ Forth words for interfacing to X Windows (ver. 11).
\ Provides words corresponding to the C interface (Xlib).
\ 
\ Krishna Myneni, Creative Consulting for Research and Education,
\ krishna.myneni@ccreweb.org
\
\ Notes:
\
\ 1. Much of this file was adapted from x11.fs in reference [1]
\
\ 2. For a lucid overview and introduction to X Windows programming,
\    see Ref. [3]. A detailed function reference in provided in [4].
\
\
\ References:
\
\ [1] bigForth, v. 2.3.1, Bernd Paysan, 
\     http://www.jwdt.com/~paysan/bigforth.html
\     see the file, x11.fs, from the bigForth package.
\
\ [2] Xorg, http://www.x.org, release X11R?
\       Xlib header files: X.h, Xlib.h
\
\ [3] Xlib Programming Manual for version 11, by Adrian Nye, 
\     O'Reilly and Associates
\
\ [4] Xlib Reference Manual for version 11, ed. by Adrian Nye, 
\     O'Reilly and Associates
\
\ Revisions:
\   2009-10-27  km  continue to add and group functions
\   2009-11-04  km  further reorganization and additions
\   2012-05-04  km  restore search order and compilation wordlist
\                   after loading. Dependent programs should now
\                   declare "Also X11" to place the X11 vocabulary
\                   in the search order.
\   2012-06-01  km  added XTranslateCoordinates, XReconfigureWMWindow,
\                   XRotateWindowProperties, XTextExtents, XTextExtents16,
\                   XSetIconName, XCheckIfEvent, XPeekIfEvent,
\                   XSetCommand, XSetNormalHints, XSetZoomHints,
\                   XSetSizeHints, XStringListToTextProperty;
\                   include new required files, Xatom.4th and Xutil.4th;
\                   use paths to x11 library files.
\   2012-06-02  km  added XSetTransientForHint, XSetClassHint,
\                   XSetWMHints, XSetWMNormalHints, XSetWMSizeHints,
\                   XSetWMClientMachine, XSetWMColormapWindows, 
\                   XSetWMProperties, XSetWMIconName, XSetWMProtocols,
\                   XWMGeometry, XMatchVisualInfo, 
\                   XSetStandardProperties, XSaveContext, Xpermalloc,
\                   XSetICFocus, XUnsetICFocus, XOpenOM, XGetIconSizes,
\                   XSetIconSizes, Xrm* words ; fix return values for
\                   XSetWMName and XSetWMIconName. 


[undefined] struct [IF] s" struct.4th" included     [THEN]
[undefined] int16: [IF] s" struct-ext.4th" included [THEN]

get-current

Vocabulary X11
Also X11 Definitions

ptr curr_wcl

0 value hndl_X11
s" libX11.so.6" open-lib        \ change if library name is different 
dup 0= [IF] check-lib-error [THEN]
to hndl_X11
cr .( Openend the X11 library )

include libs/x11/X.4th
include libs/x11/Xatom.4th
include libs/x11/Xlib.4th
include libs/x11/Xutil.4th

base @ hex

: noop ;
' noop alias has-utf8
' noop alias has-png
' noop alias has-xft

s" XSync"           C-word  XSync       ( adpy ndiscard -- n )
s" XFlush"          C-word  XFlush      ( adpy -- n )

s" XMaxRequestSize"      C-word  XMaxRequestSize      ( adpy -- n )
s" XExtendedMaxRequestSize" C-word XExtendedMaxRequestSize ( adpy -- n )
s" XResourceManagerString" C-word XResourceManagerString ( adpy -- astring )
s" XScreenResourceString" C-word XScreenResourceString ( ascreen -- astring )
s" XVisualIDFromVisual"  C-word  XVisualIDFromVisual  ( avisual -- nvisualID )
s" XAddExtension"        C-word  XAddExtension        ( adpy -- aextcodes )
s" XEHeadOfExtensionList" C-word XEHeadOfExtensionList ( nobject -- aaextdata )
s" XDefaultRootWindow"   C-word  XDefaultRootWindow   ( adpy -- nwindow )
s" XRootWindowOfScreen"  C-word  XRootWindowOfScreen  ( ascreen -- nwindow )
s" XDefaultVisualOfScreen" C-word XDefaultVisualOfScreen ( ascreen -- avisual )
s" XDefaultGCOfScreen"   C-word  XDefaultGCOfScreen   ( ascreen -- ngc )
s" XBlackPixelOfScreen"  C-word  XBlackPixelOfScreen  ( ascreen -- u )
s" XWhitePixelOfScreen"  C-word  XWhitePixelOfScreen  ( ascreen -- u )
s" XNextRequest"         C-word  XNextRequest         ( adpy -- u )
s" XLastKnownRequestProcessed" C-word XLastKnownRequestProcessed ( adpy -- u )

s" XDisplayString"       C-word  XDisplayString       ( adpy -- astring )
s" XDefaultColormapOfScreen" C-word XDefaultColormapOfScreen ( ascreen -- ncolormap )
s" XDefaultScreenOfDisplay" C-word XDefaultScreenOfDisplay ( adpy -- ascreen )
s" XEventMaskOfScreen"   C-word  XEventMaskOfScreen   ( ascreen -- nmask )
s" XConnectionNumber"    C-word  XConnectionNumber    ( adpy -- n )
s" XDefaultDepthOfScreen" C-word XDefaultDepthOfScreen ( ascreen -- n )
s" XDefaultScreen"       C-word  XDefaultScreen       ( adpy -- n )
s" XDoesBackingStore"    C-word  XDoesBackingStore    ( ascreen -- n )
s" XDoesSaveUnders"      C-word  XDoesSaveUnders      ( ascreen -- nflag )
s" XMaxCmapsOfScreen"    C-word  XMaxCmapsOfScreen    ( ascreen -- n )
s" XMinCmapsOfScreen"    C-word  XMinCmapsOfScreen    ( ascreen -- n )

\ s" XContextualDrawing"   C-word  XContextualDrawing   ( fontset -- flag )
\ s" XwcResetIC"           C-word  XwcResetIC           ( ic -- wstring )
\ s" XmbResetIC"           C-word  XmbResetIC           ( ic -- string )
\ s" XwcFreeStringList"    C-word  XwcFreeStringList    ( list -- r )
s" Xpermalloc"           C-word  Xpermalloc           ( nsize -- addr )


\ Host Access functions

s" XAddHost"    C-word  XAddHost        ( adpy ahost -- n )
s" XAddHosts"   C-word  XAddHosts       ( adpy ahosts nhosts -- n )
s" XDisableAccessControl" C-word XDisableAccessControl ( adpy -- n )
s" XEnableAccessControl"  C-word  XEnableAccessControl ( adpy -- n )
s" XListHosts"   C-word  XListHosts     ( adpy anhosts_r anstate_r -- alist )
s" XRemoveHost"  C-word  XRemoveHost    ( adpy ahost -- n )
s" XRemoveHosts" C-word  XRemoveHosts   ( adpy ahosts num_hosts -- n )
s" XSetAccessControl" C-word  XSetAccessControl  ( adpy nmode -- n )


\ Client functions

s" XKillClient"       C-word  XKillClient        ( adpy nresource -- n )
s" XSetCloseDownMode" C-word  XSetCloseDownMode  ( adpy nclose_mode -- n )


\ Housekeeping functions

s" XActivateScreenSaver" C-word  XActivateScreenSaver ( adpy -- n )
s" XForceScreenSaver"    C-word  XForceScreenSaver    ( adpy nmode -- n )
s" XFree"           C-word  XFree           ( adata -- n )
s" XFreeStringList" C-word  XFreeStringList ( aalist --  )
s" XGetScreenSaver" C-word  XGetScreenSaver ( adpy atimeout_r \
     ainterval_r  aprefer_blanking_r  allow_exposures_r -- n )
s" XLastKnownRequestProcessed"  C-word XLastKnownRequestProcessed  ( adpy -- u )
s" XLockDisplay"    C-word  XLockDisplay     ( adpy --  )
s" XNoOp"           C-word  XNoOp            ( adpy -- n )
s" XUnlockDisplay"  C-word  XUnlockDisplay   ( adpy --  )
s" XSetScreenSaver" C-word  XSetScreenSaver  ( adpy ntimeout ninterval \
     nprefer_blanking nallow_exposures -- n )
s" XResetScreenSaver" C-word  XResetScreenSaver    ( adpy -- n )


\ Locale functions

s" XSupportsLocale"   C-word  XSupportsLocale  ( -- nflag )
s" XSetLocaleModifiers"  C-word  XSetLocaleModifiers  ( amodifier_list -- astring )

\ Error-handling functions

s" XDisplayName"    C-word  XDisplayName   ( astring -- astring )
s" XGetErrorDatabaseText" C-word  XGetErrorDatabaseText ( adpy \
     aname amessage adefault_string  abuffer_r nlength -- n )  
s" XGetErrorText"   C-word  XGetErrorText  ( adpy ncode abuffer_r \
     nlength -- n )
s" XSetErrorHandler"   C-word  XSetErrorHandler     ( nhandler -- nerrorhandler )
s" XSetIOErrorHandler" C-word  XSetIOErrorHandler   ( nhandler -- nioerrorhandler )

\ Display functions

s" XAllPlanes"       C-word  XAllPlanes        ( -- u )
s" XBitmapBitOrder"  C-word  XBitmapBitOrder   ( adpy -- n )
s" XBitmapPad"       C-word  XBitmapPad        ( adpy -- n )
s" XBitmapUnit"      C-word  XBitmapUnit       ( adpy -- n )
s" XCellsOfScreen"   C-word  XCellsOfScreen    ( ascreen -- n )
s" XCloseDisplay"    C-word  XCloseDisplay     ( adpy -- n )
s" XDisplayCells"    C-word  XDisplayCells     ( adpy nscreen -- n )
s" XDisplayHeight"   C-word  XDisplayHeight    ( adpy nscreen -- n )
s" XDisplayHeightMM" C-word  XDisplayHeightMM  ( adpy nscreen -- n )
s" XDisplayWidth"    C-word  XDisplayWidth     ( adpy nscreen -- n )
s" XDisplayWidthMM"  C-word  XDisplayWidthMM   ( adpy nscreen -- n )
s" XDisplayKeycodes" C-word  XDisplayKeycodes  ( adpy amin_keycodes_r \
     amax_keycodes_r -- n )
s" XDisplayPlanes"   C-word  XDisplayPlanes    ( adpy nscreen -- n )
s" XDefaultVisual"    C-word  XDefaultVisual   ( adpy nscreen -- avisual )
s" XDefaultGC"        C-word  XDefaultGC       ( adpy nscreen -- ngc )
s" XDefaultDepth"     C-word  XDefaultDepth    ( adpy nscreen -- n )
s" XDefaultString"    C-word  XDefaultString   ( -- achar )
s" XBlackPixel"       C-word  XBlackPixel      ( adpy nscreen -- u )
s" XWhitePixel"       C-word  XWhitePixel      ( adpy nscreen -- u )
s" XDefaultColormap"  C-word  XDefaultColormap  ( adpy nscreen -- ncolormap )
s" XDisplayOfScreen"  C-word  XDisplayOfScreen  ( ascreen -- adpy )
s" XGetDefault"    C-word  XGetDefault     ( adpy aprogram aoption -- astring )
s" XPlanesOfScreen"   C-word  XPlanesOfScreen   ( ascreen -- n )
s" XHeightMMOfScreen" C-word  XHeightMMOfScreen ( ascreen -- n )
s" XHeightOfScreen"   C-word  XHeightOfScreen   ( ascreen -- n )
s" XListDepths"       C-word  XListDepths     ( adpy nscreen acount_r -- alist )
s" XOpenDisplay"      C-word  XOpenDisplay    ( aname -- adpy )
s" XProtocolRevision" C-word  XProtocolRevision ( adpy -- n )
s" XProtocolVersion"  C-word  XProtocolVersion  ( adpy -- n )
s" XRootWindow"       C-word  XRootWindow     ( adpy nscreen -- nwindow )
s" XScreenCount"      C-word  XScreenCount      ( adpy -- n )
s" XScreenNumberOfScreen" C-word XScreenNumberOfScreen ( ascreen -- n )
s" XScreenOfDisplay"  C-word  XScreenOfDisplay  ( adpy nscreen -- ascreen ) 
s" XServerVendor"     C-word  XServerVendor     ( adpy -- astring )
s" XVendorRelease"    C-word  XVendorRelease    ( adpy -- n )
s" XWidthMMOfScreen"  C-word  XWidthMMOfScreen  ( ascreen -- n )
s" XWidthOfScreen"    C-word  XWidthOfScreen    ( ascreen -- n )


\ Window functions

s" XChangeWindowAttributes" C-word XChangeWindowAttributes ( adpy nwin \
     uvaluemask  attributes -- n )
s" XConfigureWindow"  C-word  XConfigureWindow  ( adpy nw nvalue_mask  \
     avalues -- n )
s" XCreateSimpleWindow"  C-word  XCreateSimpleWindow   ( adpy nparent \
     nx ny nw nh nbwidth uborder ubg -- nwindow )
s" XCreateWindow"     C-word  XCreateWindow ( adpy nparent nx ny uw uh \
     uborderwidth ndepth uclass avisual uvaluemask attribs -- nwindow )
s" XDestroyWindow"   C-word  XDestroyWindow ( adpy nw -- n )
s" XFetchName"       C-word  XFetchName     ( adpy nw aaname_r -- nstatus )
s" XGeometry"        C-word  XGeometry      ( adpy nscreen apos \
     adefault_pos ubwidth ufwidth ufheight nxadder nyadder \
     ax_r  ay_r  aw_r  ah_r -- n )
s" XGetGeometry"     C-word  XGetGeometry  ( adpy nd awroot_r ax_r ay_r \
     aw_r  ah_r  aborderw_r  adepth_r -- nstatus )
s" XGetWindowAttributes" C-word  XGetWindowAttributes ( adpy nw \
     awindows_attributes_r -- nstatus )
s" XGetWindowProperty" C-word  XGetWindowProperty ( adpy nw nproperty noffset \
           nlength ndelete nreq_type aactual_type_r aactual_format_r \
           anitems_r abytes_after_r aprop_r -- n )
s" XIconifyWindow"   C-word  XIconifyWindow ( adpy nw nscreen -- nstatus )
s" XLowerWindow"     C-word  XLowerWindow   ( adpy nw -- n )
s" XMapRaised"       C-word  XMapRaised     ( adpy nw -- n )
s" XMapWindow"       C-word  XMapWindow     ( adpy nw -- n )
s" XMoveResizeWindow" C-word XMoveResizeWindow ( adpy nwin nx ny uw uh -- n )
s" XMoveWindow"      C-word  XMoveWindow    ( adpy nwin ux uy -- n )
s" XParseGeometry"   C-word  XParseGeometry  ( aparsestring  ax_r  ay_r \
     aw_r  ah_r  -- n )
s" XQueryTree"       C-word  XQueryTree     ( adpy  nw  aroot_r  \
     aparent_r  aachildren_r  anchildren_r  -- nstatus )
s" XRaiseWindow"     C-word  XRaiseWindow   ( adpy nw -- n )
s" XReconfigureWMWindow" C-word  XReconfigureWMWindow  ( adpy nw nscreen \
     nvalmask avalues -- n )
s" XReparentWindow"  C-word  XReparentWindow ( adpy nw nparent nx ny -- n )
s" XResizeWindow"    C-word  XResizeWindow  ( adpy nwin uw uh -- n )
s" XSetWindowBackground" C-word XSetWindowBackground ( adpy nw ubg_pixel -- n )
s" XSetWindowBackgroundPixmap" 
C-word XSetWindowBackgroundPixmap ( adpy nw nbg_pixmap -- n )
s" XSetWindowBorder" C-word  XSetWindowBorder ( adpy nw uborder_pixel -- n )
s" XSetWindowBorderPixmap" C-word XSetWindowBorderPixmap ( adpy nw \
                                          nborder_pixmap -- n )
s" XSetWindowBorderWidth"  C-word  XSetWindowBorderWidth ( adpy nw uwidth -- n )
s" XSetWindowColormap"     C-word  XSetWindowColormap    ( adpy nw ncolormap -- n )
s" XTranslateCoordinates"  C-word  XTranslateCoordinates ( adpy nwsrc nwdst \
     nxsrc nysrc axdst aydst achildwin -- n )
s" XUnmapWindow"     C-word  XUnmapWindow   ( adpy nw -- )
s" XWithdrawWindow"  C-word  XWithdrawWindow ( adpy nw nscreen -- nstatus )


s" XCirculateSubwindows" C-word XCirculateSubwindows    ( adpy nw ndirection -- n )
s" XCirculateSubwindowsDown" C-word XCirculateSubwindowsDown  ( adpy nw -- n )
s" XCirculateSubwindowsUp" C-word   XCirculateSubwindowsUp    ( adpy nw -- n )
s" XMapSubwindows"       C-word  XMapSubwindows         ( adpy nw -- n )
s" XUnmapSubwindows"     C-word  XUnmapSubwindows       ( adpy nw -- n )
s" XDestroySubwindows"   C-word  XDestroySubwindows     ( adpy nw -- n )
s" XRestackWindows"      C-word  XRestackWindows   ( adpy awindows nwindows -- n )
s" XRotateWindowProperties" C-word XRotateWindowProperties ( adpy nw \
     aproperties nprop npositions -- n )

\ Graphics context functions

s" XCreateGC"        C-word  XCreateGC  ( adpy nd nvaluemask avalues -- ngc )
s" XChangeGC"        C-word  XChangeGC  ( adpy ngc uvaluemask avalues -- n )
s" XCopyGC"          C-word  XCopyGC    ( adpy nsrc uvaluemask ndest -- n )
s" XFlushGC"         C-word  XFlushGC   ( adpy ngc -- )
s" XFreeGC"          C-word  XFreeGC    ( adpy ngc -- n )
s" XGContextFromGC"  C-word  XGContextFromGC ( ngc -- ngcontext )
s" XGetGCValues"     C-word  XGetGCValues  ( adpy ngc uvaluemask avalues_r -- nstatus )
s" XSetArcMode"      C-word  XSetArcMode   ( adpy ngc narc_mode -- n )
s" XSetBackground"   C-word  XSetBackground  ( adpy ngc ubackground -- n )
s" XSetClipMask"     C-word  XSetClipMask ( adpy ngc npixmap -- )
s" XSetClipOrigin"   C-word  XSetClipOrigin ( adpy ngc nclip_x_orig nclip_y_orig -- n )
s" XSetClipRectangles" C-word XSetClipRectangles  ( adpy ngc nclip_x_orig \
     nclip_y_orig  arectangles  n1  nordering -- n2 )
s" XSetDashes"       C-word  XSetDashes  ( adpy ngc ndash_offset adash_list n1 -- n2 )
s" XSetFillRule"     C-word  XSetFillRule   ( adpy ngc nfill_rule -- n )
s" XSetFillStyle"    C-word  XSetFillStyle  ( adpy ngc nfill_style -- n )
s" XSetForeground"   C-word  XSetForeground ( adpy ngc ufg -- n )
s" XSetFunction"     C-word  XSetFunction   ( adpy ngc nfunction -- n )
s" XSetGraphicsExposures" C-word XSetGraphicsExposures ( adpy ngc \
     ngraphics_exposures -- n )
s" XSetLineAttributes" C-word  XSetLineAttributes ( adpy ngc uline_width \
     nline_style ncap_style njoin_style -- n )
s" XSetPlaneMask"    C-word  XSetPlaneMask   ( adpy ngc uplane_mask -- n )
s" XSetState"        C-word  XSetState   ( adpy ngc ufg ubg nfunc uplane_mask -- n )
s" XSetStipple"      C-word  XSetStipple ( adpy ngc nstipple -- n )
s" XSetSubwindowMode" C-word XSetSubwindowMode ( adpy ngc nsubwindow_mode -- n )
s" XSetTile"         C-word  XSetTile    ( adpy ngc ntile -- n )
s" XSetTSOrigin"     C-word  XSetTSOrigin  ( adpy ngc nts_x_orig nts_y_orig -- n )


\ Drawing functions

s" XClearArea" C-word  XClearArea    ( adpy nwin nx ny uwidth \
     uheight nexposures -- n )
s" XClearWindow"  C-word  XClearWindow ( adpy nw  -- n )
s" XCopyArea"     C-word  XCopyArea  ( adpy nsrc ndest ngc nx ny uw uh \
     ndx ndy -- n )
s" XCopyPlane"    C-word  XCopyPlane ( adpy nsrc ndest ngc nx ny uw uh \
     ndx ndy uplane -- n )
s" XDrawArc"   C-word  XDrawArc    ( adpy nd ngc nx ny uw uh nangle1 nangle2 -- n )
s" XDrawArcs"  C-word  XDrawArcs   ( adpy nd ngc aarcs narcs -- n )
s" XDrawLine"  C-word  XDrawLine   ( adpy nd ngc nx1 ny1 nx2 ny2 -- n )
s" XDrawLines" C-word  XDrawLines  ( adpy nd ngc apoints npoints nmode -- n )
s" XDrawPoint" C-word  XDrawPoint  ( adpy nd ngc nx ny -- n )
s" XDrawPoints" C-word XDrawPoints ( adpy nd ngc apoints npoint nmode -- n )
s" XDrawRectangle" C-word  XDrawRectangle ( adpy nd ngc nx ny uw uh -- n )
s" XDrawRectangles" C-word XDrawRectangles ( adpy nd ngc arects nrects -- n )
s" XDrawSegments"   C-word XDrawSegments   ( adpy nd ngc asegments nsegments -- n )
s" XDrawString"     C-word XDrawString     ( adpy nd ngc nx ny astring nlength -- n )
s" XDrawString16"   C-word XDrawString16   ( adpy nd ngc nx ny astring nlength -- n )
s" XDrawImageString" C-word XDrawImageString ( adpy nd ngc nx ny astring nlength -- n )
s" XDrawImageString16" C-word  XDrawImageString16 ( adpy nd nx ny astring nlength -- n )
s" XDrawText"   C-word  XDrawText   ( adpy nd ngc nx ny aitems nitems -- n )
s" XDrawText16" C-word  XDrawText16 ( adpy nd ngc nx ny aitems nitems -- n )
s" XFillArc"     C-word  XFillArc   ( adpy nd ngc nx ny uw uh nangle1 nangle2 -- n )
s" XFillArcs"    C-word  XFillArcs  ( adpy nd ngc aarcs narcs -- n )
s" XFillRectangle"  C-word  XFillRectangle  ( adpy nd ngc nx ny uw uh -- n )
s" XFillRectangles" C-word  XFillRectangles ( adpy nd ngc arects nrects -- n )
s" XFillPolygon"    C-word  XFillPolygon    ( adpy nd ngc apoints \
     npoints nshape nmode -- n )



\ Pixmap and Tile functions

s" XCreateBitmapFromData"  C-word  XCreateBitmapFromData  ( adpy nd adata \
     nwidth nheight -- npixmap )
s" XCreatePixmap" C-word  XCreatePixmap   ( adpy nd nw nh ndepth -- npixmap )
s" XCreatePixmapCursor" C-word XCreatePixmapCursor  ( adpy nsource nmask \
     afgcol abgcol nx ny -- ncursor )
s" XCreatePixmapFromBitmapData"  
C-word  XCreatePixmapFromBitmapData   ( adpy nd adata uwidth uheight \
     ufg ubg udepth -- npixmap )
s" XFreePixmap"   C-word  XFreePixmap ( adpy npixmap -- n )
s" XListPixmapFormats" C-word  XListPixmapFormats   ( adpy acount_r \
     -- apixmapformatvalues )
s" XReadBitmapFile" C-word  XReadBitmapFile ( adpy  nd  afilename  awidth_r \
     aheight_r  abitmap_r  ax_hot_r  ay_hot_r  --  n )
s" XReadBitmapFileData" C-word XReadBitmapFileData ( afilename  awidth_r \
     aheight_r  abitmap_r  ax_hot_r  ay_hot_r  -- n )
s" XQueryBestSize"     C-word  XQueryBestSize     ( adpy  nclass  nwhich_screen \
     nwidth  nheight  awidth_r  aheight_r  --  nstatus )
s" XQueryBestStipple"  C-word  XQueryBestStipple  ( adpy  nwhich_screen  nwidth \
     nheight  awidth_r  aheight_r  --  nstatus )
s" XQueryBestTile"     C-word  XQueryBestTile     ( adpy  nwhich_screen  nwidth \
     nheight  awidth_r  aheight_r  --  nstatus )
s" XWriteBitmapFile"   C-word  XWriteBitmapFile   ( adpy afilename nbitmap \
     nwidth nheight nx_hot ny_hot -- n )



\ Image functions

s" XAddPixel"     C-word  XAddPixel     ( aximage nvalue -- n )
s" XCreateImage"  C-word  XCreateImage  ( adpy avisual ndepth nformat noffset \
     adata nw nh nbmpad nb/line -- aimage )
s" XDestroyImage" C-word  XDestroyImage ( aximage -- n )
s" XGetImage"     C-word  XGetImage     ( adpy nd nx ny uw uh uplanemask \
     nformat -- aimage )
s" XGetPixel"     C-word  XGetPixel     ( aximage nx ny -- u )
s" XGetSubImage"  C-word  XGetSubImage  ( adpy nd nx ny uw uh uplanemask \
     nformat axdimage ndx ndy -- aximage )
s" XInitImage"    C-word  XInitImage    ( aimage -- nstatus )
s" XImageByteOrder" C-word  XImageByteOrder ( adpy -- n )
s" XPutImage"     C-word  XPutImage     ( adpy nd ngc aimage \
     ns_x ns_y nd_x nd_y uw uh -- n )
s" XPutPixel"     C-word  XPutPixel     ( aximage nx ny upixel -- n )
s" XSubImage"     C-word  XSubImage     ( aximage nx ny uw uh -- aximage )


\ Region functions

s" XClipBox"        C-word  XClipBox        ( nreg arect_r -- n )
s" XCreateRegion"   C-word  XCreateRegion   ( -- nreg )
s" XDestroyRegion"  C-word  XDestroyRegion  ( nreg -- n )
s" XEmptyRegion"    C-word  XEmptyRegion    ( nreg -- n )
s" XEqualRegion"    C-word  XEqualRegion    ( nreg1 nreg2 -- n )
s" XOffsetRegion"   C-word  XOffsetRegion   ( nreg ndx ndy -- n )
s" XPointInRegion"  C-word  XPointInRegion  ( nreg nx ny -- nflag )
s" XPolygonRegion"  C-word  XPolygonRegion  ( apoints n nfill_rule -- nreg )
s" XRectInRegion"   C-word  XRectInRegion   ( nreg nx ny uw uh -- n )
s" XSetRegion"      C-word  XSetRegion      ( adpy ngc nreg -- n )
s" XSubtractRegion" C-word  XSubtractRegion ( nsra nsrb ndr_r -- n )
s" XUnionRegion"    C-word  XUnionRegion    ( nsra nsrb ndr_r -- n )
s" XShrinkRegion"   C-word  XShrinkRegion   ( nreg ndx ndy -- n )
s" XXorRegion"      C-word  XXorRegion      ( nsra nsrb ndr_r -- n )
s" XIntersectRegion" C-word XIntersectRegion  ( nsra nsrb ndr_r -- n )
s" XUnionRectWithRegion" C-word XUnionRectWithRegion ( arect nsrc_reg ndest_reg_r -- n )


\ Device-independent Color functions

s" XcmsAddColorSpace"  C-word  XcmsAddColorSpace ( acolor_space -- nstatus )
s" XcmsAddFunctionSet" C-word  XcmsAddFunctionSet ( afunction_set -- nstatus )
s" XcmsAllocColor"     C-word  XcmsAllocColor  ( adpy ncolormap acolor_in_out \
     nresult_format -- nstatus )
s" XcmsAllocNamedColor" C-word XcmsAllocNamedColor ( adpy ncolormap \
     acolor_string acolor_screen_r acolor_exact_r nresult_format -- nstatus )


\ Colormap functions

s" XAllocColor"       C-word  XAllocColor   ( adpy ncolormap acolor -- nstatus )
s" XAllocColorCells"  C-word  XAllocColorCells  ( adpy ncolormap ncontig \
     aplanemasks_r nplanes apixels_r npixels -- nstatus ) 
s" XAllocColorPlanes" C-word  XAllocColorPlanes ( adpy ncolormap ncontig \
     apixels_r npixels nreds ngreens nblues armask_r agmask_r abmask_r -- nstatus )
s" XAllocNamedColor"  C-word  XAllocNamedColor  ( adpy ncolormap acolor_name \
     ascreendef_r aexactdef_r -- nstatus )
s" XCopyColormapAndFree" C-word  XCopyColormapAndFree ( adpy ncolormap1 -- ncolormap2 )
s" XCreateColormap"      C-word  XCreateColormap ( adpy nw avisual \
     nalloc -- ncolormap )
s" XFreeColormap"    C-word  XFreeColormap ( adpy ncolormap -- n )
s" XFreeColors"      C-word  XFreeColors  ( adpy ncolormap apixels \
     npixels nplanes -- n )
s" XGetStandardColormap" C-word  XGetStandardColormap  ( adpy nw acolormap_r \
     nproperty -- nstatus )
s" XInstallColormap" C-word  XInstallColormap  ( adpy ncolormap -- n )
s" XListInstalledColormaps"  C-word  XListInstalledColormaps ( adpy nw \
     anum_r -- alist )
s" XLookupColor"     C-word  XLookupColor ( adpy ncolormap acolor_name \
     aexact_def_r ascreen_def_r -- nstatus )
s" XParseColor"      C-word  XParseColor  ( adpy ncolormap aspec \
     aexact_def_r -- nstatus )
s" XQueryColor"      C-word  XQueryColor  ( adpy  ncolormap  adef_in_out  -- n )
s" XQueryColors"     C-word  XQueryColors ( adpy  ncolormap  adefs_in_out \
     ncolors -- n )
s" XSetRGBColormaps" C-word  XSetRGBColormaps  ( adpy nw astd_colormap \
     ncount nproperty --  )
s" XSetStandardColormap" C-word  XSetStandardColormap  ( adpy nw acolormap \
     nproperty -- )
s" XStoreColor"          C-word  XStoreColor    ( adpy ncolormap acolorcell_def -- n )
s" XStoreColors"         C-word  XStoreColors   ( adpy ncolormap acolorarr \
     ncolors -- n )
s" XStoreNamedColor"     C-word  XStoreNamedColor  ( adpy ncolormap acolor_name \
     upixel nflags -- n )
s" XUninstallColormap"   C-word  XUninstallColormap  ( adpy ncolormap -- n )


\ Font functions

s" XFreeFont"         C-word  XFreeFont       ( adpy afont_struct -- n )
s" XFreeFontInfo"     C-word  XFreeFontInfo   ( aanames afree_info nactual_count -- n )
s" XFreeFontNames"    C-word  XFreeFontNames  ( aalist -- n )
s" XFreeFontPath"     C-word  XFreeFontPath   ( aalist -- n )
s" XGetFontPath"      C-word  XGetFontPath    ( adpy anpaths_r -- aastring )
s" XGetFontProperty"  C-word  XGetFontProperty ( afontstruct natom avalue_r -- nflag )
s" XListFonts"        C-word  XListFonts      ( adpy apattern nmaxnames \
     actual_count_r -- aalist )
s" XListFontsWithInfo" C-word XListFontsWithInfo ( adpy apattern nmaxnames \
     acount_r aainfo_r -- aalist )
s" XLoadFont"         C-word  XLoadFont       ( adpy aname -- nfont )
s" XLoadQueryFont"    C-word  XLoadQueryFont  ( adpy aname -- afontstruct )
s" XQueryFont"        C-word  XQueryFont      ( adpy nfont_id -- afontstruct )
s" XSetFont"          C-word  XSetFont        ( adpy ngc nfont -- n )
s" XSetFontPath"      C-word  XSetFontPath    ( adpy aadirectories ndirs -- n )
s" XUnloadFont"       C-word  XUnloadFont     ( adpy nfont -- n )
s" XTextWidth"        C-word  XTextWidth      ( afont_struct astring ncount -- n )
s" XTextWidth16"      C-word  XTextWidth16    ( afont_struct astring ncount -- n )


\ Text functions

s" XBaseFontNameListOfFontSet" 
  C-word XBaseFontNameListOfFontSet ( nfontset -- astring )
s" XContextDependentDrawing"   
  C-word XContextDependentDrawing  ( nfontset -- nflag )
s" XCreateFontSet"    C-word  XCreateFontSet ( adpy abase_font_name_list \
     aamissing_charset_list amissing-charset_count aadef_string -- nfontset )
s" XExtentsOfFontSet" C-word  XExtentsOfFontSet  ( nfontset -- afontsetextents )
s" XFontsOfFontSet"   C-word  XFontsOfFontSet ( nfont_set \
     aafont_struct_list_r  aafont_name_list_r -- n )
s" XFreeFontSet"      C-word  XFreeFontSet    ( adpy nfontset -- n )
s" XLocaleOfFontSet"  C-word  XLocaleOfFontSet  ( nfontset -- astring )
s" XQueryTextExtents" C-word  XQueryTextExtents ( adpy  nfont_id  astring \
     nchars  adirection_r  afont_ascent_r  afont_descent_r  aoverall_r  -- n )
s" XQueryTextExtents16" C-word XQueryTextExtents16  ( adpy  nfont_id  astring \
     nchars  adirection_r  afont_ascent_r  afont_descent_r  aoverall_r  -- n )
s" XSetTextProperty"  C-word  XSetTextProperty  ( adpy nw atext_prop nprop --  )

\ s" XDirectionalDependentDrawing" C-word XDirectionalDependentDrawing ( fontset -- flag )
s" XStringToKeysym"   C-word  XStringToKeysym      ( astring -- nkeysym )
s" XTextExtents"      C-word  XTextExtents ( afontstruct  astring  nchars \
     adirection_r  afont_ascent_r  afont_descent_r  aoverall_r -- n )
s" XTextExtents16"    C-word  XTextExtents16 ( afont_struct astring nchars \
     adirection_r  afont_ascent_r afont_descent_r aoverall_r -- n )

\ Grabbing functions

s" XGrabButton"   C-word  XGrabButton  ( adpy nbutton nmodifiers ngrab_win \
     nowner_events uevent_mask npointer_mode nkeyboard_mode nconfine_to ncursor -- n )
s" XGrabKey"      C-word  XGrabKey     ( adpy nkeycode umodifiers ngrab_win \
     nowner_events npointer_mode nkeyboard_mode -- n )
s" XGrabKeyboard" C-word  XGrabKeyboard ( adpy nw nowner_events npointer_mode \
     nkeyboard_mode utime -- n )
s" XGrabPointer"  C-word  XGrabPointer  ( adpy ngrab_win nowner_events \
     uevent_mask npointer_mode nkeyboard_mode nconfine_to ncursor utime -- n )
s" XGrabServer"     C-word  XGrabServer    ( adpy -- n )
s" XUngrabButton"   C-word  XUngrabButton  ( adpy ubutton umodifiers ngrab_window -- n )
s" XUngrabKey"      C-word  XUngrabKey   ( adpy nkeycode umodifiers ngrab_window -- n )
s" XUngrabKeyboard" C-word  XUngrabKeyboard ( adpy utime -- n )
s" XUngrabPointer"  C-word  XUngrabPointer  ( adpy ntime -- n )
s" XUngrabServer"   C-word  XUngrabServer   ( adpy -- n )


\ Input Context functions

s" XCreateIC"     C-word  XCreateIC       ( nim -- nXIC )
s" XDestroyIC"    C-word  XDestroyIC      ( nic -- n )
\ libX11 XCreateIC_1 [ 4 ] ints (ptr) XCreateIC       ( im -- XIC )
\ libX11 XCreateIC_2 [ 6 ] ints (ptr) XCreateIC       ( im -- XIC )
\ libX11 XCreateIC_3 [ 8 ] ints (ptr) XCreateIC       ( im -- XIC )
\ libX11 XCreateIC_4 [ &10 ] ints (ptr) XCreateIC       ( im -- XIC )
\ libX11 XCreateIC_5 [ &12 ] ints (ptr) XCreateIC       ( im -- XIC )
s" XSetICFocus"   C-word  XSetICFocus     ( nic -- )
s" XUnsetICFocus" C-word  XUnsetICFocus   ( nic -- )

\ Input Method functions

s" XCloseIM"      C-word  XCloseIM        ( nim -- nstatus )
s" XDisplayOfIM"  C-word  XDisplayOfIM    ( nim -- adpy )
s" XIMOfIC"       C-word  XIMOfIC         ( nic -- nim )
s" XLocaleOfIM"   C-word  XLocaleOfIM     ( nim -- astring )
s" XOpenIM"       C-word  XOpenIM  ( adpy ardb ares_name ares_class -- nim )
\ libX11 XGetIMValues_1 [ 4 ] ints (ptr) XGetIMValues    ( im ... -- string )
\ libX11 XGetIMValues_2 [ 6 ] ints (ptr) XGetIMValues    ( im ... -- string )
\ libX11 XGetIMValues_3 [ 8 ] ints (ptr) XGetIMValues  ( im ... -- string )
\ libX11 XSetIMValues_1 [ 4 ] ints (ptr) XSetIMValues    ( im ... -- string )
\ libX11 XSetIMValues_2 [ 6 ] ints (ptr) XSetIMValues    ( im ... -- string )
\ libX11 XSetIMValues_3 [ 8 ] ints (ptr) XSetIMValues    ( im ... -- string )

\ Output Method functions

s" XOpenOM"         C-word  XOpenOM   ( adpy ardb ares_name ares_class -- nxom )
s" XCloseOM"        C-word  XCloseOM  ( nom -- nstatus )
\ s" XSetOMValues"         C-word  XSetOMValues         ( ...om -- astring )
\ s" XGetOMValues"         C-word  XGetOMValues         ( ...om -- astring )
\ s" XDisplayOfOM"         C-word  XDisplayOfOM         ( om -- dpy )
\ s" XLocaleOfOM"          C-word  XLocaleOfOM          ( om -- string )
\ s" XCreateOC"            C-word  XCreateOC            ( ...om -- XOC )
\ s" XDestroyOC"           C-word  XDestroyOC           ( oc -- r )
\ s" XOMOfOC"              C-word  XOMOfOC              ( oc -- XOM )
\ s" XSetOCValues"         C-word  XSetOCValues         ( ...oc -- string )
\ s" XGetOCValues"         C-word  XGetOCValues         ( ...oc -- string )


\ Input Handling functions

s" XAllowEvents"   C-word  XAllowEvents    ( adpy nevent_mode ntime -- n )
s" XFilterEvent"   C-word  XFilterEvent    ( axevent nw -- nflag )
s" XGetInputFocus" C-word  XGetInputFocus  ( adpy afocus_ret arevert -- n )
s" XSetInputFocus" C-word  XSetInputFocus  ( adpy nfocus nrevert_to ntime -- n )
s" XSelectInput"   C-word  XSelectInput    ( adpy nw nevent_mask -- n )


\ Pointer functions

s" XChangeActivePointerGrab" C-word  XChangeActivePointerGrab  ( adpy \
     nevent_mask ncursor utime -- n )
s" XChangePointerControl"  C-word  XChangePointerControl ( adpy \
     ndo_accel ndo_threshold naccel_numerator naccel_denom nthreshold -- n )
s" XGetPointerControl"   C-word  XGetPointerControl   ( adpy \
     aaccel_num_r  aaccel_denom_r athreshold_r -- n )
s" XGetPointerMapping"   C-word  XGetPointerMapping   ( adpy amap_r nmap -- n )
s" XQueryPointer"        C-word  XQueryPointer  ( adpy nw aroot_r achild_r \
     aroot_x_r aroot_y_r awin_x_r awin_y_r amask_r -- nflag )
s" XSetPointerMapping"   C-word  XSetPointerMapping   ( adpy amap nmap -- n )
s" XWarpPointer"         C-word  XWarpPointer   ( adpy  nsrc_w  ndest_w  \
     nsrc_x  nsrc_y  usrc_w  usrc_h  ndest_x  ndest_y -- n )


\ Keyboard

s" XChangeKeyboardMapping" C-word XChangeKeyboardMapping  ( adpy \
     nfirst_keycode nkeysyms_per_keycode akeysyms nkeycodes -- n )
s" XFreeModifiermap"     C-word  XFreeModifiermap     ( amodmap -- n )
s" XGetKeyboardControl"  C-word  XGetKeyboardControl  ( adpy avalues_r -- n )
s" XGetKeyboardMapping" C-word  XGetKeyboardMapping  ( adpy nkeycode \
     nkeycode_c akeysyms_r -- akeysym )
s" XGetModifierMapping"  C-word  XGetModifierMapping  ( adpy -- amodmap )
s" XKeycodeToKeysym"  C-word  XKeycodeToKeysym  ( adpy nkeycode nindex \
     -- nkeysym )
s" XKeysymToKeycode"  C-word  XKeysymToKeycode ( adpy nkeysym -- nkeycode )
s" XKeysymToString"   C-word  XKeysymToString  ( nkeysym -- astring )
s" XLookupKeysym"     C-word  XLookupKeysym   ( akey_event nindex -- nkeysym )
s" XLookupString"     C-word  XLookupString ( aevent_struct  abuffer_r \
     nbytes_buffer  akeysym_r  astatus_in_out -- n )
s" XConvertCase"      C-word  XConvertCase    ( nkeysym alower aupper -- )
s" XNewModifiermap"   C-word  XNewModifiermap ( nmaxkeys -- amodmap )
s" XQueryKeymap"      C-word  XQueryKeymap    ( adpy akeys_r -- n )
s" XRebindKeysym"     C-word  XRebindKeysym   ( adpy nkeysym amod_list \
     nmod_count astring nbytes -- n )
s" XRefreshKeyboardMapping" C-word XRefreshKeyboardMapping ( aevent_map -- n )
s" XSetModifierMapping"  C-word  XSetModifierMapping  ( adpy amodmap -- n )


\ Cursor functions

s" XCreateFontCursor"  C-word  XCreateFontCursor  ( adpy nshape -- ncursor )
s" XCreateGlyphCursor" C-word  XCreateGlyphCursor ( adpy nsource_font \
     nmask_font nsource_char nmask_char afgcol abgcol -- ncursor )
s" XDefineCursor"      C-word  XDefineCursor  ( adpy nwin ncursor -- n )
s" XFreeCursor"        C-word  XFreeCursor    ( adpy ncursor -- n )
s" XRecolorCursor"     C-word  XRecolorCursor ( adpy ncursor afg abg -- n )
s" XQueryBestCursor"   C-word  XQueryBestCursor ( adpy  nd  uwidth  \
     uheight  awidth_r  aheight_r  -- nstatus )
s" XUndefineCursor"    C-word  XUndefineCursor ( adpy nw -- n )


\ Icon functions

s" XGetIconName"    C-word  XGetIconName   ( adpy nw aaicon_name_r -- n )
s" XGetIconSizes"   C-word  XGetIconSizes  ( adpy nw aasize_list_r acount_r -- n )
s" XSetIconName"    C-word  XSetIconName   ( adpy nw aicon_name -- n )
s" XSetIconSizes"   C-word  XSetIconSizes  ( adpy nw asize_list ncount -- n )

\ Event functions

s" XDisplayMotionBufferSize" C-word XDisplayMotionBufferSize ( adpy -- u )
s" XNextEvent"      C-word  XNextEvent  ( adpy aevent_r -- n )
s" XMaskEvent"   C-word  XMaskEvent     ( adpy nevent_mask aevent_r -- n )
s" XCheckMaskEvent" C-word  XCheckMaskEvent ( adpy nevent_mask aevent_r -- nflag )
s" XWindowEvent"  C-word XWindowEvent   ( adpy nw nevent_mask aevent_r -- n )
s" XCheckWindowEvent" C-word XCheckWindowEvent ( adpy nw nevent_mask aevent_r -- nflag )
s" XPeekEvent"   C-word  XPeekEvent     ( adpy aevent_r -- n )
s" XCheckTypedEvent" C-word XCheckTypedEvent ( adpy nevent_type aevent_r -- nflag )
s" XCheckTypedWindowEvent" C-word XCheckTypedWindowEvent ( adpy nw nevent_type \
                                                    aevent_r  -- nflag )
s" XEventsQueued"   C-word  XEventsQueued  ( adpy nmode -- n )
s" XPending"        C-word  XPending       ( adpy -- n )
s" XPutBackEvent"   C-word  XPutBackEvent  ( adpy aevent -- n )
s" XGetMotionEvents" C-word XGetMotionEvents  ( adpy nw nstart nstop \
                                              anevents_r -- atimecoord )
s" XQLength"      C-word  XQLength      ( adpy -- n )
s" XSendEvent"    C-word XSendEvent     ( adpy nw npropagate \
                             nevent_mask aevent_send -- nstatus )
s" XIfEvent"      C-word  XIfEvent      ( adpy aevent_r apredicate aarg -- nflag )
s" XCheckIfEvent" C-word  XCheckIfEvent ( adpy aevent_r apredicate aarg -- nflag )
s" XPeekIfEvent"  C-word  XPeekIfEvent  ( adpy aevent_r apredicate aarg -- n )


\ Selection functions

s" XConvertSelection"  C-word  XConvertSelection  ( adpy nselection ntarget \
     nproperty nrequestor utime -- n )
s" XGetSelectionOwner" C-word  XGetSelectionOwner ( adpy natom -- nwindow )
s" XSetSelectionOwner" C-word  XSetSelectionOwner ( adpy nselection nowner utime -- n )


\ Cut-Buffer functions

s" XFetchBuffer"  C-word  XFetchBuffer  ( adpy anbytes_r nbuffer -- axfbuffer )
s" XFetchBytes"   C-word  XFetchBytes   ( adpy anbytesr -- abuffer )
s" XRotateBuffers" C-word XRotateBuffers  ( adpy nrotate -- n )
s" XStoreBuffer"  C-word  XStoreBuffer  ( adpy abytes nbytes nbuffer -- n )
s" XStoreBytes"   C-word  XStoreBytes   ( adpy abytes nbytes -- n )


\ Property functions

s" XChangeProperty"  C-word  XChangeProperty    ( adpy nw nproperty ntype \
     nformat nmode adata nelements -- n )
s" XDeleteProperty"  C-word XDeleteProperty ( adpy nw natom -- n )
s" XGetAtomName"     C-word  XGetAtomName   ( adpy natom -- aname )
\ s" XGetAtomNames" C-word  XGetAtomNames   ( namesr count atoms dpy -- status )
s" XInternAtom"     C-word  XInternAtom    ( adpy aproperty_name \
     nonly_if_exists -- n )
s" XListProperties" C-word  XListProperties ( adpy nw anum_prop_r -- aatom )


\ Save Set functions

s" XAddToSaveSet"   C-word  XAddToSaveSet   ( adpy nw -- n )
s" XChangeSaveSet"  C-word  XChangeSaveSet  ( adpy nw nchange_mode -- n )
s" XRemoveFromSaveSet" C-word  XRemoveFromSaveSet ( adpy nw -- n )


\ User Preferences functions

s" XAutoRepeatOff"       C-word  XAutoRepeatOff       ( adpy -- n )
s" XAutoRepeatOn"        C-word  XAutoRepeatOn        ( adpy -- n )
s" XBell"                C-word  XBell   ( adpy npercent -- n )
s" XChangeKeyboardControl" C-word XChangeKeyboardControl  ( adpy \
  uvalue_mask avalues -- n )


\ Window Manager Hints functions

s" XAllocClassHint"   C-word  XAllocClassHint      ( -- axclasshint )
s" XAllocIconSize"    C-word  XAllocIconSize       ( -- axiconsize )
s" XAllocSizeHints"   C-word  XAllocSizeHints      ( -- axsizehints )
s" XAllocStandardColormap" C-word XAllocStandardColormap  ( -- axstdcmap )
s" XAllocWMHints"     C-word  XAllocWMHints        ( -- axwmhints )
s" XGetClassHint"     C-word  XGetClassHint  ( adpy nw \
     aclass_hints_r -- nstatus )
s" XGetCommand"       C-word  XGetCommand    ( adpy nw \
     aargv_r argc_r -- nstatus )
s" XGetNormalHints"   C-word  XGetNormalHints ( adpy nw ahints_r -- nstatus )
s" XGetRGBColormaps"  C-word  XGetRGBColormaps ( adpy nw \
     aastdcmap_r acount_r nprop   -- nstatus )
s" XGetSizeHints"     C-word  XGetSizeHints   ( adpy nw ahints_r nprop -- nstatus )
s" XGetZoomHints"     C-word  XGetZoomHints   ( adpy nw azhints_r -- \
     nstatus )
s" XGetTextProperty"  C-word  XGetTextProperty ( adpy nw \
     atext_prop_r nprop -- nstatus )
s" XGetTransientForHint" C-word  XGetTransientForHint ( adpy nw \
     aprop_w_r -- nstatus )
s" XGetVisualInfo"       C-word  XGetVisualInfo  ( adpy nvinfo_mask \
     avinfo_templ anitems_r -- axvinfo )
s" XGetWMClientMachine"  C-word  XGetWMClientMachine ( adpy nw \
     atext_prop_r -- nstatus )
s" XGetWMColormapWindows" C-word XGetWMColormapWindows ( adpy nw \
     awindows_r ncount_r -- nstatus )
s" XGetWMHints"       C-word  XGetWMHints  ( adpy nw -- aWMHints )
s" XGetWMIconName"    C-word  XGetWMIconName ( adpy nw atext_prop_r -- nstatus )
s" XGetWMName"        C-word  XGetWMName   ( adpy nw atext_prop_r -- nstatus )
s" XGetWMNormalHints" C-word  XGetWMNormalHints  ( adpy nw \
     ahints_r asupplied_r -- nstatus )
s" XGetWMProtocols"   C-word  XGetWMProtocols ( adpy nw \
     aaprotocols_r acount_r -- nstatus )
s" XGetWMSizeHints"   C-word  XGetWMSizeHints ( adpy nw \
     ahints_r asupplied_r nprop -- nstatus )
s" XWMGeometry"       C-word  XWMGeometry  ( adpy nscreen auser_geom \
     adef_geom nborder_w ahints ax_r ay_r aw_r ah_r agravity_r -- n )

s" XSetCommand"       C-word  XSetCommand     ( adpy nw aargv nargc -- n )
s" XSetClassHint"     C-word  XSetClassHint   ( adpy nw aclass_hints -- n )
s" XSetNormalHints"   C-word  XSetNormalHints ( adpy nw ahints -- n )
s" XSetZoomHints"     C-word  XSetZoomHints   ( adpy nw azhints -- n )
s" XSetSizeHints"     C-word  XSetSizeHints   ( adpy nw ahints nprop -- n )
s" XSetTransientForHint"  C-word  XSetTransientForHint  ( adpy nw npropw -- n )
s" XSetWMHints"       C-word  XSetWMHints     ( adpy nw awm_hints -- n )
s" XSetWMNormalHints" C-word  XSetWMNormalHints  ( adpy nw ahints -- )
s" XSetWMSizeHints"   C-word  XSetWMSizeHints ( adpy nw ahints nprop -- )
s" XSetWMProtocols" C-word  XSetWMProtocols ( adpy nw aprotocols ncount -- n )
s" XSetWMColormapWindows" C-word XSetWMColormapWindows ( adpy nw \
     acolormap_windows ncount -- n )
s" XSetWMClientMachine" C-word XSetWMClientMachine  ( adpy nw atext_prop -- )
s" XSetWMIconName"    C-word  XSetWMIconName  ( adpy nw atext_prop -- )
s" XSetWMName"        C-word  XSetWMName      ( adpy nwin atext_prop -- )
s" XSetWMProperties"  C-word  XSetWMProperties ( adpy nw awindow_name \
     aicon_name aargv nargc anormal_hints awm_hints aclass_hints -- )
s" XStoreName"   C-word  XStoreName      ( adpy nwin awindow_name -- n )
s" XSetStandardProperties" C-word  XSetStandardProperties  ( adpy nw \
     awindow_name aicon_name nicon_pixmap aargv nargc asizehints -- n ) 

\ Xutil Functions
\ The following functions are not performed by the XServer, but in Xlib.

s" XMatchVisualInfo" C-word  XMatchVisualInfo ( adpy nscreen ndepth nclass \
     avinfo_r -- n )

s" XDeleteContext"  C-word  XDeleteContext  ( adpy nrid ncontext -- n )
s" XFindContext"    C-word  XFindContext    ( adpy nrid ncontext adata_r -- n )
s" XSaveContext"    C-word  XSaveContext    ( adpy nrid ncontext adata -- n )


\ Resource Manager functions

s" XDeleteModifiermapEntry" C-word  XDeleteModifiermapEntry ( amodmap \
     nkeycode nmodifier -- amodmap )
s" XInsertModifiermapEntry" C-word  XInsertModifiermapEntry ( amodmap \
     nkeycode nmodifier -- amodmap )

s" XStringListToTextProperty" C-word  XStringListToTextProperty ( alist \
     ncount atext_prop_r -- n )

s" XrmInitialize"        C-word  XrmInitialize        ( -- )
s" XrmGetDatabase"       C-word  XrmGetDatabase       ( adpy -- ndbase )
s" XrmGetStringDatabase" C-word  XrmGetStringDatabase ( adata -- ndbase )
s" XrmGetFileDatabase"   C-word  XrmGetFileDatabase   ( afilename -- ndbase )
s" XrmLocaleOfDatabase"  C-word  XrmLocaleOfDatabase  ( ndbase -- astring )
s" XrmDestroyDatabase"   C-word  XrmDestroyDatabase   ( ndbase -- )
s" XrmParseCommand"      C-word  XrmParseCommand ( adbase ntable ntable_count \
     aname argc_io aargv_io -- )
s" XrmPutLineResource"   C-word  XrmPutLineResource  ( adbase aline -- )
s" XrmPutResource"       C-word  XrmPutResource  ( adbase aspec avalue -- )
s" XrmPutStringResource" C-word XrmPutStringResource  ( adbase aspec avalue -- )
s" XrmGetResource"       C-word  XrmGetResource  ( ndbase astr_n astr_c \
     aastr_t_r  avalue_r -- nflag )
s" XrmSetDatabase"       C-word  XrmSetDatabase      ( adpy ndbase --  )
s" XrmPutFileDatabase"   C-word  XrmPutFileDatabase  ( ndbase astored_db -- )
s" XrmCombineDatabase"   C-word  XrmCombineDatabase  ( ndbase_src adbase_dst \
     nflag -- )
s" XrmMergeDatabases"    C-word  XrmMergeDatabases   ( ndbase_src adbase_dst -- )
s" XrmCombineFileDatabase" C-word XrmCombineFileDatabase  ( afilename adbase_dst \
     nflag -- n ) 
\ libX11 XrmEnumerateDatabase [ 6 ] ints (int) XrmEnumerateDatabase    ( closure callback mode class_prefix name_prefix db -- flag )

\ libX11 XrmStringToQuarkList [ 2 ] ints (int) XrmStringToQuarkList    ( quarks string -- r )
\ libX11 XrmStringToBindingQuarkList [ 3 ] ints (int) XrmStringToBindingQuarkList     ( quarks bindings string -- r )
(
struct{
    cell size
    cell addr
} XrmValue
)
\ s" XrmStringToQuark"     C-word  XrmStringToQuark     ( string -- quark )
\ s" XrmPermStringToQuark" C-word  XrmPermStringToQuark ( string -- quark )
\ s" XrmQuarkToString"     C-word  XrmQuarkToString     ( quark -- string )
\ s" XInitThreads"         C-word  XInitThreads         ( -- status )
\ s" XrmUniqueQuark"       C-word  XrmUniqueQuark       ( -- quark )

\ libX11 XrmQPutResource [ 5 ] ints (int) XrmQPutResource ( value type quarks bindings dbase -- r )
\ libX11 XrmQPutStringResource [ 4 ] ints (int) XrmQPutStringResource   ( value quarks bindings dbase -- r )

\ libX11 XrmQGetResource [ 5 ] ints (int) XrmQGetResource ( value_r quark_t_r quark_c quark_n dbase -- r )
\ libX11 XrmQGetSearchList [ 5 ] ints (int) XrmQGetSearchList       ( list_len list_r classes names dbase -- flag )
\ libX11 XrmQGetSearchResource [ 5 ] ints (int) XrmQGetSearchResource   ( value_r type_r class name list -- flag )

\ libX11 XSetICValues_1 [ 4 ] ints (int) XSetICValues    ( ic ... -- string )
\ libX11 XSetICValues_2 [ 6 ] ints (int) XSetICValues    ( ic ... -- string )
\ libX11 XSetICValues_3 [ 8 ] ints (int) XSetICValues    ( ic ... -- string )

\ libX11 XVaCreateNestedList_1 [ 4 ] ints (ptr) XVaCreateNestedList     ( ...unused -- \ vanestedlist )
\ libX11 XVaCreateNestedList_2 [ 6 ] ints (ptr) XVaCreateNestedList     ( ...unused -- vanestedlist )
\ libX11 XVaCreateNestedList_3 [ 8 ] ints (ptr) XVaCreateNestedList     ( ...unused -- vanestedlist )
\ libX11 XVaCreateNestedList_4 [ &10 ] ints (ptr) XVaCreateNestedList     ( ...unused -- vanestedlist )

0 ( has-utf8) [IF]
\ libX11 Xutf8DrawImageString [ 8 ] ints (int) Xutf8DrawImageString        ( dpy d fontset gc x y string length -- r )
\ libX11 Xutf8DrawString [ 8 ] ints (int) Xutf8DrawString     ( dpy d fontset gc x y string length -- r )
\ libX11 Xutf8LookupString [ 6 ] ints (int) Xutf8LookupString ( ic event buffer_r wchars_buffer keysym_r status_r -- n )
\ libX11 Xutf8TextExtents [ 7 ] ints (void) Xutf8TextExtents    ( font_struct string nchars direction_r font_ascent_r font_descent_r overall_r -- )
\ libX11 Xutf8DrawText [ 7 ] ints (void) Xutf8DrawText       ( dpy d gc x y items nitems -- )
\ libX11 Xutf8TextEscapement [ 3 ] ints (int) Xutf8TextEscapement       ( num_wchars text fontset -- n )
\ libX11 Xutf8TextPerCharExtents [ 9 ] ints (int) Xutf8TextPerCharExtents   ( overal_logical_r overall_ink_r num_chars buffer_size logical_extents_buffer ink_extents_buffer num_wchars text fontset -- status )
\ libX11 Xutf8ResetIC int (int) Xutf8ResetIC      ( ic -- string )
[THEN]


\ s" XmbTextEscapement" C-word  XmbTextEscapement  ( bytes_text text fontset -- n )
\ s" XwcTextEscapement" C-word  XwcTextEscapement  ( num_wchars text fontset -- n )
\ s" XmbTextExtents"    C-word  XmbTextExtents  ( overall_logical_r overall_ink_r bytes_text text fontset -- n )
\ s" XwcTextExtents"    C-word  XwcTextExtents  ( overall_logical_r overall_ink_r num_wchars text fontset -- n )

\ libX11 XmbTextPerCharExtents [ 9 ] ints (int) XmbTextPerCharExtents   ( overal_logical_r overall_ink_r num_chars buffer_size logical_extents_buffer  ink_extents_buffer bytes_text text fontset -- status )
\ libX11 XwcTextPerCharExtents [ 9 ] ints (int) XwcTextPerCharExtents   ( overal_logical_r overall_ink_r num_chars buffer_size logical_extents_buffer ink_extents_buffer num_wchars text fontset -- status )
\ libX11 XmbDrawText [ 7 ] ints (int) XmbDrawText     ( nitems text_items y x gc d dpy -- r )
\ libX11 XwcDrawText [ 7 ] ints (int) XwcDrawText     ( nitems text_items y x gc d dpy -- r )
\ libX11 XmbDrawString [ 8 ] ints (int) XmbDrawString   ( bytes_text text y x gc fontset d dpy -- r )
\ libX11 XwcDrawString [ 8 ] ints (int) XwcDrawString   ( num_wchars text y x gc fontset d dpy -- r )
\ libX11 XmbDrawImageString [ 8 ] ints (int) XmbDrawImageString      ( bytes_text text y x gc fontset d dpy -- r )
\ libX11 XwcDrawImageString [ 8 ] ints (int) XwcDrawImageString      ( num_wchars text y x gc fontset d dpy -- r )
\ libX11 XGetICValues_1 [ 4 ] ints (int) XGetICValues    ( ... ic -- string )
\ libX11 XGetICValues_2 [ 6 ] ints (int) XGetICValues    ( ... ic -- string )
\ libX11 XGetICValues_3 [ 8 ] ints (int) XGetICValues    ( ... ic -- string )
\ libX11 XmbLookupString [ 6 ] ints (int) XmbLookupString ( status_r keysym_r bytes_buffer buffer_r event ic -- n )
\ libX11 XwcLookupString [ 6 ] ints (int) XwcLookupString ( status_r keysym_r wchars_buffer buffer_r event ic -- n )
\ libX11 XRegisterIMInstantiateCallback [ 6 ] ints (int) XRegisterIMInstantiateCallback  ( client_data callback res_class res_name rdb dpy -- flag )
\ libX11 XUnregisterIMInstantiateCallbac [ 6 ] ints (int) XUnregisterIMInstantiateCallback        ( client_data callback res_class res_name rdb dpy -- flag )
\ libX11 XInternalConnectionNumbers [ 3 ] ints (int) XInternalConnectionNumbers      ( count_r fd_r dpy -- status )
\ libX11 XProcessInternalConnection [ 2 ] ints (int) XProcessInternalConnection      ( fd dpy -- r )
\ libX11 XAddConnectionWatch [ 3 ] ints (int) XAddConnectionWatch     ( client_data callback dpy -- status )
\ libX11 XRemoveConnectionWatch [ 3 ] ints (int) XRemoveConnectionWatch  ( client_data callback dpy -- status )


\ libX11 XmbSetWMProperties [ 9 ] ints (int) XmbSetWMProperties      ( class_hints wm_hints normal_hints argc argv icon_name window_name w dpy -- r )

\ libX11 XmbTextListToTextProperty [ 5 ] ints (int) XmbTextListToTextProperty       ( text_prop_r style count list dpy -- n )
\ libX11 XwcTextListToTextProperty [ 5 ] ints (int) XwcTextListToTextProperty       ( text_prop_r style count list dpy -- n )
\ libX11 XTextPropertyToStringList [ 3 ] ints (int) XTextPropertyToStringList       ( count_r list_r text_prop -- status )
\ libX11 XmbTextPropertyToTextList [ 4 ] ints (int) XmbTextPropertyToTextList       ( count_r list_r text_prop dpy -- n )
\ libX11 XwcTextPropertyToTextList [ 4 ] ints (int) XwcTextPropertyToTextList       ( count_r list_r text_prop dpy -- n )


\ X extensions

\ s" XAddToExtensionList"  C-word XAddToExtensionList  ( extdata structure -- r )
\ s" XFindOnExtensionList" C-word XFindOnExtensionList ( number structure -- extdata )
s" XFreeExtensionList"   C-word  XFreeExtensionList   ( aalist -- n )
\ s" XInitExtension"  C-word  XInitExtension  ( name dpy -- extcodes )
s" XListExtensions"   C-word  XListExtensions ( adpy anextensions_r -- aalist )
s" XQueryExtension"   C-word  XQueryExtension ( adpy  aname  amajor_opcode_r \
     afirst_event_r  afirst_error_r  -- nflag )


\ libXext XShmPutImage [ &11 ] ints (int) XShmPutImage   ( send_event h w dy dx sy sx im gc win dpy -- status )

base !
curr_wcl set-current
previous


\ include Xstring.fs




