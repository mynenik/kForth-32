\ keycal.4th
\
\ Measure keyboard event response time for your system.
\
\ This program measures the average time between the press of a
\ key and when it is processed by the system. There will be
\ a significant non-zero delay due to processor interrupts, 
\ thread priorities, and other operating system factors.
\
\ Copyright (c) 2003 Krishna Myneni
\ Provided under the GNU General Public License
\
\ Revisions:
\
\	2003-3-2  created  km
\

500 constant MAXWAIT	\ maximum response time in milliseconds

variable niter
variable keepwaiting
variable kbresp

: cal
	begin  key?  until    key drop	\ wait for key press
	0 niter !
	true keepwaiting !

	0
	begin
	  ms@
	  begin key? 0= keepwaiting @ and 
	  while ms@ over - MAXWAIT > if false keepwaiting ! then
	  repeat
	  keepwaiting @
	while
	  key drop ms@ swap - +
	  1 niter +!
	repeat
	drop  cr
	niter @ dup if / dup kbresp ! 
	  ." Average keyboard response time was " . ." ms" cr
	  ." Number of events = " niter @ . cr
	else
	  2drop ." No data" cr
	then 
;

cr cr
.(   Hold down the spacebar for about 30 seconds and release it ) cr
.(   to calibrate the average interruption time for reading a ) cr
.(   keyboard event on your system. Type 'cal' to repeat. ) cr cr
	  
cal

