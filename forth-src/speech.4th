\ speech.4th
\
\ Interface to the "festival" text to speech synthesis program
\
\ See http://www.cstr.ed.ac.uk/projects/festival/
\
\ Copyright (c) 2002 Krishna Myneni, Creative Consulting
\   for Research and Education
\
\ The executable, or a link to the executable, festival must
\ be in the PATH.
\
\ Requires:
\	strings.4th
\	files.4th  (2002-09-19 version or later)
\	utils.4th
\
\ Revisions:
\
\	2002-09-09  created  KM
\	2002-09-20  added say-again  KM
\	2002-09-22  modified SAY to delete MSGFILE  KM

s" speechmsg.txt" $constant MSGFILE

: say-file ( a u -- | read the file with the given name)
	s" festival --tts " 2swap strcat shell drop ;

: say ( a u -- | speak the message in the buffer )
        MSGFILE delete-file drop
	MSGFILE  W/O  create-file
	abort" Unable to open speech output file."
	dup >r write-file drop r> close-file drop
	MSGFILE  say-file ;

: say-again ( -- )
        MSGFILE say-file ;
