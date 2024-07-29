\ libX11.4th
\
\ Load bindings for the X Windows Xlib Library
\
1 CELLS 8 = [IF]
  s" libs/x11/libX11_x86_64.4th" included
[ELSE]
  s" libs/x11/libX11_x86.4th" included
[THEN]

