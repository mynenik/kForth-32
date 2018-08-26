\ signed-include.4th
\
\ Utility words for loading PGP-signed Forth source
\ code.
\
\ Krishna Myneni, public key fingerprint:
\   660c 9cdb 9bb7 2d95 dfe3 a3ba aeaf 69b7 c4e2 3145
\
\ Last Revised: 22 August 2018
\
\ Requires:
\    strings.4th
\
\ Provides:
\
\    check-pgp-signature ( a u -- b )
\    -----BEGIN          ( <text> -- )
\    signed-included     ( a u -- )
\    include-signed      ( <filename> -- )
\
\ Notes:
\
\ 0. The assumption made about PGP-signed Forth source
\    files is that they have been "clearsigned", e.g.
\
\       $ gpg --clearsign filename
\
\ 1. If you want to load a PGP-signed Forth source
\    file without doing signature validation, simply use
\    INCLUDED or INCLUDE with the signed file in the
\    usual way. The PGP headers will be ignored.
\ 
\ 2. For ANS-Forths, please provide the following equivalent
\    words:
\
\    strcat ( a1 u1 a2 u2 -- a3 u3 | concatenate strings )
\    strpck ( a u -- ^str | string to counted string )
\    system ( ^str -- n | shell command with return code )
\
\    A port of strings.4th to ANS Forth is available to
\    provide STRCAT and STRPCK, but SYSTEM or equivalent
\    must be available in your Forth system, as well as
\    gpg or equivalent command line PGP tool.

10 constant EOL
 
\ For the filename specified by the string, check
\ its PGP signature and return a flag: true if
\ signature is good, false if bad.
: check-pgp-signature ( a u -- b )
	s" gpg --verify " 2swap strcat strpck system 0= ;

: -----BEGIN ( <text> -- )
    EOL parse
    2dup 
    s" PGP SIGNED MESSAGE-----" compare 0= if
      2drop refill if  EOL parse 2drop  then
    else
      s" PGP SIGNATURE-----" compare 0= if
        begin
	  refill if
            EOL parse
            s" -----END PGP SIGNATURE-----"
            compare 0=
	  else true then
        until
      else
	2drop
      then 
    then ;	
	   
\ version of INCLUDED for a PGP-signed file
: signed-included ( a u -- )
    2dup check-pgp-signature IF
      included
    else
      type ."  has an invalid signature!" cr
      abort
    then ;

\ version of INCLUDE for a PGP-signed file
: signed-include ( <filename> -- )
    bl parse signed-included ;

