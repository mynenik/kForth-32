\ typeset-test-x11.4th
\
\ Test simple-typeset-x11 words.
\
\ K. Myneni, 2012-05-04
\
\ Revisions:
\   2012-05-10  km  added frame2 to illustrate text typesetting
\                   within entire window width with margins; also
\                   illustrate changing one font characteristic
\                   with CHANGE-FONT-SLANT
\
\   2012-05-11  km  added frame3 to demonstrate output of
\                   strings containing more than one font.
\
\   2012-05-13  km  use FontSpec variables with \fnt control
\                   sequence, for changing fonts inside of strings.

include ans-words
include modules
include asm
include strings
include lib-interface
include libs/x11/libX11
include x11/font-strings-x11
include x11/simple-graphics-x11
include x11/simple-fonts-x11
include x11/cs-strings-x11
include x11/simple-typeset-x11
include x11/simple-frames-x11

Also font-strings-x11
Also simple-graphics-x11
Also simple-fonts-x11
Also cs-strings-x11
Also simple-typeset-x11
Also simple-frames-x11

variable box_w
variable box_h

: frame1 ( -- )  
    10 s" Centered text on line 10" place-centered-text

    s" Left aligned text " 
    2dup  2>r get-string-box  box_h !  box_w ! 
    10 50 box_w @ box_h @ draw-rectangle
    10 50 box_w @ 2r>   draw-hbox-wrapped-text

    grey foreground  1 1 set-line-type
    10 90 250 300 draw-rectangle
    black foreground
    10 90 250 
    s" Wrapped text in a box 250 pix wide, starting at 10,90. "
    s" The quick white fox jumped over the fence. " strcat
    s" His fleece was white as snow. " strcat
    s" And everywhere that Mary went, he was sure to go. " strcat
    s" It went to school one day. It made the children laugh. " strcat
    s" But, when the hound came to play, the fox went on his way." strcat
    draw-hbox-wrapped-text
;

\ Typeset text with half-inch margins in window
: frame2 ( -- )
   bold regular 240 TextFonts1 select-font
   1 s" Great Expectations" place-centered-text
   medium italic 140 TextFonts1 select-font
   3 s" Charles Dickens" place-centered-text
   regular change-font-slant
   s" My father's family name being Pirrip, and my Christian "
   s" name Philip, my infant tongue could make of both names " strcat
   s" nothing longer or more explicit than Pip. So, I called myself " strcat
   s" Pip, and came to be called Pip. I give Pirrip as my father's " strcat
   s" family name, on the authority of his tombstone and my sister,--Mrs. " strcat
   s" Joe Gargery, who married the blacksmith. As I never saw my father " strcat
   s" or my mother, and never saw any likeness of either of them (for their " strcat
   s" days were long before the days of photographs), my first fancies " strcat
   s" regarding what they were like were unreasonably derived from their " strcat
   s" tombstones. The shape of the letters on my father's, gave me an odd " strcat
   s" idea that he was a square, stout, dark man, with curly black hair. " strcat
   2>r
   get-resolution drop  \ xdpi
   2/ 1+ dup 2* >r      \ x for halfinch margin
   5 line>y get-window-size drop r> - 2r> draw-hbox-wrapped-text
;

nullFont  FontSpec  MathS
nullFont  FontSpec  MathT
nullFont  FontSpec  TextF

\ Demonstrate strings with control sequences
: frame3 ( -- )
    \ Set up the main fonts we will use
    medium regular 180 SymbolFonts MathS  font-spec!
    medium italic  180 TextFonts1  MathT  font-spec!
    medium regular 180 TextFonts1  TextF  font-spec!

    clear-window
    TextF font-spec@ select-font

    20 2 line>y 
    s" This is a \it multi-line \rg and \it multi-font \rg string!\br "
    s" We may use \bf bold text \md or \it italic text \rg within a line.\br " strcat
    s" And we may change the \14pt \bf point size \18pt \md to make " strcat
    s" \14pt \bf the text \12pt smaller and \10pt smaller.\18pt \md \br " strcat
    s" Making the text \24pt larger \18pt gets attention!\br " strcat
    s" \color red We \color green can \color blue get \color magenta \it crazy \rg " strcat
    s" \color yellow \bf with \md \color cyan our \color brown options\color black !"
    strcat draw-text-cs 2drop
(    
    20 8 line>y 
    s" The relation between \it frequency\rg , \fnt MathS n, "
    s" \fnt TextF and \it wavelength\rg , \fnt MathS l,\fnt TextF \ is " strcat 
    draw-text-cs 2drop

    get-window-size drop 2/ 10 line>y
    s" \fnt MathS n = \fnt MathT c/\fnt MathS l"  draw-text-cs 2drop   
)
;

' frame1 ' frame2 ' frame3
3 set-frames
start-frames
