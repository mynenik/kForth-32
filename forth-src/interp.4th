\ From - Thu Aug 22 08:20:00 2002
\ From: Chris Jakeman <cjakeman@bigfoot.com>
\ Newsgroups: comp.lang.forth
\ Subject: Linear Interpolation
\ Date: Thu, 22 Aug 2002 14:01:02 +0100
\
\ Looking through the Forth Code Index at
\ http://www.fig-uk.org/codeindex, I found several in the arithmetic
\ section on interpolating data from tables.
\
\ Brad Eckert has published a version which uses a minimum of memory
\ "High accuracy look-up using cubic interpolation"
\ (http://www.tinyboot.com/cubic.txt) and also "Simple look-up using
\ linear interpolation" (http://www.tinyboot.com/linear.txt).
\
\ I was surprised at how complex this linear interpolation was, with 35
\ words and lots of double arithmetic. Brad has given us a solution for
\ minimum memory; linear interpolation should be aimed at maximum speed.
\
\ Here is a solution aimed at maximum speed. Following Wil Baden's
\ example, I am posting it here hoping for critical feedback or a
\ pointer to some better solution I have missed.
\
\ Thanks in advance,
\
\ Chris


\ LINEAR INTERPOLATION - Chris Jakeman, 2002-08-22, ANS Forth

\ ==== kForth notes =============
\ This version is adapted for kForth. The word "interp_table" has
\ been added and "Entry," has been modified. Another test word
\ "try2" has also been added for comparing the interpolation
\ table calculation against a floating-point sine calculation.
\ -- K. Myneni 2003/11/05
\
\ Requires: ans-words.4th
\ ================================

\ The table contains pairs of data for each point, the Y distance to
\ the next point followed by the Y value of the current point. This
\ reduces the calculation needed at run-time.

\ >XStep< - X distance between entries in table
\ XBase   - X value at start of table
\ XIndex  - No of entries into the table
\ XOffset - X distance beyond entry XIndex

2 cells constant >Entry<                  \ Size of table entry

\ Create an interpolation table 
: interp_table ( xstep xbase xmax xmin "name" -- addr )
    2dup 2>r - >r over dup 0= abort" Step size of 0 not allowed" 
    r> swap / 1+ 2* 4 + cells create allot? 2r>
    rot >r
    swap r@ 2 cells + 2!		    
    swap r@ 2!
    r> 4 cells + 
;   
\ Word to build a table entry conveniently
: Entry, ( addr Prev Next -- addr2 Next )
    rot >r
    swap 2dup -  ( -- Next Prev Next-Prev )
    ( , ,) r@ ! r@ cell+ ! r> 2 cells + swap 
;
\ Find the entry in the table representing value <= X
: InterpolateFind ( X &Table -- &Table XIndex XOffset >XStep< )
   dup 2@ >r   \ Stash >XStep<            ( -- X &Table XBase )
   rot swap -  \ Get XDistance into table ( -- &Table X-XBase )
   r@ /mod     \ Calc index into table    ( -- &Table XOffset XIndex )
   2+          \ Increment past preamble ( -- &Table XOffset XIndex' )
   swap r>                        ( -- &Table XIndex XOffset >XStep< )
;
\ Do the arithmetic
: InterpolateScale ( &Table XIndex XOffset >XStep< -- Result )
   2>r
   >Entry< * + \ Get table entry          ( -- &Entry )
   2@ 2r>      \ Get scaling factors      ( -- YBase >YStep< XOffset >XStep< )
   */ +
;
: Interpolate ( X &Table -- Result )
   InterpolateFind
   InterpolateScale
;
: SafeInterpolate ( X &Table -- Result )
   2dup >Entry< + 2@ within 0= abort" Outside range of look-up table"
   Interpolate
;

\ Sample table for 10,000*Sin(X)
\ Preamble
 15  0	      \ >XStep<  XBase 
 90  0	      \ max and min limits of X
interp_table SinTable
\ Data points
\   Y            X     
 0000         \  0
 2588  Entry, \ 15
 5000  Entry, \ 30
 7071  Entry, \ 45
 8660  Entry, \ 60
 9659  Entry, \ 75
10000  Entry, \ 90
2drop

: try 
   80 SinTable SafeInterpolate ." 9772=" .
;

\ Compare interpolated values with floating point sine curve calculation
: try2
    90 0 do 
      i 2 .r 2 spaces i SinTable Interpolate 6 .r 2 spaces 
      i s>f deg>rad fsin 10000e f* fround>s  6 .r cr 
    loop
;

