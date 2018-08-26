\ X.4th
\
\ Definitions from X.h
\ Adapted to Forth by Krishna Myneni, Creative Consulting for
\   Research and Education, krishna.myneni@ccreweb.org
\
\ Original comments and copyright notice:
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
\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
\ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
\ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
\ OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
\ AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
\ CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
\
\ Except as contained in this notice, the name of The Open Group shall not be
\ used in advertising or otherwise to promote the sale, use or other dealings
\ in this Software without prior written authorization from The Open Group.


11 constant X_PROTOCOL                  \ current protocol version
 0 constant X_PROTOCOL_REVISION         \ current minor version

\ *****************************************************************
\  RESERVED RESOURCE AND CONSTANT DEFINITIONS
\ *****************************************************************

[undefined] None [IF]
0 constant  None               \ universal null resource or null atom
[THEN]
1 constant  ParentRelative     \ background pixmap in CreateWindow
                               \     and ChangeWindowAttributes
0 constant  CopyFromParent     \ border pixmap in CreateWindow
                               \        and ChangeWindowAttributes
                               \    special VisualID and special window
                               \        class passed to CreateWindow
0 constant  PointerWindow      \ destination window in SendEvent
1 constant  InputFocus         \ destination window in SendEvent
1 constant  PointerRoot        \ focus window in SetInputFocus
0 constant  AnyPropertyType    \ special Atom, passed to GetProperty
0 constant  AnyKey             \ special Key Code, passed to GrabKey
0 constant  AnyButton          \ special Button Code, passed to GrabButton
0 constant  AllTemporary       \ special Resource ID passed to KillClient
0 constant  CurrentTime        \ special Time
0 constant  NoSymbol           \ special KeySym


\ *****************************************************************
\  EVENT DEFINITIONS
\ *****************************************************************

\ Input Event Masks. Used as event-mask window attribute and as arguments
\   to Grab requests.  Not to be confused with event names.

    0        constant  NoEventMask
 1  0 lshift constant  KeyPressMask                    ( 1L<<0)
 1  1 lshift constant  KeyReleaseMask                  ( 1L<<1)
 1  2 lshift constant  ButtonPressMask                 ( 1L<<2)
 1  3 lshift constant  ButtonReleaseMask               ( 1L<<3)
 1  4 lshift constant  EnterWindowMask                 ( 1L<<4)
 1  5 lshift constant  LeaveWindowMask                 ( 1L<<5)
 1  6 lshift constant  PointerMotionMask               ( 1L<<6)
 1  7 lshift constant  PointerMotionHintMask           ( 1L<<7)
 1  8 lshift constant  Button1MotionMask               ( 1L<<8)
 1  9 lshift constant  Button2MotionMask               ( 1L<<9)
 1 10 lshift constant  Button3MotionMask               ( 1L<<10)
 1 11 lshift constant  Button4MotionMask               ( 1L<<11)
 1 12 lshift constant  Button5MotionMask               ( 1L<<12)
 1 13 lshift constant  ButtonMotionMask                ( 1L<<13)
 1 14 lshift constant  KeymapStateMask                 ( 1L<<14)
 1 15 lshift constant  ExposureMask                    ( 1L<<15)
 1 16 lshift constant  VisibilityChangeMask            ( 1L<<16)
 1 17 lshift constant  StructureNotifyMask             ( 1L<<17)
 1 18 lshift constant  ResizeRedirectMask              ( 1L<<18)
 1 19 lshift constant  SubstructureNotifyMask          ( 1L<<19)
 1 20 lshift constant  SubstructureRedirectMask        ( 1L<<20)
 1 21 lshift constant  FocusChangeMask                 ( 1L<<21)
 1 22 lshift constant  PropertyChangeMask              ( 1L<<22)
 1 23 lshift constant  ColormapChangeMask              ( 1L<<23)
 1 24 lshift constant  OwnerGrabButtonMask             ( 1L<<24)

\ Event names.  Used in "type" field in XEvent structures.  Not to be
\ confused with event masks above.  They start from 2 because 0 and 1
\ are reserved in the protocol for errors and replies.

 2 constant  KeyPress
 3 constant  KeyRelease
 4 constant  ButtonPress
 5 constant  ButtonRelease           
 6 constant  MotionNotify            
 7 constant  EnterNotify             
 8 constant  LeaveNotify             
 9 constant  FocusIn                 
10 constant  FocusOut                
11 constant  KeymapNotify            
12 constant  Expose                  
13 constant  GraphicsExpose          
14 constant  NoExpose                
15 constant  VisibilityNotify        
16 constant  CreateNotify            
17 constant  DestroyNotify           
18 constant  UnmapNotify             
19 constant  MapNotify               
20 constant  MapRequest              
21 constant  ReparentNotify          
22 constant  ConfigureNotify         
23 constant  ConfigureRequest        
24 constant  GravityNotify           
25 constant  ResizeRequest           
26 constant  CirculateNotify         
27 constant  CirculateRequest        
28 constant  PropertyNotify          
29 constant  SelectionClear          
30 constant  SelectionRequest        
31 constant  SelectionNotify         
32 constant  ColormapNotify          
33 constant  ClientMessage           
34 constant  MappingNotify           
35 constant  LASTEvent             \ must be bigger than any event 

\ Key masks. Used as modifiers to GrabButton and GrabKey, results of QueryPointer,
\   state in various key-, mouse-, and button-related events.

 1 0 lshift constant  ShiftMask               ( 1<<0)
 1 1 lshift constant  LockMask                ( 1<<1)
 1 2 lshift constant  ControlMask             ( 1<<2)
 1 3 lshift constant  Mod1Mask                ( 1<<3)
 1 4 lshift constant  Mod2Mask                ( 1<<4)
 1 5 lshift constant  Mod3Mask                ( 1<<5)
 1 6 lshift constant  Mod4Mask                ( 1<<6)
 1 7 lshift constant  Mod5Mask                ( 1<<7)

\ modifier names.  Used to build a SetModifierMapping request or
\   to read a GetModifierMapping request.  These correspond to the
\   masks defined above.
 0 constant  ShiftMapIndex
 1 constant  LockMapIndex
 2 constant  ControlMapIndex
 3 constant  Mod1MapIndex
 4 constant  Mod2MapIndex
 5 constant  Mod3MapIndex
 6 constant  Mod4MapIndex
 7 constant  Mod5MapIndex

\ button masks.  Used in same manner as Key masks above. Not to be confused
\   with button names below.

 1  8 lshift constant  Button1Mask             ( 1<<8)
 1  9 lshift constant  Button2Mask             ( 1<<9)
 1 10 lshift constant  Button3Mask             ( 1<<10)
 1 11 lshift constant  Button4Mask             ( 1<<11)
 1 12 lshift constant  Button5Mask             ( 1<<12)

 1 15 lshift constant  AnyModifier             ( 1<<15) \ used in GrabButton, GrabKey


\ button names. Used as arguments to GrabButton and as detail in ButtonPress
\   and ButtonRelease events.  Not to be confused with button masks above.
\   Note that 0 is already defined above as "AnyButton". 

 1 constant  Button1
 2 constant  Button2
 3 constant  Button3
 4 constant  Button4
 5 constant  Button5

\ Notify modes

 0 constant NotifyNormal          
 1 constant NotifyGrab             
 2 constant NotifyUngrab           
 3 constant NotifyWhileGrabbed     

 1 constant NotifyHint            \ for MotionNotify events

\ Notify detail

 0 constant  NotifyAncestor         
 1 constant  NotifyVirtual          
 2 constant  NotifyInferior         
 3 constant  NotifyNonlinear        
 4 constant  NotifyNonlinearVirtual 
 5 constant  NotifyPointer          
 6 constant  NotifyPointerRoot      
 7 constant  NotifyDetailNone       

\ Visibility notify

 0 constant  VisibilityUnobscured          
 1 constant  VisibilityPartiallyObscured    
 2 constant  VisibilityFullyObscured        

\ Circulation request 

 0 constant PlaceOnTop            
 1 constant PlaceOnBottom      

\ protocol families

 0 constant  FamilyInternet               \ IPv4
 1 constant  FamilyDECnet           
 2 constant  FamilyChaos            
 6 constant  FamilyInternet6              \ IPv6

\ authentication families not tied to a specific protocol
 5 constant  FamilyServerInterpreted

\ Property notification

 0 constant  PropertyNewValue      
 1 constant  PropertyDelete         

\ Color Map notification

 0 constant  ColormapUninstalled   
 1 constant  ColormapInstalled   

\ GrabPointer, GrabButton, GrabKeyboard, GrabKey Modes

 0 constant  GrabModeSync
 1 constant  GrabModeAsync

\ GrabPointer, GrabKeyboard reply status

 0 constant  GrabSuccess            
 1 constant  AlreadyGrabbed         
 2 constant  GrabInvalidTime        
 3 constant  GrabNotViewable        
 4 constant  GrabFrozen             

\ AllowEvents modes

 0 constant  AsyncPointer          
 1 constant  SyncPointer            
 2 constant  ReplayPointer          
 3 constant  AsyncKeyboard          
 4 constant  SyncKeyboard           
 5 constant  ReplayKeyboard         
 6 constant  AsyncBoth              
 7 constant  SyncBoth               

\ Used in SetInputFocus, GetInputFocus

None        constant  RevertToNone      
PointerRoot constant  RevertToPointerRoot
2           constant  RevertToParent

\ *****************************************************************
\  ERROR CODES
\ *****************************************************************

 0 constant  Success               \ everything's okay
 1 constant  BadRequest            \ bad request code
 2 constant  BadValue              \ int parameter out of range
 3 constant  BadWindow             \ parameter not a Window
 4 constant  BadPixmap             \ parameter not a Pixmap
 5 constant  BadAtom               \ parameter not an Atom
 6 constant  BadCursor             \ parameter not a Cursor
 7 constant  BadFont               \ parameter not a Font
 8 constant  BadMatch              \ parameter mismatch
 9 constant  BadDrawable           \ parameter not a Pixmap or Window
10 constant  BadAccess             \ depending on context:
                                   \ - key/button already grabbed
                                   \ - attempt to free an illegal
                                   \ cmap entry
                                   \ - attempt to store into a read-only
                                   \ color map entry.
                                   \ - attempt to modify the access control
                                   \ list from other than the local host.

11 constant  BadAlloc              \ insufficient resources
12 constant  BadColor              \ no such colormap
13 constant  BadGC                 \ parameter not a GC
14 constant  BadIDChoice           \ choice not in range or already used
15 constant  BadName               \ font or color name doesn't exist
16 constant  BadLength             \ Request length incorrect
17 constant  BadImplementation     \ server is defective

128 constant  FirstExtensionError
255 constant  LastExtensionError

\ *****************************************************************
\  WINDOW DEFINITIONS
\ *****************************************************************

\ Window classes used by CreateWindow
\ Note that CopyFromParent is already defined as 0 above

 1 constant  InputOutput            
 2 constant  InputOnly              

\ Window attributes for CreateWindow and ChangeWindowAttributes

 1  0 lshift constant  CWBackPixmap            ( 1L<<0)
 1  1 lshift constant  CWBackPixel             ( 1L<<1)
 1  2 lshift constant  CWBorderPixmap          ( 1L<<2)
 1  3 lshift constant  CWBorderPixel           ( 1L<<3)
 1  4 lshift constant  CWBitGravity            ( 1L<<4)
 1  5 lshift constant  CWWinGravity            ( 1L<<5)
 1  6 lshift constant  CWBackingStore          ( 1L<<6)
 1  7 lshift constant  CWBackingPlanes         ( 1L<<7)
 1  8 lshift constant  CWBackingPixel          ( 1L<<8)
 1  9 lshift constant  CWOverrideRedirect      ( 1L<<9)
 1 10 lshift constant  CWSaveUnder             ( 1L<<10)
 1 11 lshift constant  CWEventMask             ( 1L<<11)
 1 12 lshift constant  CWDontPropagate         ( 1L<<12)
 1 13 lshift constant  CWColormap              ( 1L<<13)
 1 14 lshift constant  CWCursor                ( 1L<<14)

\ ConfigureWindow structure

 1 0 lshift constant  CWX                     ( 1<<0)
 1 1 lshift constant  CWY                     ( 1<<1)
 1 2 lshift constant  CWWidth                 ( 1<<2)
 1 3 lshift constant  CWHeight                ( 1<<3)
 1 4 lshift constant  CWBorderWidth           ( 1<<4)
 1 5 lshift constant  CWSibling               ( 1<<5)
 1 6 lshift constant  CWStackMode             ( 1<<6)

\ Bit Gravity

 0 constant  ForgetGravity          
 1 constant  NorthWestGravity       
 2 constant  NorthGravity           
 3 constant  NorthEastGravity       
 4 constant  WestGravity            
 5 constant  CenterGravity          
 6 constant  EastGravity            
 7 constant  SouthWestGravity       
 8 constant  SouthGravity           
 9 constant  SouthEastGravity      
10 constant  StaticGravity      

\ Window gravity + bit gravity above

 0 constant  UnmapGravity           

\ Used in CreateWindow for backing-store hint

 0 constant  NotUseful              
 1 constant  WhenMapped             
 2 constant  Always                 

\ Used in GetWindowAttributes reply

 0 constant  IsUnmapped             
 1 constant  IsUnviewable           
 2 constant  IsViewable             

\ Used in ChangeSaveSet

 0 constant  SetModeInsert          
 1 constant  SetModeDelete          

\ Used in ChangeCloseDownMode

 0 constant  DestroyAll             
 1 constant  RetainPermanent        
 2 constant  RetainTemporary        

\ Window stacking method (in configureWindow)

 0 constant  Above                  
 1 constant  Below                  
 2 constant  TopIf                  
 3 constant  BottomIf               
 4 constant  Opposite              

\ Circulation direction

 0 constant  RaiseLowest            
 1 constant  LowerHighest          

\ Property modes

 0 constant  PropModeReplace        
 1 constant  PropModePrepend        
 2 constant  PropModeAppend         

\ *****************************************************************
\  GRAPHICS DEFINITIONS
\ *****************************************************************

\ graphics functions, as in GC.alu
hex
 0 constant  GXclear                              \ 0
 1 constant  GXand                                \ src AND dst
 2 constant  GXandReverse                         \ src AND NOT dst
 3 constant  GXcopy                               \ src
 4 constant  GXandInverted                        \ NOT src AND dst
 5 constant  GXnoop                               \ dst
 6 constant  GXxor                                \ src XOR dst
 7 constant  GXor                                 \ src OR dst
 8 constant  GXnor                                \ NOT src AND NOT dst
 9 constant  GXequiv                              \ NOT src XOR dst
 A constant  GXinvert                             \ NOT dst
 B constant  GXorReverse                          \ src OR NOT dst
 C constant  GXcopyInverted                       \ NOT src
 D constant  GXorInverted                         \ NOT src OR dst
 E constant  GXnand                               \ NOT src OR NOT dst
 F constant  GXset                                \ 1 
decimal

\ LineStyle

 0 constant  LineSolid              
 1 constant  LineOnOffDash          
 2 constant  LineDoubleDash         

\ capStyle

 0 constant  CapNotLast             
 1 constant  CapButt                
 2 constant  CapRound               
 3 constant  CapProjecting          

\ joinStyle

 0 constant  JoinMiter              
 1 constant  JoinRound              
 2 constant  JoinBevel              

\ fillStyle

 0 constant  FillSolid              
 1 constant  FillTiled              
 2 constant  FillStippled           
 3 constant  FillOpaqueStippled     

\ fillRule

 0 constant  EvenOddRule            
 1 constant  WindingRule            

\ subwindow mode

 0 constant  ClipByChildren         
 1 constant  IncludeInferiors       

\ SetClipRectangles ordering

 0 constant  Unsorted              
 1 constant  YSorted                
 2 constant  YXSorted               
 3 constant  YXBanded               

\ CoordinateMode for drawing routines

 0 constant  CoordModeOrigin           \ relative to the origin
 1 constant  CoordModePrevious         \ relative to previous point

\ Polygon shapes

 0 constant  Complex                   \ paths may intersect
 1 constant  Nonconvex                 \ no paths intersect, but not convex
 2 constant  Convex                    \ wholly convex

\ Arc modes for PolyFillArc

 0 constant  ArcChord                  \ join endpoints of arc
 1 constant  ArcPieSlice               \ join endpoints to center of arc

\ GC components: masks used in CreateGC, CopyGC, ChangeGC, OR'ed into
\   GC.stateChanges

 1  0 lshift constant  GCFunction              ( 1L<<0)
 1  1 lshift constant  GCPlaneMask             ( 1L<<1)
 1  2 lshift constant  GCForeground            ( 1L<<2)
 1  3 lshift constant  GCBackground            ( 1L<<3)
 1  4 lshift constant  GCLineWidth             ( 1L<<4)
 1  5 lshift constant  GCLineStyle             ( 1L<<5)
 1  6 lshift constant  GCCapStyle              ( 1L<<6)
 1  7 lshift constant  GCJoinStyle             ( 1L<<7)
 1  8 lshift constant  GCFillStyle             ( 1L<<8)
 1  9 lshift constant  GCFillRule              ( 1L<<9)
 1 10 lshift constant  GCTile                  ( 1L<<10)
 1 11 lshift constant  GCStipple               ( 1L<<11)
 1 12 lshift constant  GCTileStipXOrigin       ( 1L<<12)
 1 13 lshift constant  GCTileStipYOrigin       ( 1L<<13)
 1 14 lshift constant  GCFont                  ( 1L<<14)
 1 15 lshift constant  GCSubwindowMode         ( 1L<<15)
 1 16 lshift constant  GCGraphicsExposures     ( 1L<<16)
 1 17 lshift constant  GCClipXOrigin           ( 1L<<17)
 1 18 lshift constant  GCClipYOrigin           ( 1L<<18)
 1 19 lshift constant  GCClipMask              ( 1L<<19)
 1 20 lshift constant  GCDashOffset            ( 1L<<20)
 1 21 lshift constant  GCDashList              ( 1L<<21)
 1 22 lshift constant  GCArcMode               ( 1L<<22)

 22 constant  GCLastBit
\ *****************************************************************
\  FONTS
\ *****************************************************************

\ used in QueryFont -- draw direction

 0 constant  FontLeftToRight
 1 constant  FontRightToLeft

 255 constant  FontChange

\ *****************************************************************
\   IMAGING
\ *****************************************************************

\ ImageFormat -- PutImage, GetImage

 0 constant  XYBitmap                      \ depth 1, XYFormat
 1 constant  XYPixmap                      \ depth == drawable depth
 2 constant  ZPixmap                       \ depth == drawable depth

\ *****************************************************************
\   COLOR MAP STUFF
\ *****************************************************************

\ For CreateColormap

 0 constant  AllocNone                     \ create map with no entries
 1 constant  AllocAll                      \ allocate entire map writeable


\ Flags used in StoreNamedColor, StoreColors

 1 0 lshift constant  DoRed                   ( 1<<0)
 1 1 lshift constant  DoGreen                 ( 1<<1)
 1 2 lshift constant  DoBlue                  ( 1<<2)

\ *****************************************************************
\  CURSOR STUFF
\ *****************************************************************

\ QueryBestSize Class

 0 constant  CursorShape                  \ largest size that can be displayed
 1 constant  TileShape                    \ size tiled fastest
 2 constant  StippleShape                 \ size stippled fastest

\ *****************************************************************
\  KEYBOARD/POINTER STUFF
\ *****************************************************************

 0 constant  AutoRepeatModeOff
 1 constant  AutoRepeatModeOn
 2 constant  AutoRepeatModeDefault

 0 constant  LedModeOff          
 1 constant  LedModeOn             

\ masks for ChangeKeyboardControl

 1 0 lshift constant  KBKeyClickPercent       ( 1L<<0)
 1 1 lshift constant  KBBellPercent           ( 1L<<1)
 1 2 lshift constant  KBBellPitch             ( 1L<<2)
 1 3 lshift constant  KBBellDuration          ( 1L<<3)
 1 4 lshift constant  KBLed                   ( 1L<<4)
 1 5 lshift constant  KBLedMode               ( 1L<<5)
 1 6 lshift constant  KBKey                   ( 1L<<6)
 1 7 lshift constant  KBAutoRepeatMode        ( 1L<<7)

 0 constant  MappingSuccess        
 1 constant  MappingBusy            
 2 constant  MappingFailed          

 0 constant  MappingModifier      
 1 constant  MappingKeyboard      
 2 constant  MappingPointer        

\ *****************************************************************
\  SCREEN SAVER STUFF
\ *****************************************************************

 0 constant  DontPreferBlanking  
 1 constant  PreferBlanking       
 2 constant  DefaultBlanking       

 0 constant  DisableScreenSaver   
 0 constant  DisableScreenInterval 

 0 constant  DontAllowExposures    
 1 constant  AllowExposures         
 2 constant  DefaultExposures       

\ for ForceScreenSaver

 0 constant  ScreenSaverReset
 1 constant  ScreenSaverActive

\ *****************************************************************
\  HOSTS AND CONNECTIONS
\ *****************************************************************

\ for ChangeHosts

 0 constant  HostInsert            
 1 constant  HostDelete             

\ for ChangeAccessControl

 1 constant  EnableAccess           
 0 constant  DisableAccess          

\ Display classes  used in opening the connection
\  Note that the statically allocated ones are even numbered and the
\  dynamically changeable ones are odd numbered 

 0 constant  StaticGray            
 1 constant  GrayScale             
 2 constant  StaticColor           
 3 constant  PseudoColor           
 4 constant  TrueColor             
 5 constant  DirectColor            


\ Byte order  used in imageByteOrder and bitmapBitOrder 

 0 constant  LSBFirst              
 1 constant  MSBFirst               


\ end of X.4th

