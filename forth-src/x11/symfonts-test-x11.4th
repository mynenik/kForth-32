\ symfonts-test-x11.4th
\
\ Test use of the Symbol fonts in the simple-frames-x11
\ presentation framework.
\
\ K. Myneni, 2012-05-01
\

include ans-words
include modules
include syscalls
include mc
include asm
include strings
include lib-interface
include libs/x11/libX11
include x11/font-strings-x11
include x11/simple-graphics-x11
include x11/simple-fonts-x11
include x11/simple-typeset-x11
include x11/simple-frames-x11

Also font-strings-x11
Also simple-graphics-x11
Also simple-fonts-x11
Also simple-typeset-x11
Also simple-frames-x11

: frame1 
     medium regular 140 SymbolFonts select-font
     10 s" a^2 + b^2 = g^2" place-centered-text
;

' frame1
1 set-frames
start-frames

