\ This file is generated using LyX and Noweb -- Do Not Edit!
\ Please make modifications to the original file, literate-included.lyx
\ Version 1.1
\ Copyright (c) 2010--2011, Krishna Myneni
\ The software given here may be used for any purpose,
\   provided the copyright notice, above, is preserved.
[undefined] strcat [IF]  s" strings.fs" included  [THEN]
[undefined] 4dup   [IF] : 4dup  2over 2over ; [THEN]
[undefined] 4drop  [IF] : 4drop 2drop 2drop ; [THEN]

\ Search the string, $str, for the pattern, $pat. If found,
\ replace $pat with $rep, and return the new string, $new.

: replace ( $str $pat $rep -- $new )
    2>r        ( $str $pat ) ( r: $rep )
    4dup search
    if                 ( $str $pat $sub )   ( r: $rep )
      2rot 2over       ( $pat $sub $str $sub ) ( r: $rep )
      drop nip over -  ( $pat $sub $left ) ( r: $rep )
      2r> strcat       ( $pat $sub $left+$rep )
      2>r 2swap nip /string ( $right ) ( r: $left+$rep )
      2r> 2swap strcat ( $left+$rep+$right )
    else               ( $str $pat $sub )  ( r: $rep )
      4drop 2r> 2drop  ( $str )
    then ;

\ auto selection for those systems which identify themselves

[DEFINED] gforth   [IF] : shell ( caddr u -- retcode )  system $? ;     [THEN]
[DEFINED] bigforth [IF]
  also dos  : shell  strpck system ;  previous [THEN]
[DEFINED] vfxforth [IF]
  Extern: sys-command int system ( char * ); ( cmd -- r )
  : shell  strpck 1+ sys-command ; [THEN]

\ manual selection for other systems

[UNDEFINED] shell [IF]
  0 [IF] : shell ( caddr u -- retcode )  system $? ;                [THEN]  \ gforth (older version)
  1 [IF] : shell  strpck  system ;       [THEN]  \ kforth
  0 [IF] : shell  system  RETURNCODE @ ; [THEN]  \ iForth
  0 [IF] : shell  system ;               [THEN]  \ pfe
[THEN]

\ Extract the Forth source (.fs) from a Noweb (.nw) file.
\ Return the full .fs filename.

: untangle ( anw u1 afs u2 -- afs2 u3 )
    strpck count 2>r  strpck count 2r> 
        \ Execute a shell command to extract a Forth source file from a Noweb file
        ( anw u1  afs u2 ) 2>r
        s" notangle -R%f2.fs  %f1.nw  >  %f2.fs"
        s" %f2" 2r@  replace  s" %f1" 2rot replace  s" %f2" 2r@  replace
        shell 2r> rot ( afs u2 n ) abort" Unable to extract Forth source file!"
    s" .fs" strcat ;

\ INCLUDED for a Noweb file
: nw-included ( anw u1 asrc u2 -- ... )  untangle included ;
: lyx>nw ( alyx u1 -- anw u1 retcode )
        strpck count
        2dup s" .nw" strcat DELETE-FILE drop
        2dup ( afname u )
             s" lyx -e literate " 2swap strcat s" .lyx" strcat shell ( n ) ;

\ INCLUDED for a LyX (.lyx) file.
: lyx-included ( alyx u1 asrc u2 -- )
    strpck count 2>r
    lyx>nw  abort" Unable to convert a lyx file to a noweb file!"
    2r> nw-included
;
