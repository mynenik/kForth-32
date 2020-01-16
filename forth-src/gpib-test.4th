\ gpib-test.4th
\
\ Test kForth interface to the linux-gpib driver using the HP multimeter
\
\ Revisions:
\   2011-09-14  km  updated to include modules.4th
\   2011-11-03  km  revised to use modular version of hp34401.4th

include ans-words
include modules
include strings
include struct
include struct-ext
include ioctl
include gpib
include daq/hp/hp34401.4th
: meter1 hp34401 ;

CR .( Opening GPIB driver ... )
   ∋ gpib open dup [IF] .( Error ) . [ELSE] drop .( ok ) [THEN]

CR .( Initializing GPIB interface ... )
   ∋ gpib init dup [IF] .( Error ) . [ELSE] drop .( ok ) [THEN]

CR .( Setting timeout ... )
  10000000 ∋ gpib ibtmo dup [IF] .( Error )  . [ELSE] drop .( ok ) [THEN]
CR   
CR .( Sending CLEAR DEVICE to meter at ADRESS ) ∋ meter1 get-pad . ∋ meter1 clear
CR .( Reading meter: result = ) ∋ meter1 read  f.
CR .( Closing GPIB ) ∋ gpib close


