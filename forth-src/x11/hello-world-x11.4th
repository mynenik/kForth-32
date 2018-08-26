\ hello-world-x11.4th
\
\ The Hello-World program in the simple-frames presentation
\ framework.
\
\
include ans-words
include modules
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


: frame1 ( -- )  10 s" Hello World!" place-centered-text ;

' frame1
1 set-frames
start-frames
