\ sun 05.08.11 NAB
\ Sunrise/sunset calculations.
\
\ This is the kForth port of Neal Bridges' sunrise/sunset calculator
\   for Quartus Forth.  K. Myneni 2005-08-20
\
\ -- Original code and documentation may be found in 
\      http://quartus.net/files/PalmOS/Forth/Examples/sun.zip
\
\ -- This version uses Wil Baden's Julian Day calculator (jd.4th).
\
\ -- Modified for Forths without separate fp stack. For Forths with separate
\      fp stack, modify the word TIME>MH
\
\ -- local sunrise and sunset words require that the local offset be hardcoded
\      in the word local-offset.
\
\ -- For use with standard ANS Forth, uncomment line below:
\ : ?allot here swap allot ;

 1  constant  January
 2  constant  February
 3  constant  March
 4  constant  April
 5  constant  May
 6  constant  June
 7  constant  July
 8  constant  August
 9  constant  September
10  constant  October
11  constant  November
12  constant  December

include jd

\ ======== kForth compatibility ===========
: d>s drop ;
\ ======= end kForth compatibility ========


\ Local latitude and longitude
\ (west and south are negative, east and north are positive):
fvariable latitude
fvariable longitude

\ Sun's zenith for sunrise/sunset:
fvariable zenith

\ Other working variables:
fvariable lngHour
fvariable T
fvariable L
fvariable M
fvariable RA
fvariable sinDec
fvariable cosDec
fvariable cosH
fvariable H


: set-location ( long lat -- )
  latitude f!  longitude f! ;

: set-zenith ( zenith -- )  zenith f! ;


: zenith: ( f -- )
\ Builds zenith-setting words.
  create  ( here f!)  1 dfloats ?allot f!
  does> ( -- )  f@ set-zenith ;


90.83333e  zenith:  official-zenith
      96e  zenith:  civil-zenith
     102e  zenith:  nautical-zenith
     108e  zenith:  astronomical-zenith

: day-of-year ( d m y -- day )
\ Calculate the day-of-year number of a given date (January 1=day 1).
  dup >r  ( dmy>date) jd
  1 January r> ( dmy>date) jd - 1+ ;

\ { 20 July 1984 day-of-year -> 202 } 

\ Floating-point helper words:
: ftuck ( a b -- b a b )  fswap fover ;
: f>s ( f -- n )  f>d d>s ;

: range360 ( f1 -- f2 )
\ Adjust so the range is [0,360).
  fdup f0< if  360e f+
  else  fdup 360e f> if  360e f-  then
  then ;

\ { 383e range360 f>s -> 23 }
\ { -17e range360 f>s -> 343 }

: floor90 ( f1 -- f2 )
\ Round down to the nearest multiple of 90.
  90e ftuck f/ floor f* ;

\ { 97e floor90 f>s -> 90 }

: time>mh ( h.m -- min hour )
\ Convert a floating-point h.m time into integer minutes and hours.
  fdup floor  fover fswap  f-
  60e f*  f>s  >r floor  f>s r> swap ;   \ integrated stack Forth.
\  60e f*  f>s  floor  f>s ;              \ Separate fp stack.

\ { 3.5e time>mh -> 30 3 }

\ The algorithm works in degrees, so we need separate versions of the
\ trig functions that operate on degrees rather than radians:
: fsind  deg>rad fsin ;
: fcosd  deg>rad fcos ;
: ftand  deg>rad ftan ;
: fasind  fasin rad>deg ;
: facosd  facos rad>deg ;
: fatand  fatan rad>deg ;

false constant rising
true constant setting

: UTC-suntime  ( d m y set? -- h.m )
\ Calculate the UTC sunrise or sunset time for a given day of the year,
\  using the location set in the longitude and latitude fvariables.
  >r  \ preserve rise/set value
  day-of-year  0 d>f  T f!
  longitude f@ 15e f/ lngHour f!                 \ let lngHour=longitude/15:  
  r@ rising = if
    18e lngHour f@ f- 24e f/ T f@ f+ T f!        \ let T=T+((18-lngHour)/24):
  else \ setting
    6e lngHour f@ f- 24e f/ T f@ f+ T f!         \ let T=T+((6-lngHour)/24):
  then
  0.9856e T f@ f* 3.289e f- M f!                 \ let M=(0.9856*T)-3.289:

\  let L=range360(M+(1.916*sin(M))+(0.020*sin(2*M))+282.634):
  M f@ 2e f* fsind 0.020e f* M f@ fsind 1.916e f* f+ M f@ f+ 282.634e f+
  range360 L f!

\  let RA=range360(atan(0.91764*tan(L))):
  L f@ ftand 0.91764e f* fatand range360 RA f!

\  let RA=(RA+(floor90(L)-floor90(RA)))/15:
  L f@ floor90 RA f@ floor90 f- RA f@ f+ 15e f/ RA f!
 
  L f@ fsind 0.39782e f* sinDec f!                \ let sinDec=0.39782*sin(L):
  sinDec f@ fasind fcosd cosDec f!                \ let cosDec=cos(asin(sinDec)):

\  let cosH=(cos(zenith)-(sinDec*sin(latitude)))/(cosDec*cos(latitude)):
  zenith f@ fcosd latitude f@ fsind sinDec f@ f* f-
  latitude f@ fcosd cosDec f@ f* f/ cosH f! 


  cosH f@ fabs 1e f> ABORT" Fatal Error"   \  let abs(cosH): 1e f> -11 and  throw
  cosH f@ facosd 15e f/ H f!               \  let H=acos(cosH)/15:
  r> rising = if  24e H f@ f- H f! ( let H=24-H:)  then

\ let H+RA-(0.06571*T)-6.622 -lngHour:
  H f@ RA f@ f+ 0.06571e T f@ f* f- 6.622e f- lngHour f@ f- 
;

\ {  \ Toronto, Canada: 43.6N 79.4W
\    -79.4e 43.6e set-location
\    official-zenith
\    20 July 1989 setting UTC-suntime
\    time>mh -> 53 0 }
\ { 20 July 1989 rising UTC-suntime
\    time>mh -> 54 9 }


\ : local-offset ( -- local-offset. )
\ \ Return the total offset in minutes
\ \  of the timezone and DST settings.
\ \ Requires PalmOS 4 and above.
\  PrefTimeZone >byte
\  PrefGetPreference
\  PrefDaylightSavingAdjustment
\  >byte  PrefGetPreference  d+ ;

: local-offset ( -- d | hardcode local offset in minutes here for your location )
     0 s>d ;

: range24 ( f1 -- f2 )
\ Adjust so the range is [0,24):
  fdup  24e f> if  24e f-  then
  fdup  f0< if  24e f+  then ;

: local-suntime  ( d m y set? -- h.m )
\ Calculate sunrise or sunset time
\  for the specified date, adjusting
\  for the local timezone & DST.
  UTC-suntime
\ Convert UTC value to local time:
  local-offset d>f 60e f/ f+ range24 ;


: sunrise ( d m y -- h.m )
  rising local-suntime ;
: sunset ( d m y -- h.m )
  setting local-suntime ;

