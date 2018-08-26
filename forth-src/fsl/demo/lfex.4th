\ lfex.4th
\
\ Demonstrate use of polynomial fitting words to 
\ fit a straight line to data and determine the
\ slope and y-intercept
\
include ans-words
include fsl-util
include dynmem
include determ
include polyfit

\ Set up x and y arrays

8 constant NP

NP FLOAT array x{
101.6e 105.0e 113.4e 124.0e 128.3e 133.4e 138.0e 146.3e  NP x{ }fput

NP FLOAT array y{
699.6e 712.0e 740.8e 774.8e 792.0e 807.6e 825.2e 852.4e  NP y{ }fput

2 FLOAT array a{

x{ y{ a{ 1 NP polfit  fdrop

cr cr
.( Slope = )       a{ 1 } F@ F. cr
.( y-intercept = ) a{ 0 } F@ F. cr
