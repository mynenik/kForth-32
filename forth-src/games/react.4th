\ react.4th
\
\ Measure your eye-hand reaction time.
\
\ Copyright (c) 2002--2003  Krishna Myneni, Creative Consulting for
\   Research and Education
\
\ Provided under the GNU General Public License
\
\ Revisions:
\
\	2002	-- created  km
\	2003-3-2 -- updated with mini-oof and key event response time km
\
\ Notes:
\
\ 1) For use under Windows, make the following changes:
\
\	a) change "include files" to "include filesw". If filesw.4th
\	   fails to load, you may need to obtain the latest version
\	   of this file at http://ccreweb.org/software/kforth/kforth4.html
\
\	b) Comment out "include speech". Also, comment out
\	   the first definition of MESSAGE and uncomment
\	   the no-speech definition of MESSAGE.
\
\ 2) I find my reaction time to be slightly improved if the console 
\    window background is black.
\
\ 3) Human reaction time is around 220 milliseconds or so. There are 
\    a number of web pages dealing with this topic, and, not being an 
\    expert on the subject, I will not recommend a particular one.

include strings
include ansi
include files	\ or filesw under Windows
include matrix
include stats
include ans-words
include utils
include mini-oof

\ Comment the include statement below if your system does not 
\    have the Festival speech to text program. Also use the
\    appropriate definition of MESSAGE.
 
include speech	   
: message ( a u -- ) 2dup type say cr ;
\ : message ( a u -- ) type cr ;

s" DISCLAIMER: This program is for ENTERTAINMENT PURPOSES ONLY! "
s" No claim is made as to the accuracy of this program. It should NOT " strcat 
s" be used as a basis for deciding your fitness to drive a motor " strcat
s" vehicle, operate heavy machinery, or to balance your check book." strcat
message

CR

\ We must calibrate the systematic error due to the
\ keyboard event response time.

s" First we must calibrate the average time for your system to " 
s" respond to a key event. Press and hold down the space bar " strcat
s" for about 30 seconds and then release it." strcat
message

include keycal

s" The average key response time on your system is "
kbresp @ s>string count strcat
s"  milli-seconds. This value will be subtracted from your " strcat
s"  reaction time measurements." strcat
message

page

27 constant PATTERN_WIDTH
 7 constant PATTERN_HEIGHT
1 cells constant cell

object class
       PATTERN_WIDTH PATTERN_HEIGHT * var pa-text
       cell var pa-fg		    \ foreground color
       cell var pa-bg		    \ background color
       method   pa-init
       method   pa-draw
       method   pa-setcolors
end-class pattern

: noname ( ... o -- )
    PATTERN_HEIGHT 0 ?do 
      nip dup pa-text i PATTERN_WIDTH * + rot swap PATTERN_WIDTH cmove
    loop drop ;

' noname pattern defines pa-init

: noname ( col row o -- )
    PATTERN_HEIGHT 0 ?do
      -rot 2dup i + at-xy rot
      dup pa-text i PATTERN_WIDTH * + PATTERN_WIDTH type
    loop
    drop 2drop ;

' noname pattern defines pa-draw
  
pattern new cross
S"              *             "
S"              *             "
S"              *             "
S"        *************       "
S"              *             "
S"              *             "
S"              *             "
cross pa-init

pattern new diagonal-cross
S"        *           *       "
S"          *       *         "
S"            *   *           "
S"              *             "
S"            *   *           "
S"          *       *         "
S"        *           *       "
diagonal-cross pa-init

pattern new diamond
S"              *             "
S"            *   *           "
S"          *       *         "
S"        *           *       "
S"          *       *         "
S"            *   *           "
S"              *             "
diamond pa-init

pattern new square
S"        *************       "
S"        *           *       "
S"        *           *       "
S"        *           *       "
S"        *           *       "
S"        *           *       "
S"        *************       "
square pa-init

4 table patterns
variable npatterns
4 npatterns !
       

: help
	s" I will begin the test after a short pause. "
	s" When you see the pattern on the screen change, press the " strcat
	s" space bar. We will repeat this several times, with a random " strcat
	s" pause each time. At the end of the test I will " strcat
	s" tell you your reaction time." strcat message
	1000 ms cr cr
;

\ Pseudo-random number generation
variable last-rn
time&date 2drop 2drop drop last-rn !  \ seed the rng

: lcrng ( -- n ) last-rn @ 31415928 * 2171828 + 31415927 mod dup last-rn ! ;

: next_ran ( -- n | random number from 0 to 255 )
	0 8 0 do 1 lshift lcrng 1 and or loop ;

: choose ( n -- n' | arbitrarily choose a number between 0 and n-1)
 	dup next_ran * 255 / swap 1- min ;


variable last_color
0 last_color !

variable last_pattern
0 last_pattern !

: check-mark ( -- | place a mark on pattern to indicate user has hit key)
	0 0 at-xy
	."        " cr
	."     /  " cr
	."    /   " cr
	." \ /    " cr
	."  V     " cr
;

20 constant NTRIALS

: go
	s" Get ready to begin ..." message
	1500 ms  \ initial delay allows user to get ready
	NTRIALS 0 do
	  \ pause between 500 to 2500 milli-seconds
	  2000 choose 500 + ms
	  begin key? while key drop repeat  \ flush any kbd input during pause
	  begin 8 choose dup last_color @ = while drop repeat \ choose next col
	  dup last_color !
	  dup background 
	  BLACK = if WHITE else BLACK then foreground
	  ( page) ms@
	  begin npatterns @ choose dup last_pattern @ = while drop repeat
	  dup last_pattern !
	  cells patterns + a@ 0 0 rot pa-draw	  
	  begin key? until ms@
	  key 27 = if 
	    text_normal s" You stopped the test" message unloop exit 
	  then 
	  swap - kbresp @ - s>f
	  check-mark
	loop
	text_normal
	page
	NTRIALS variance fsqrt fround f>d d>s 
	mu f@
	fround f>d d>s s>string count s" Your average response time was "
	2swap strcat s"  milli-seconds" strcat message
	s>string count s" The standard deviation was " 2swap strcat
	s"  milli-seconds" strcat message cr
	s" You may repeat the test by typing 'go' " message ;



help
go

