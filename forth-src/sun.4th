\ sun 05.08.11 NAB
\ Sunrise/sunset calculations.
\
\ This is the kForth32 port of Neal Bridges' sunrise/sunset
\ calculator for Quartus Forth --  Krishna Myneni 2005-08-20
\
\ Usage:
\
\    rlongitude rlatitude      SET-LOCATION
\    tzoffset_hr tzoffset_min  SET-TIMEZONE
\    OFFICIAL-ZENITH
\
\    dd mm yyyy SUNRISE TIME>MH . . 
\    dd mm yyyy SUNSET  TIME>MH . .
\
\ Revisions:
\   2005-08-20 km first port of Neal Bridges' code [1].
\   2019-01-26 km fix roundoff error in TIME>MH;
\     added TIMEZONE SET-TIMEZONE LOCAL-OFFSET-HR
\     UTC>LOCAL_STANDARD ; provide predefined timezones
\     UTC-12:00 ... ;
\
\ Requires:
\   ans-words.4th  (kForth32 only)
\   jd.4th
\
\ Notes: 
\
\   1. All times are Standard Times for the specified timezone.
\      Times are on a 24-hour clock. This version does not perform
\      daylight savings time (DST) correction. 
\
\   1. This version uses Wil Baden's Julian Day calculator (jd.4th).
\
\   2. Compatible with ANS Forth standard.
\
\ References:
\   1. Original code and documentation may be found in 
\      http://quartus.net/files/PalmOS/Forth/Examples/sun.zip

\ Definitions for JD ?ALLOT FTUCK F>S FROUND>S
[UNDEFINED] JD [IF] s" jd.4th" included [THEN]
[UNDEFINED] ?ALLOT [IF] : ?allot here swap allot ; [THEN]
[UNDEFINED] FTUCK [IF] 
: ftuck ( ra rb -- rb ra rb )  fswap fover ;
[THEN]
[UNDEFINED] F>S [IF] : f>s ( r -- n )  f>d d>s ; [THEN]
[UNDEFINED] FROUND>S [IF]
: fround>s ( r -- n ) fround f>d d>s ;
[THEN]

\ Calendar months
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

\ Defining word for timezone
: timezone ( hh mm <name> -- ) 2constant ;

\ Predefined timezones
-12 00 timezone UTC-12:00
-11 00 timezone UTC-11:00
-10 00 timezone UTC-10:00
 -9 30 timezone UTC-09:30
 -9 00 timezone UTC-09:00
 -8 00 timezone UTC-08:00
 -7 00 timezone UTC-07:00
 -6 00 timezone UTC-06:00
 -5 00 timezone UTC-05:00
 -4 00 timezone UTC-04:00
 -3 30 timezone UTC-03:30
 -3 00 timezone UTC-03:00
 -2 00 timezone UTC-02:00
 -1 00 timezone UTC-01:00
  0 00 timezone UTC+00:00
  1 00 timezone UTC+01:00
  2 00 timezone UTC+02:00
  3 00 timezone UTC+03:00
  3 30 timezone UTC+03:30
  4 00 timezone UTC+04:00
  4 30 timezone UTC+04:30
  5 00 timezone UTC+05:00
  5 30 timezone UTC+05:30
  5 45 timezone UTC+05:45
  6 00 timezone UTC+06:00
  6 30 timezone UTC+06:30
  7 00 timezone UTC+07:00
  8 00 timezone UTC+08:00
  8 45 timezone UTC+08:45
  9 00 timezone UTC+09:00
  9 30 timezone UTC+09:30
 10 00 timezone UTC+10:00
 10 30 timezone UTC+10:30
 11 00 timezone UTC+11:00
 12 00 timezone UTC+12:00
 12 45 timezone UTC+12:45
 13 00 timezone UTC+13:00
 14 00 timezone UTC+14:00

UTC+00:00 timezone DEFAULT_TIMEZONE

\ Versions of the trig functions for argument in degrees
: fsind   ( r1 -- r2 ) deg>rad fsin ;
: fcosd   ( r1 -- r2 ) deg>rad fcos ;
: ftand   ( r1 -- r2 ) deg>rad ftan ;

\ Versions of inverse trig functions for result in degrees
: fasind  ( r1 -- r2 ) fasin rad>deg ;
: facosd  ( r1 -- r2 ) facos rad>deg ;
: fatand  ( r1 -- r2 ) fatan rad>deg ;

\ Adjust hours so the range is [0,24)
: range24 ( r1 -- r2 )
  fdup  24e f> IF  24e f-  THEN
  fdup  f0<    IF  24e f+  THEN ;

\ Adjust angle in degrees so the range is [0,360)
: range360 ( r1 -- r2 )
    fdup f0< IF  360e f+
    ELSE
      fdup 360e f> IF
        360e f-  
      THEN
    THEN ;

\ Round down to the nearest multiple of 90.
: floor90 ( r1 -- r2 )
    90e ftuck f/ floor f* ;

\ Return Julian day for specified date.
: dmy>date ( d m y -- jday ) jd ;

\ Calculate the day-of-year number of a given date (January 1=day 1).
: day-of-year ( d m y -- day )
    dup >r  dmy>date
    1 January r> dmy>date - 1+ ;

\ Convert decimal hours time into integer minutes and hours.
: time>mh ( rh -- min hour )
    fdup floor  fover  f- fnegate
    60e f* fround>s  
    >r floor f>s r> swap ;

\ Local latitude and longitude
\ (west and south are negative, east and north are positive):
fvariable latitude
fvariable longitude

\ timezone
2variable tzone

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

: set-location ( rlong rlat -- )
  latitude f!  longitude f! ;

: set-timezone ( tzoffset_hr tzoffset_min -- ) tzone  2! ;

DEFAULT_TIMEZONE set-timezone

: set-zenith   ( rzenith -- )   zenith f! ;

\ Builds zenith-setting word.
: zenith: ( r -- )
  create  ( here f!)  1 dfloats ?allot f!
  does> ( -- )  f@ set-zenith ;

90.83333e  zenith:  official-zenith
    96.0e  zenith:  civil-zenith
   102.0e  zenith:  nautical-zenith
   108.0e  zenith:  astronomical-zenith

false constant rising
true constant setting

\ Calculate the UTC sunrise or sunset time for a given day of the year,
\  using the location set in the longitude and latitude fvariables.
\  Returned time is in decimal hours.
: UTC-suntime  ( d m y set? -- rh )
  >r  \ preserve rise/set value
  day-of-year  0 d>f  T f!
  longitude f@ 15e f/ lngHour f!             \ lngHour = longitude/15  
  r@ rising = IF
    18e lngHour f@ f- 24e f/ T f@ f+ T f!    \ T = T + ((18-lngHour)/24)
  ELSE \ setting
    6e lngHour f@ f- 24e f/ T f@ f+ T f!     \ T = T + ((6-lngHour)/24)
  THEN
  0.9856e T f@ f* 3.289e f- M f!             \ M = 0.9856*T - 3.289

\  L = range360( M + 1.916*sin(M) + 0.020*sin(2*M) + 282.634 )
  M f@ 2e f* fsind 0.020e f* M f@ fsind 1.916e f* f+ M f@ f+ 282.634e f+
  range360 L f!

\ RA = range360( atan( 0.91764*tan(L) ) )
  L f@ ftand 0.91764e f* fatand range360 RA f!

\ RA = (RA + (floor90(L)-floor90(RA)) ) / 15
  L f@ floor90 RA f@ floor90 f- RA f@ f+ 15e f/ RA f!
 
  L f@ fsind 0.39782e f* sinDec f!      \ sinDec = 0.39782*sin(L)
  sinDec f@ fasind fcosd cosDec f!      \ cosDec = cos(asin(sinDec))

\ cosH = (cos(zenith) - (sinDec*sin(latitude))) / (cosDec*cos(latitude))
  zenith f@ fcosd latitude f@ fsind sinDec f@ f* f-
  latitude f@ fcosd cosDec f@ f* f/ cosH f! 

  cosH f@ fabs 1e f> ABORT" Fatal Error"   \  abs(cosH): 1e f> -11 and  throw
  cosH f@ facosd 15e f/ H f!               \  H = acos(cosH)/15
  r> rising = IF
    24e H f@ f- H f!                       \ H = 24 - H
  THEN

\ H + RA - 0.06571*T - 6.622 - lngHour
  H f@ RA f@ f+ 0.06571e T f@ f* f- 6.622e f- lngHour f@ f- 
;

\ Return local standard time offset from UTC in decimal hours
\ based on the timezone (configured by SET-TIMEZONE)
: local-offset-hr ( -- rhoffset )
    tzone 2@ >r s>f r> s>f 60e f/ f+ ;

: UTC>local_standard ( rh1 -- rh2 )
    local-offset-hr f+ range24 ;

\ Return sunrise or sunset time in local standard time
\ for the specified date (local timezone must be specified
\ using SET-TIMEZONE prior)
: local-suntime  ( d m y set? -- rh )
    UTC-suntime
    UTC>local_standard
;

: sunrise ( d m y -- rh )
  rising local-suntime ;

: sunset ( d m y -- rh )
  setting local-suntime ;

\ Test code
0 [IF]
[UNDEFINED] T{ [IF] s" ttester.4th" included [THEN]

TESTING RANGE360 FLOOR90 DAY-OF-YEAR TIME>MH
t{ 383e range360 f>s -> 23 }t
t{ -17e range360 f>s -> 343 }t
t{  97e floor90  f>s -> 90 }t
t{ 20 July 1984 day-of-year -> 202 }t
t{ 3.5e time>mh -> 30 3 }t

TESTING SET-LOCATION OFFICIAL-ZENITH UTC-SUNTIME
\ Sunrise and sunset in UTC for Toronto, Canada ( 43.6N 79.4W )
t{ -79.4e 43.6e set-location -> }t
t{  official-zenith -> }t
t{  20 July 1989 rising  UTC-suntime time>mh -> 55 9 }t
t{  20 July 1989 setting UTC-suntime time>mh -> 53 0 }t

TESTING SET-TIMEZONE SUNRISE SUNSET
\ Sunrise and sunset in local standard time for Toronto
t{ UTC-05:00 set-timezone -> }t
t{ 20 July 1989 sunrise time>mh -> 55  4 }t
t{ 20 July 1989 sunset  time>mh -> 53 19 }t

[THEN]


