\ cavity-modes.4th
\
\ Graphical demonstration of the standing modes of a cavity, and
\ the behavior of the mode frequencies with change in length of
\ the cavity.
\
\ Copyright (c) 2012 Krishna Myneni, <krishna.myneni@ccreweb.org>
\ 
\
\ Provided under the GNU General Public License.
\
\ Revisions:
\   2012-05-03  km  created.
\   2012-05-04  km  erase and redraw graphical elements rather
\                     than redrawing entire window, for smoother
\                     animation.
\ 
include ans-words
include fsl/fsl-util
include asm-x86
include strings
include lib-interface
include libs/x11/libX11
include x11/font-strings-x11
include x11/simple-graphics-x11
include x11/simple-fonts-x11
include x11/cs-strings-x11
include x11/simple-typeset-x11
include x11/simple-frames-x11

Also simple-graphics-x11
Also simple-fonts-x11
Also cs-strings-x11
Also simple-typeset-x11
Also simple-frames-x11

bold   regular 180 TextFonts1  FontSpec  text1a
bold   regular 140 TextFonts1  FontSpec  text1b
medium italic  240 TextFonts1  FontSpec  mathT
medium regular 240 SymbolFonts FontSpec  mathS

: title-font     ( -- )   text1a font-spec@ select-font ;
: body-font      ( -- )   text1b font-spec@ select-font ;
: math-text-font ( -- )   mathT  font-spec@ select-font ;
: math-sym-font  ( -- )   mathS  font-spec@ select-font ;


2.998e8 fconstant c
pi 2e f/ fconstant pi/2

0.10e fconstant L0        \ start cavity length (single pass length)
fvariable  L              \ current cavity length
L0 L f!

L0 2e f/ fnegate fconstant LEFT_M_Z  \ left mirror position

fvariable zr              \ right mirror horizontal position
L0 2e f/ zr f!
L0 100e f/ fconstant DZR  \ motion increment for right mirror

\ Note: left mirror is fixed at z = -L0/2

0.005e fconstant MWIDTH   \ mirror-width
0.10e  fconstant MHEIGHT  \ mirror-height

\ Return free spectral range of cavity
: fsr ( F: -- fsr )  c 2e L f@ f* f/ ;

\ Set cavity length based on current position of right mirror
: update-L ( -- ) zr f@ L0 2e f/ f+ L f! ;

: draw-left-mirror  ( -- )
    LEFT_M_Z MWIDTH f-    MHEIGHT 2e f/   \ x,y 
    MWIDTH MHEIGHT  put-filled-rectangle
;

: draw-right-mirror ( -- )
    zr f@   MHEIGHT 2e f/  
    MWIDTH MHEIGHT put-filled-rectangle
;

: erase-right-mirror ( -- ) white foreground draw-right-mirror ;

: draw-cavity-axis ( -- )
    2 1 set-line-type   \ thickness 2, dashed
    black foreground
    -0.07e 0e 0.07e 0e put-line
;

: draw-cavity ( -- )
    cyan foreground
    draw-left-mirror  draw-right-mirror
    draw-cavity-axis
;

fvariable k_z
fvariable dz
fvariable dl/2  \ (L - L0)/2
MHEIGHT 2e f/ fconstant A

500 float array  z{
500 float array  am{
0 value modenum

\ Compute wavenumber from mode number
: m>k_z ( m -- )  s>f pi f* L f@ f/ k_z f! ;

\ Set resolution for mode calculation (L/(m*100))
: set-dz ( m -- ) >r L f@ 100e r> s>f f* f/ dz f! ;
    
: calc-mode ( m -- )
    to modenum
    modenum  m>k_z
    modenum  set-dz
    L f@ L0 f- 2e f/  dl/2 f! 

    LEFT_M_Z        \ start at left mirror
    modenum 100 * 1+ 0 DO
      fdup z{ I } f!  
      fdup dl/2 f@ f- k_z f@ f*                \ k_z*(z - dl/2)
      modenum 1- 2 mod IF  pi/2 f+  THEN
      fcos A f*  am{ I } f!
      dz f@ f+
    LOOP
    fdrop  
;

: draw-mode ( m -- )
    dup calc-mode
    >r z{ 0 } am{ 0 } r> 100 * 1+ line-plot
;

: draw-cavity-modes ( -- )
    2 0 set-line-type
    red   foreground  1 draw-mode
    green foreground  2 draw-mode
    blue  foreground  3 draw-mode
;

: erase-cavity-modes ( -- )
   2 0 set-line-type
   white foreground 1 draw-mode 2 draw-mode 3 draw-mode ;

\ original mode frequency positions for cavity length, L0.
: mode>z0 ( m -- ) ( F: -- z0 )
    s>f 0.14e f* 4e f/ -0.07e f+ ;

\ new mode frequency positions, for cavity length, L.
: mode>z  ( m -- ) ( F: -- z)  
    s>f 0.14e f* 4e f/ L0 L f@ f/ f* -0.07e f+ ;

: draw-mode-fline ( F: z -- ) 
    -0.15e fover -0.09e put-line ;

: draw-frequency-scale ( -- )
    2 0 set-line-type
    black foreground
    -0.07e -0.15e 0.07e -0.15e put-line
    2 1 set-line-type
    red   foreground 1 mode>z0 draw-mode-fline
    green foreground 2 mode>z0 draw-mode-fline
    blue  foreground 3 mode>z0 draw-mode-fline
;

: draw-mode-freqs ( -- )
    2 0 set-line-type
    red   foreground  1 mode>z draw-mode-fline
    green foreground  2 mode>z draw-mode-fline
    blue  foreground  3 mode>z draw-mode-fline
;

: erase-mode-freqs ( -- )
    2 0 set-line-type  white foreground
    1 mode>z draw-mode-fline
    2 mode>z draw-mode-fline
    3 mode>z draw-mode-fline
;

: text1 ( -- )
    black foreground
    math-sym-font  0.06e -0.17e s" n" put-text
    title-font 1 s" Standing Wave Modes of a Cavity" place-centered-text
    -0.02e -0.065e s" Mode Frequencies" put-text
    body-font
    -0.04e -0.18e s" Use left or right arrow keys to move the right mirror."
    put-text
;

: update-drawing ( -- )
    erase-cavity-modes
    erase-mode-freqs
    update-L
    draw-cavity
    draw-cavity-modes
    draw-frequency-scale
    draw-mode-freqs
;

: move-rmirror-left ( -- )
    erase-right-mirror
    zr f@ DZR f- LEFT_M_Z MWIDTH f+ fmax zr f! ;

: move-rmirror-right ( -- )
    erase-right-mirror
    zr f@ DZR f+ 0.08e MWIDTH f- fmin zr f! ;

: frame1-key-handler ( -- )
    get-keyinfo
    CASE
      XK_Left   OF  move-rmirror-left  update-drawing ENDOF
      XK_Right  OF  move-rmirror-right update-drawing ENDOF
      XK_Page_Down  OF  frame-nav  ENDOF
      XK_Escape OF  exit-simple-graphics EXIT         ENDOF
    ENDCASE
    \ frame-nav
;

: frame1 ( -- )
    ['] frame1-key-handler IS on-keypress
    draw-cavity
    draw-cavity-modes
    draw-frequency-scale
    draw-mode-freqs
    text1
;

: offset-x ( x y dx -- x+dx y ) 2>r r> + r> ;

: text2 ( -- )
    black foreground
    title-font 1 s" Condition for Standing Waves" place-centered-text

    -0.01e -0.11e uc>wc
    s" \fnt mathT L = m\fnt mathS l/2 \fnt mathT \ \ \ m = 1, 2, 3, ..."
    draw-text-cs 2drop

    body-font
    -0.07e -0.12e uc>wc  0.14e udx>wdx
    s" The cavity length must be an integral number of half wavelengths. "
    s" Shown above are the m = 1 (red), 2 (green), and 3 (blue) modes:" strcat
    draw-hbox-wrapped-text

    -0.06e -0.16e uc>wc s" \fnt mathS l_1 = \fnt mathT 2L" 
    draw-text-cs  0.03e udx>wdx offset-x
    s" \fnt mathS l_2 = \fnt mathT L" draw-text-cs  0.03e udx>wdx offset-x 
    s" \fnt mathS l_3 = \fnt mathT 3L/2" draw-text-cs 2drop
;

: draw-length-scale ( -- )
    2 1 set-line-type  black foreground
    LEFT_M_Z  MHEIGHT 1.5e f/ fover  fover fnegate put-line 
    zr f@     MHEIGHT 1.5e f/ fover  fover fnegate put-line
    2 0 set-line-type
    LEFT_M_Z  MHEIGHT 1.5e f/ fnegate fover 1.5e f/ fover put-line
    zr f@ MHEIGHT 1.5e f/ fnegate fover 1.5e f/ fover put-line
;

: frame2 ( -- )
    ['] frame-nav IS on-keypress
    draw-cavity
    draw-cavity-modes
    draw-length-scale
    text2
;
    
: text3 ( -- )
    black foreground
    title-font 1 s" Cavity Mode Frequencies" place-centered-text
    -0.01e -0.08e uc>wc
    s" \fnt mathS n = \fnt mathT c/\fnt mathS l" draw-text-cs 2drop
;

: frame3 ( -- )
    draw-cavity
    draw-cavity-modes
    text3
;
   
' frame1 ' frame2 ' frame3
3 set-frames
-0.08e -0.2e 0.08e 0.1e set-window-limits
start-frames

