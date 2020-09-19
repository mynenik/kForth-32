\ font-strings-x11.4th
\
\ Module for making valid x11 font description strings
\ 
\  Copyright (c) 2012--2020 Krishna Myneni
\
\  This code may be used for any purpose, provided the
\  copyright notice above is included.
\
\ Requires:
\   strings.4th
\   utils.4th
\

[undefined] $table [IF] s" utils" included  [THEN]

Module: font-strings-x11
Begin-Module

variable xdpi    \ horizontal display resolution in dots per inch (dpi)
variable ydpi    \ vertical   dpi
0 xdpi ! 0 ydpi !

25 constant nCommonFonts

Public:

\ Common font families
 0  constant  FONT_FIXED
 1  constant  FONT_TIMES_NEW_ROMAN
 2  constant  FONT_TIMES
 3  constant  FONT_COURIER
 4  constant  FONT_COURIER_NEW
 5  constant  FONT_COURIER_10_PITCH
 6  constant  FONT_ARIAL
 7  constant  FONT_ARIALBLACK
 8  constant  FONT_HELVETICA
 9  constant  FONT_CHARTER
10  constant  FONT_BITSTREAM_CHARTER
11  constant  FONT_NEW_CENTURY_SCHOOLBOOK
12  constant  FONT_LUCIDA
13  constant  FONT_LUCIDABRIGHT
14  constant  FONT_UTOPIA
15  constant  FONT_GEORGIA
16  constant  FONT_VERDANA
17  constant  FONT_PALATINO
18  constant  FONT_BOOKMAN
19  constant  FONT_ANDALE_MONO
20  constant  FONT_IMPACT
21  constant  FONT_TREBUCHET_MS
22  constant  FONT_COMIC_SANS_MS
23  constant  FONT_SYMBOL
24  constant  FONT_STANDARD_SYMBOLS_L

s" fixed"
s" times new roman"
s" times"
s" courier"
s" courier new"
s" courier 10 pitch"
s" arial"
s" arial black"
s" helvetica"
s" charter"
s" bitstream charter"
s" new century schoolbook"
s" lucida"
s" lucidabright"
s" utopia"
s" georgia"
s" verdana"
s" palatino"
s" bookman"
s" andale mono"
s" impact"
s" trebuchet ms"
s" comic sans ms"
s" symbol"
s" standard symbols l"
nCommonFonts 32 $table $common_fonts


\ Font weights
 1  constant  FONT_WEIGHT_MEDIUM
 2  constant  FONT_WEIGHT_BOLD

\ Font slants
 1  constant  FONT_SLANT_REGULAR
 2  constant  FONT_SLANT_ITALIC
 3  constant  FONT_SLANT_OBLIQUE

\ Font spacings
 1  constant  FONT_SPACING_MONOSPACE
 2  constant  FONT_SPACING_PROPORTIONAL

\ Font character set
 0  constant  FONT_CHARSET_ANY
 1  constant  FONT_CHARSET_ISO8559_1
 2  constant  FONT_CHARSET_ISO10646_1

Private:

variable charset
variable spacing
variable ptsize
variable slant
variable weight

Public:

\ Set the horizontal and vertical resolution to use for font strings
: xlfd-set-resolution ( xdpi ydpi -- )  ydpi !  xdpi ! ;

\ Make an X11 logical font description string, e.g.
\
\   FONT_WEIGHT_MEDIUM  FONT_SLANT_REGULAR  180
\   FONT_SPACING_PROPORTIONAL FONT_CHARSET_ISO8559_1  
\   s" bitstream charter" make-xlfd
\ 
\ will return the string,
\
\   "-*-bitstream charter-medium-r-normal--*-180-*-*-p-*-iso8859-1"
\
\ For the weight, slant, spacing, and charset arguments, use a zero
\ argument to place a "*" wildcard in the string.

: make-xlfd ( nweight nslant npointsize nspacing ncharset caddr1 u1 -- caddr2 u2 )
    2>r charset !  spacing ! ptsize !  slant !  weight !
    s" -*-" 2r> strcat
    weight @
    case
      FONT_WEIGHT_MEDIUM of  s" -medium"  endof
      FONT_WEIGHT_BOLD   of  s" -bold"    endof
      >r s" -*" r>
    endcase
    strcat
    slant @
    case
      FONT_SLANT_REGULAR of  s" -r"  endof
      FONT_SLANT_ITALIC  of  s" -i"  endof
      FONT_SLANT_OBLIQUE of  s" -o"  endof
      >r s" -*" r>
    endcase
    strcat
    s" -normal--*-" strcat
    ptsize @ 0 <# # # # #> strcat
    s" -" strcat
    xdpi @ ?dup if 0 <# # # # #> else s" *" then strcat
    s" -" strcat
    ydpi @ ?dup if 0 <# # # # #> else s" *" then strcat
    spacing @
    case
      FONT_SPACING_MONOSPACE    of  s" -m"  endof
      FONT_SPACING_PROPORTIONAL of  s" -p"  endof
      >r s" -*" r>
    endcase
    strcat
    s" -*" strcat
    charset @
    case
      FONT_CHARSET_ISO8559_1 of  s" -iso8859-1"  endof
      FONT_CHARSET_ISO10646_1 of s" -iso10646-1" endof
      >r s" -*-*" r>
    endcase
    strcat
;

\ Simplified way to get the x11 name of a common font. Only
\ four parameters are required: common font family number, font
\ weight, font slant, and point size (in tenths of points).
\
\ Example:
\
\   FONT_WEIGHT_BOLD  FONT_SLANT_ITALIC  140  FONT_ARIAL
\   get-common-font-xlfd
 
: get-common-font-xlfd ( weight slant pointsize family -- caddr u )
    dup 0 nCommonFonts within IF
      $common_fonts 2>r 0 FONT_CHARSET_ANY 2r> make-xlfd
    ELSE
      ." Common Font Index out of bounds!"
      2drop 2drop 0 0
    THEN
;

End-Module

