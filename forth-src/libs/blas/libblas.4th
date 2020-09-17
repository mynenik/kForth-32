\ libblas.4th
\
\ Interface to the Fortran BLAS shared object library
\
\ Krishna Myneni, krishna.myneni@ccreweb.org
\
\ Notes:
\
\  0. The BLAS library is not subject to copyright restrictions. 
\     This Forth file, which provides an interface to the library, 
\     from a suitably equipped Forth environment, may be modified 
\     and used for any purpose, provided the source is acknowledged, 
\     as follows:
\
\      Based on the kForth interface to the BLAS library,
\      libblas.4th, by Krishna Myneni.
\
\  1. The BLAS source may be downloaded from 
\         
\          http:netlib.org/
\
\     For use in kForth, this library must be built as a dynamically-
\     loadable (shared object), 32-bit library. The provided Makefile
\     in the source package only builds a static library, which may be
\     either 32-bit or 64-bit, depending on the platform. A modified
\     Makefile and make.inc file are available to build the 32-bit
\     shared object file, libblas.so, which is accessed by this 
\     interface. The necessary build tools, e.g. gfortran, etc. must be
\     installed on your system to build libblas.so.
\
\ 2.  
\     NOTE THAT ALL ARGUMENTS ARE BY REFERENCE, as required by
\     Fortran. Arguments should not be passed directly by value
\     on the Forth stack. A simpler interface, in which arguments
\     are passed by value on the Forth data/fp stack may be easily
\     implemented by storing values in holder variables and calling
\     the Forth words defined below.
\
\ 3.  Use the tester program, libblas-test.4th, to verify the
\     Forth interface to the BLAS subroutines (interface to functions
\     not yet implemented).
\
\ 4.  BLAS is a well-documented library, and is the basis for higher
\     level libraries such as LAPACK. However, numerical examples
\     for the individual BLAS functions appear to be hard to find.
\
\ Requires:
\
\  ans-words
\  modules.fs
\  syscalls
\  mc
\  asm
\  strings
\  lib-interface
\

[undefined] open-lib [if] s" lib-interface" included [then]

vocabulary BLAS
also BLAS definitions

0 value hndl_BLAS
s" libblas.so" open-lib
dup 0= [IF] check-lib-error [THEN]
to hndl_BLAS
cr .( Opened the BLAS library )

\ Level 1 BLAS
s" srotg"  F-word  srotg  ( asa asb asc ass -- )
s" srotmg" F-word  srotmg ( asd1 asd2 asx1 asy1 asparam -- )
s" srot"   F-word  srot   ( an asx aincx asy aincy ac as -- )
s" srotm"  F-word  srotm  ( an asx aincx asy aincy asparam -- )
s" sswap"  F-word  sswap  ( an asx aincx asy aincy -- )
s" sscal"  F-word  sscal  ( an asa asx aincx -- )
s" scopy"  F-word  scopy  ( an asx aincx asy aincy -- )
s" saxpy"  F-word  saxpy  ( an asa asx aincx asy aincy -- )
s" sdot"   F-word  sdot   ( an asx aincx asy aincy -- s )
s" sdsdot" F-word  sdsdot ( an asb asx aincx asy aincy -- s )
s" snrm2"  F-word  snrm2  ( an ax aincx -- s )
s" sasum"  F-word  sasum  ( an asx aincx -- s )
s" isamax" F-word  isamax ( an asx aincx -- n )

s" drotg"  F-word  drotg  ( ada adb ac as -- )
s" drotmg" F-word  drotmg ( add1 add2 adx1 ady1 adparam -- )
s" drot"   F-word  drot   ( an adx aincx ady aincy ac as -- )
s" drotm"  F-word  drotm  ( an adx aincx ady aincy adparam -- )
s" dswap"  F-word  dswap  ( an adx aincx ady aincy -- )
s" dscal"  F-word  dscal  ( an ada adx aincx -- )
s" dcopy"  F-word  dcopy  ( an adx aincx ady aincy -- )
s" daxpy"  F-word  daxpy  ( an ada adx aincx ady aincy -- )
s" ddot"   F-word  ddot   ( an adx aincx ady aincy -- r )
s" dnrm2"  F-word  dnrm2  ( an ax aincx -- r )
s" dasum"  F-word  dasum  ( an adx aincx -- r )
s" idamax" F-word  idamax ( an adx aincx -- n )

s" cswap"  F-word  cswap  ( an acx aincx acy aincy -- )
s" cscal"  F-word  cscal  ( an aca acx aincx -- )
s" csscal" F-word  csscal ( an asa acx aincx -- )
s" ccopy"  F-word  ccopy  ( an acx aincx acy aincy -- )
s" caxpy"  F-word  caxpy  ( an aca acx aincx acy aincy -- )
s" cdotu"  F-word  cdotu  ( an acx aincx acy aincy -- s s )
s" cdotc"  F-word  cdotc  ( an acx aincx acy aincy -- s s )

s" zswap"  F-word  zswap  ( an azx aincx azy aincy -- )
s" zscal"  F-word  zscal  ( an aza azx aincx -- )
s" zdscal" F-word  zdscal ( an ada azx aincx -- )
s" zcopy"  F-word  zcopy  ( an azx aincx azy aincy -- )
s" zaxpy"  F-word  zaxpy  ( an aza azx aincx azy aincy -- )
s" zdotu"  F-word  zdotu  ( an azx aincx azy aincy -- r r )
s" zdotc"  F-word  zdotc  ( an azx aincx azy aincy -- r r )

s" scnrm2" F-word  scnrm2 ( an ax aincx -- s )
s" dznrm2" F-word  dznrm2 ( an ax aincx -- r )
s" scasum" F-word  scasum ( an acx aincx -- s )
s" dzasum" F-word  dzasum ( an azx aincx -- r )
s" icamax" F-word  icamax ( an acx aincx -- n )
s" izamax" F-word  izamax ( an azx aincx -- n )

s" dsdot"  F-word  dsdot  ( an asx aincx asy aincy -- r )
cr .( loaded LEVEL 1 functions. )

\ Level 2 BLAS
s" sgemv"  F-word  sgemv  ( atrans am an aalpha aa alda ax aincx \
                            abeta ay aincy -- )
s" sgbmv"  F-word  sgbmv  ( atrans am an akl aku aalpha aa alda ax \
                            aincx abeta ay aincy -- )
s" ssymv"  F-word  ssymv  ( auplo an aalpha aa alda ax aincx abeta \
                            ay aincy -- )
s" ssbmv"  F-word  ssbmv  ( auplo an ak aalpha aa alda ax aincx \
                            abeta ay aincy -- )
s" sspmv"  F-word  sspmv  ( auplo an aalpha aap ax aincx abeta ay aincy -- )
s" strmv"  F-word  strmv  ( auplo atrans adiag an aa alda ax aincx -- )
s" stbmv"  F-word  stbmv  ( auplo atrans adiag an ak aa alda ax aincx -- )
s" stpmv"  F-word  stpmv  ( auplo atrans adiag an aap ax aincx -- )
s" strsv"  F-word  strsv  ( auplo atrans adiag an aa alda ax aincx -- )
s" stbsv"  F-word  stbsv  ( auplo atrans adiag an ak aa alda ax aincx -- )
s" stpsv"  F-word  stpsv  ( auplo atrans adiag an aap ax aincx -- )
s" sger"   F-word  sger   ( am an aalpha ax aincx ay aincy aa alda -- )
s" ssyr"   F-word  ssyr   ( auplo an aalpha ax aincx aa alda -- )
s" sspr"   F-word  sspr   ( auplo an aalpha ax aincx aap -- )
s" ssyr2"  F-word  ssyr2  ( auplo an aalpha ax aincx ay aincy aa alda -- )
s" sspr2"  F-word  sspr2  ( auplo an aalpha ax aincx ay aincy aap -- )

s" dgemv"  F-word  dgemv  ( atrans am an aalpha aa alda ax aincx abeta \
                            ay aincy -- )
s" dgbmv"  F-word  dgbmv  ( atrans am an akl aku aalpha aa alda ax aincx \
                            abeta ay aincy -- )
s" dsymv"  F-word  dsymv  ( auplo an aalpha aa alda ax aincx abeta ay \
                            aincy -- )
s" dsbmv"  F-word  dsbmv  ( auplo an ak aalpha aa alda ax aincx abeta ay \
                            aincy -- )
s" dspmv"  F-word  dspmv  ( auplo an aalpha aap ax aincx abeta ay aincy -- )
s" dtrmv"  F-word  dtrmv  ( auplo atrans adiag an aa alda ax aincx -- )
s" dtbmv"  F-word  dtbmv  ( auplo atrans adiag an ak aa alda ax aincx -- )
s" dtpmv"  F-word  dtpmv  ( auplo atrans adiag an aap ax aincx -- )
s" dtrsv"  F-word  dtrsv  ( auplo atrans adiag an aa alda ax aincx -- )
s" dtbsv"  F-word  dtbsv  ( auplo atrans adiag an ak aa alda ax aincx -- )
s" dtpsv"  F-word  dtpsv  ( auplo atrans adiag an aap ax aincx -- )
s" dger"   F-word  dger   ( am an aalpha ax aincx ay aincy aa alda -- )
s" dsyr"   F-word  dsyr   ( auplo an aalpha ax aincx aa alda -- )
s" dspr"   F-word  dspr   ( auplo an aalpha ax aincx aap -- )
s" dsyr2"  F-word  dsyr2  ( auplo an aalpha ax aincx ay aincy aa alda -- )
s" dspr2"  F-word  dspr2  ( auplo an aalpha ax aincx ay aincy aap -- )

s" cgemv"  F-word  cgemv  ( atrans am an aalpha aa alda ax aincx abeta \
                            ay aincy -- )
s" cgbmv"  F-word  cgbmv  ( atrans am an akl aku aalpha aa alda ax aincx \
                            abeta ay aincy -- )
s" chemv"  F-word  chemv  ( auplo an aalpha aa alda ax aincx abeta ay \
                            aincy -- )
s" chbmv"  F-word  chbmv  ( auplo an ak aalpha aa alda ax aincx abeta ay \
                            aincy -- )
s" chpmv"  F-word  chpmv  ( auplo an aalpha aap ax aincx abeta ay aincy -- )
s" ctrmv"  F-word  ctrmv  ( auplo atrans adiag an aa alda ax aincx -- )
s" ctbmv"  F-word  ctbmv  ( auplo atrans adiag an ak aa alda ax aincx -- )
s" ctpmv"  F-word  ctpmv  ( auplo atrans adiag an aap ax aincx -- )
s" ctrsv"  F-word  ctrsv  ( auplo atrans adiag an aa alda ax aincx -- )
s" ctbsv"  F-word  ctbsv  ( auplo atrans adiag an ak aa alda ax aincx -- )
s" ctpsv"  F-word  ctpsv  ( auplo atrans adiag an aap ax aincx -- )
s" cgeru"  F-word  cgeru  ( am an aalpha ax aincx ay aincy aa alda -- )
s" cgerc"  F-word  cgerc  ( am an aalpha ax aincx ay aincy aa alda -- )
s" cher"   F-word  cher   ( auplo an aalpha ax aincx aa alda -- )
s" chpr"   F-word  chpr   ( auplo an aalpha ax aincx aap -- )
s" cher2"  F-word  cher2  ( auplo an aalpha ax aincx ay aincy aa alda -- )
s" chpr2"  F-word  chpr2  ( auplo an aalpha ax aincx ay aincy aap -- )

s" zgemv"  F-word  zgemv  ( atrans am an aalpha aa alda ax aincx abeta \
                            ay aincy -- )
s" zgbmv"  F-word  zgbmv  ( atrans am an akl aku aalpha aa alda ax aincx \
                            abeta ay aincy -- )
s" zhemv"  F-word  zhemv  ( auplo an aalpha aa alda ax aincx abeta ay \
                            aincy -- )
s" zhbmv"  F-word  zhbmv  ( auplo an ak aalpha aa alda ax aincx abeta ay \
                            aincy -- )
s" zhpmv"  F-word  zhpmv  ( auplo an aalpha aap ax aincx abeta ay aincy -- )
s" ztrmv"  F-word  ztrmv  ( auplo atrans adiag an aa alda ax aincx -- )
s" ztbmv"  F-word  ztbmv  ( auplo atrans adiag an ak aa alda ax aincx -- )
s" ztpmv"  F-word  ztpmv  ( auplo atrans adiag an aap ax aincx -- )
s" ztrsv"  F-word  ztrsv  ( auplo atrans adiag an aa alda ax aincx -- )
s" ztbsv"  F-word  ztbsv  ( auplo atrans adiag an ak aa alda ax aincx -- )
s" ztpsv"  F-word  ztpsv  ( auplo atrans adiag an aap ax aincx -- )
s" zgeru"  F-word  zgeru  ( am an aalpha ax aincx ay aincy aa alda -- )
s" zgerc"  F-word  zgerc  ( am an aalpha ax aincx ay aincy aa alda -- )
s" zher"   F-word  zher   ( auplo an aalpha ax aincx aa alda -- )
s" zhpr"   F-word  zhpr   ( auplo an aalpha ax aincx aap -- )
s" zher2"  F-word  zher2  ( auplo an aalpha ax aincx ay aincy aa alda -- )
s" zhpr2"  F-word  zhpr2  ( auplo an aalpha ax aincx ay aincy aap -- )
cr .( loaded LEVEL 2 functions. )

\ Level 3 BLAS
s" sgemm"  F-word  sgemm  ( atransa atransb am an ak aalpha aa alda ab \
                            aldb abeta ac aldc -- )
s" ssymm"  F-word  ssymm  ( aside auplo am an aalpha aa alda ab aldb \
                            abeta ac aldc -- )
s" ssyrk"  F-word  ssyrk  ( auplo atrans an ak aalpha aa alda abeta ac \ 
                            aldc -- )
s" ssyr2k" F-word  ssyr2k ( auplo atrans an ak aalpha aa alda ab abeta \
                            ac aldc -- )
s" strmm"  F-word  strmm  ( aside auplo atransa adiag am an aalpha aa \
                            alda ab aldb -- )
s" strsm"  F-word  strsm  ( aside auplo atransa adiag am an aalpha aa \
                            alda ab aldb -- )

s" dgemm"  F-word  dgemm  ( atransa atransb am an ak aalpha aa alda ab \
                            aldb abeta ac aldc -- )
s" dsymm"  F-word  dsymm  ( aside auplo am an aalpha aa alda ab aldb \
                            abeta ac aldc -- )
s" dsyrk"  F-word  dsyrk  ( auplo atrans an ak aalpha aa alda abeta ac \
                            aldc -- )
s" dsyr2k" F-word  dsyr2k ( auplo atrans an ak aalpha aa alda ab aldb \
                            abeta ac aldc -- )
s" dtrmm"  F-word  dtrmm  ( aside auplo atransa adiag am an aalpha aa \
                            alda ab aldb -- )
s" dtrsm"  F-word  dtrsm  ( aside auplo atransa adiag am an aalpha aa \
                            alda ab aldb -- )

s" cgemm"  F-word  cgemm  ( atransa atransb am an ak aalpha aa alda ab \
                            aldb abeta ac aldc -- )
s" csymm"  F-word  csymm  ( aside auplo am an aalpha aa alda ab aldb abeta \
                            ac aldc -- )
s" chemm"  F-word  chemm  ( aside auplo am an aalpha aa alda ab aldb abeta \
                            ac aldc -- )
s" csyrk"  F-word  csyrk  ( auplo atrans an ak aalpha aa alda abeta ac \
                            aldc -- )
s" cherk"  F-word  cherk  ( auplo atrans an ak aalpha aa alda abeta ac \
                            aldc -- )
s" csyr2k" F-word  csyr2k ( auplo atrans an ak aalpha aa alda ab aldb \
                            abeta ac aldc -- )
s" cher2k" F-word  cher2k ( auplo atrans an ak aalpha aa alda ab aldb \
                            ac aldc -- )
s" ctrmm"  F-word  ctrmm  ( aside auplo atransa adiag am an aalpha aa \
                            alda ab aldb -- )
s" ctrsm"  F-word  ctrsm  ( aside auplo atransa adiag am an aalpha aa \
                            alda ab aldb -- )

s" zgemm"  F-word  zgemm  ( atransa atransb am an ak aalpha aa alda ab \
                            aldb abeta ac aldc -- )
s" zsymm"  F-word  zsymm  ( aside auplo am an aalpha aa alda ab aldb \
                            abeta ac aldc -- )
s" zhemm"  F-word  zhemm  ( aside auplo am an aalpha aa alda ab aldb \
                            abeta ac aldc -- )
s" zsyrk"  F-word  zsyrk  ( auplo atrans an ak aalpha aa alda abeta ac \
                            aldc -- )
s" zherk"  F-word  zherk  ( auplo atrans an ak aalpha aa alda abeta ac \
                            aldc -- )
s" zsyr2k" F-word  zsyr2k ( auplo atrans an ak aalpha aa alda ab aldb \
                            abeta ac aldc -- )
s" zher2k" F-word  zher2k ( auplo atrans an ak aalpha aa alda ab aldb \
                            abeta ac aldc -- )
s" ztrmm"  F-word  ztrmm  ( aside auplo atransa adiag am an aalpha aa \
                            alda ab aldb -- )
s" ztrsm"  F-word  ztrsm  ( aside auplo atransa adiag am an aalpha aa \
                            alda ab aldb -- )

cr .( loaded LEVEL 3 functions. )

also forth definitions

