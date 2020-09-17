\ cs-strings-x11.4th
\
\ Support for strings with control sequences to perform
\ switching between fonts, changing current font properties,
\ or to perform other text formatting.
\
\ Copyright (c) 2012--2020 Krishna Myneni
\
(
  Supported Control Sequences:

    \bf           switch to bold weight in current font
    \md             "      medium weight    "
    \it           switch to italic slant in current font
    \rg             "      regular slant    "
    \ob             "      oblique slant    "
    \10pt         switch to 10 point size in current font
    \12pt           "      12 point         "
    \14pt           "      14 point         "
    \18pt           "      18 point         "
    \24pt           "      24 point         "
    \color  name  set color of output; name is color name, e.g. "red"
    \fnt    name  set the font to the name of a type, fontspec
    \fnttab name  use new font table and keep other font characteristics
    \\            backslash character
    \             space character
    \_            subscript
    \^            superscript
    \br           force line break, i.e. newline in current font


  Use of Control Sequences:

  1.  One blank space is required *after* a control sequence,
      and this one space is ignored by DRAW-TEXT-CS, i.e. not
      output as part of the text. Thus, the string,

         s" A \bf line \md of text." 

      will be output as "A line of text." with specified font
      change, while the string,

         s" The atom is excited to a \it meta-\rg stable state."

      will be output as,
  
         "The atom is excited to a meta-stable state."
)

\ API Words:
\
\   get-start-pos-cs   ( -- x0 y0 )
\   get-fin-pos-cs     ( -- xf yf )
\   draw-text-cs       ( x1 y1 caddr u -- x2 y2 )
\
\ Requires:
\   strings.4th
\   utils.4th
\   libs/x11/libX11.4th
\   simple-graphics-x11.4th
\   simple-fonts-x11.4th
\

Module: cs-strings-x11

Also simple-graphics-x11
Also simple-fonts-x11

Begin-Module

variable x0      \ Start coordinates for draw-text-cs
variable y0

variable xf      \ Finish coordinates for draw-text-cs
variable yf

\ Control Sequences
18 constant nControls

s" \bf"
s" \md"
s" \it"
s" \rg"
s" \ob"
s" \10pt"
s" \12pt"
s" \14pt"
s" \18pt"
s" \24pt"
s" \color"
s" \fnt"
s" \fnttab"
s" \\"
s" \"
s" \_"
s" \^"
s" \br"
nControls 8 $table $controls

\ Table of execution vectors, associated with control codes.

\ All actions will have the following stack behavior:
\
\   x1 y1 caddr1 u1  --  x2 y2 caddr2 u2
\
\ where x1, y1 are the current coordinates at which the
\ output text is to be drawn, and caddr1 u1 is the string
\ following the corresponding control code.

:noname bold    change-font-weight ;        \ 0
:noname medium  change-font-weight ;        \ 1
:noname italic  change-font-slant  ;        \ 2
:noname regular change-font-slant  ;        \ 3
:noname oblique change-font-slant  ;        \ 4
:noname 100     change-font-pointsize ;     \ 5
:noname 120     change-font-pointsize ;     \ 6
:noname 140     change-font-pointsize ;     \ 7
:noname 180     change-font-pointsize ;     \ 8
:noname 240     change-font-pointsize ;     \ 9
:noname parse_token strpck find 
         IF >body @ foreground
         ELSE drop THEN ;                  \ 10
:noname parse_token strpck find
         IF >body font-spec@ select-font
         ELSE drop THEN ;                  \ 11
:noname parse_token strpck find 
         IF >body change-font-table
         ELSE drop THEN ;                  \ 12
:noname 2>r s" \" draw-text-xytrack 2r> ;  \ 13
:noname 2>r s"  " draw-text-xytrack 2r> ;  \ 14
:noname ;                                  \ 15
:noname ;                                  \ 16
:noname 2>r current-font-height + >r 
         drop x0 @ r> 2r> ;                \ 17
nControls table cs_actions

\ For the given control sequence string, lookup the specified
\ action and return its xt. Return zero if the control string
\ is not one of the known controls in the string table, 
\ $font_controls.
: lookup-cs ( caddr u -- xt|0 )
    nControls 0 DO
      2dup I $controls compare 0=
      IF  2drop cs_actions I cells + a@
          UNLOOP EXIT
      THEN
    LOOP
    2drop 0
;
 

: do-cs ( x1 y1 caddr0 u0 caddr1 u1 -- x2 y2 caddr2 u2 )
    2dup 2>r lookup-cs
    dup IF  execute  2r> 2drop 
    ELSE  drop ." Unknown font control: " 2r> type cr
    THEN
;

: parse-to-next-cs ( caddr0 u0 -- caddr0 u1 caddr2 u2 )
    2dup [char] \ scan 2dup 2>r nip - 2r> ;

Public:

: get-start-pos-cs ( -- x0 y0 ) x0 @ y0 @ ;
: get-fin-pos-cs   ( -- xf yf ) xf @ yf @ ;

: draw-text-cs ( x0 y0 caddr u -- xf yf )
    2over y0 ! x0 !       \ save output start position 
    BEGIN  dup  WHILE
      parse-to-next-cs 2>r
      dup IF  draw-text-xytrack  ELSE  2drop  THEN
      2r> 
      dup IF 
        parse_token   \ x1 y1 caddr1 u1 caddr2 u2
        do-cs
        dup IF 1 /string THEN  \ ignore one blank space after cs
      THEN
    REPEAT
    2drop
    2dup yf ! xf !
;


End-Module








