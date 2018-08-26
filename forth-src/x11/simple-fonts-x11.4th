\ simple-fonts-x11.4th
\
\ Simplified font loading and selection for X11 windows.
\
\ 
\ Copyright (c) 2012 Krishna Myneni, Creative Consulting for
\   Research and Education, http://ccreweb.org
\
\ This code may be used for any purpose, provided the copyright
\ notice above is included.
\
\ Provides:
\
\   Font weight constants:  medium  bold
\   Font slant  constants:  regular  italic  oblique
\
\   Font Variables and Tables
\
\     FontSpec  ( wt sl ptsize atable "name" -- ) \ create font variable
\     font-spec@     ( a -- wt sl ptsize atable ) \ fetch from font var
\     font-spec!     ( wt sl ptsize atable a -- ) \ store to font var
\     nullFont       ( -- 0 0 0 0 )               \ null font constant
\
\     FontTable      ( "name" -- )         \ create a font table
\     >font-index    ( weight slant ptsize -- index )
\     !font-entry    ( afontstruct font_id index atable -- )
\     @font-entry    ( index atable -- afontstruct font_id)
\
\   Loading and Setting Fonts and Font Tables
\
\     load-common-font  ( wgt slnt ptsize family -- afstruct font_id flag )
\     load-font-table   ( family atable -- flag )  \ load specific fonts in family
\     load-symbol-font  ( ptsize family -- afstruct font_id flag )
\     load-symbol-font-table ( family atable -- flag )
\     unload-font-table ( atable -- )        \ unload all fonts in a table
\     select-font       ( weight slant ptsize atable -- )
\     change-font-weight    ( weight -- )
\     change-font-slant     ( slant -- )
\     change-font-pointsize ( ptsize -- )
\     change-font-table     ( atable -- )
\     get-current-font      ( -- afontstruct )
\
\   Font Properties and Geometry
\
\     current-font-properties    ( -- weight slant pointsize )
\     current-font-ascent ( -- ascent )           \ pixels
\     current-font-height ( -- height )           \ in pixels
\     get-string-box ( caddr u -- width height  ) \ width and height in pixels
\                                                 \  of string in current font
\   Output:
\
\     draw-text-xytrack ( x1 y1 caddr u -- x2 y2 )
\
\ Revisions:
\   2012-04-28  km  created.
\   2012-04-30  km  added GET-CURRENT-FONT and Font Geometry words
\   2012-05-01  km  added LOAD-SYMBOL-FONT and LOAD-SYMBOL-FONT-TABLE
\   2012-05-04  km  declare dependency on the X11 vocabulary
\   2012-05-05  km  added GET-FONT-ASCENT and CURRENT-FONT-ASCENT
\   2012-05-10  km  added CHANGE-FONT-x words; moved the words
\                   GET-FONT-ASCENT and GET-FONT-HEIGHT to 
\                   module, simple-graphics-x11
\   2012-05-11  km  added DRAW-TEXT-XYTRACK
\   2012-05-13  km  added font variables for use with SELECT-FONT --
\                   new FontSpec type declaration and words
\                   FONT-SPEC@  FONT-SPEC!  and nullFont
\   2012-10-24  km  revised the following words to return a flag
\                   indicating success or failure (true = success):
\                   ?ADD-FONT  LOAD-FONT-TABLE  LOAD-SYMBOL-FONT-TABLE
\   2015-07-30  km  revise glossary comments to fix stack diagrams.
\   2016-06-04  km  revised SELECT-FONT to avoid setting uninitialized font.

Module: simple-fonts-x11

Also X11
Also font-strings-x11
Also simple-graphics-x11

Begin-Module

Public:

\ Font Variables for use with SELECT-FONT
: font-spec@ ( a -- weight slant ptsize atable )
    dup >r 2 cells + 2@ r@ cell+ @ r> a@ ;

: font-spec! ( weight slant ptsize atable a -- )
    dup >r ! r@ cell+ ! r> 2 cells + 2! ;

\ Defining word for FontSpec type
: FontSpec ( weight slant ptsize atable "name" -- )
    create 4 cells ?allot font-spec! ;

: nullFont 0 0 0 0 ;   \ a useful fontspec constant

\ Simple names for font weights and slants
FONT_WEIGHT_MEDIUM constant  medium
FONT_WEIGHT_BOLD   constant  bold
FONT_SLANT_REGULAR constant  regular
FONT_SLANT_ITALIC  constant  italic
FONT_SLANT_OBLIQUE constant  oblique

 5 constant SUPPORTED_POINTSIZES
20 constant MAX_FAMILY_FONTS
MAX_FAMILY_FONTS cells 2* constant FONT_TABLE_SIZE

Private:

: pointsize>index ( pointsize -- index )
   100 max 240 min   \ enforce bounds on pointsize
   100 - 20 /        \ 0, 1, 2, 4, 7
   dup 3 7 within if drop 3 then
   dup 3 > if drop 4 then
;

: slant>index  ( slant -- index )  1- 0 max 1 min ;
: weight>index ( weight -- index ) 1- 0 max 1 min ;

: ?load-font ( caddr u -- afontstruct font_id flag )
    dup 0= IF  2drop 0 0 false  ELSE  load-font  THEN ;

Public:
   
: >font-index ( weight slant pointsize -- fontindex )
    pointsize>index >r  slant>index >r  weight>index
    SUPPORTED_POINTSIZES 2* * r> SUPPORTED_POINTSIZES * + r> +
;

: load-common-font ( weight slant pointsize family -- afontstruct font_id flag)
    get-common-font-xlfd  ?load-font ;

: load-symbol-font ( pointsize family -- afontstruct font_id flag )
    2>r  medium regular 2r@ drop  FONT_SPACING_PROPORTIONAL 0
    2r>  nip $common_fonts  make-xlfd  ?load-font ;

\ Store information about a loaded font into the specified font table
: !font-entry ( afontstruct  font_id  index  atable --  )  
    over 0 MAX_FAMILY_FONTS within 
    IF >r cells 2* r> + 2! ELSE  2drop 2drop THEN ;

: @font-entry ( index atable -- afontstruct font_id )
    >r cells 2* r> + dup >r cell+ a@ r> @ ;

: ?add-font ( weight slant pointsize family atable -- flag )
    >r 2over 2over drop >font-index >r
    load-common-font
    IF    r> r> !font-entry true
    ELSE  cr ." load-common-font failed! font index = " r> .
          r> drop 2drop false 
    THEN ;

: FontTable  create FONT_TABLE_SIZE allot ;

\ Loads 20 specific fonts from a font family and stores
\ the loaded font information into the specified table.
\ Fonts from the font family are loaded at two different
\ weights (medium, bold), two different slants (regular,
\ italic), and five different point sizes: 
\ 100, 120, 140, 180, 240.

: load-font-table ( family atable -- flag )
    2>r 
    medium regular 100  2r@  ?add-font
    medium regular 120  2r@  ?add-font and
    medium regular 140  2r@  ?add-font and
    medium regular 180  2r@  ?add-font and
    medium regular 240  2r@  ?add-font and
    medium italic  100  2r@  ?add-font and
    medium italic  120  2r@  ?add-font and
    medium italic  140  2r@  ?add-font and
    medium italic  180  2r@  ?add-font and
    medium italic  240  2r@  ?add-font and
    bold   regular 100  2r@  ?add-font and
    bold   regular 120  2r@  ?add-font and
    bold   regular 140  2r@  ?add-font and
    bold   regular 180  2r@  ?add-font and
    bold   regular 240  2r@  ?add-font and
    bold   italic  100  2r@  ?add-font and
    bold   italic  120  2r@  ?add-font and
    bold   italic  140  2r@  ?add-font and
    bold   italic  180  2r@  ?add-font and
    bold   italic  240  2r@  ?add-font and   
    2r> 2drop
;

: load-symbol-font-table ( family atable -- flag )
     2>r
     100 2r@ drop load-symbol-font  0 r@ !font-entry
     120 2r@ drop load-symbol-font  1 r@ !font-entry  and
     140 2r@ drop load-symbol-font  2 r@ !font-entry  and
     180 2r@ drop load-symbol-font  3 r@ !font-entry  and
     240 2r@ drop load-symbol-font  4 r@ !font-entry  and
     2r> 2drop
; 

: unload-font-table ( atable -- )
    MAX_FAMILY_FONTS 0 do
      I over @font-entry 
      dup IF unload-font ELSE drop THEN drop
    loop
    drop
;

Private:

variable pCurrentFont       \ pointer to XFontstruct for current font
variable pCurrentFontTable
variable CurrentFontWeight
variable CurrentFontSlant
variable CurrentFontPointSize
variable CurrentFontAscent
variable CurrentFontHeight

Public:

\ Select a font from the specified table, by specifying
\ its weight (medium or bold), slant (regular or italic)
\ and its point size. If the point size is not one of
\ standard point sizes, the closest match will be used.

: select-font ( weight slant pointsize atable -- )
    2over CurrentFontSlant  !  CurrentFontWeight !
    2dup  pCurrentFontTable !  CurrentFontPointSize !   
    >r >font-index r> @font-entry
    ?dup IF
      set-font  
      dup pCurrentFont !
      \ store the font ascent and height
      dup get-font-ascent CurrentFontAscent !
          get-font-height CurrentFontHeight !
    ELSE drop
    THEN
;

\ The change-font-x functions change only the x parameter of
\ the current font, leaving other parameters intact. Do not
\ use these words prior to using SELECT-FONT to set the inital
\ font.

\ Change the current font weight to the specified weight
: change-font-weight ( bold|medium -- )
    CurrentFontSlant @ CurrentFontPointSize @ pCurrentFontTable a@
    select-font ;

\ Change the current font slant to the specified slant
: change-font-slant ( regular|italic|oblique -- )
    >r CurrentFontWeight @ r> CurrentFontPointSize @ pCurrentFontTable a@
    select-font ;

\ Change the current font point size to the specified size
: change-font-pointsize ( 100|120|140|180|240 -- )
    >r CurrentFontWeight @ CurrentFontSlant @ r> pCurrentFontTable a@
    select-font ;

\ Change the current font table to the specified table
: change-font-table ( atable -- )
    >r CurrentFontWeight @ CurrentFontSlant @ CurrentFontPointSize @ r>
    select-font ;

\ Return the current font properties, weight, slant, and pointsize
: current-font-properties ( -- weight slant pointsize ) 
    CurrentFontWeight @  CurrentFontSlant @  CurrentFontPointSize @ ;

\ Return the pointer to the x11 font structure for current font
: get-current-font ( -- afontstruct ) pCurrentFont a@ ;

\ Return the current font ascent in pixels
: current-font-ascent ( -- ascent ) CurrentFontAscent @ ;

\ Return the current font height in pixels
: current-font-height ( -- height ) CurrentFontHeight @ ;

\ Return the width and height in pixels of a string in the current font
: get-string-box ( caddr u -- width height )
    strpck count 2>r pCurrentFont a@ 2r> XTextWidth 
    CurrentFontHeight @ 
;

\ Draw text at specified window coordinates, and keep track
\   of text coordinates.
: draw-text-xytrack ( x1 y1 caddr u -- x2 y2 )
    2dup get-string-box drop >r   \ x1 y1 caddr u
    2>r 2dup 2r> draw-text
    r> rot + swap
; 
       
End-Module

