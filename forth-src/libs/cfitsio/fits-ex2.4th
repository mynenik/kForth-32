\ fits-ex2.4th
\
\ Example of reading FITS files, taken from [1]
\ 
\ [1] W. Pence, CFITSIO Quick Start Guide, January 2003, p.4.
\
include libcfitsio \ required by every program that uses CFITSIO 

\ The following two variables are essential
variable file_fptr       \ pointer to the FITS file; defined in fitsio.h
variable status

\ Program specific data
create card FLEN_CARD allot
variable nkeys

: fits-ex2 ( c-addr u -- status )
    0 status !         \ initialize status before calling fitsio routines 
    $>zstr file_fptr swap READONLY status  fits_open_file   \ open existing FITS file
    cr ." fits_open_file returned " dup . 
    ABORT" Unable to open the input FITS file!"
  
    0 nkeys !  
    file_fptr @  nkeys NULL status  fits_get_hdrspace
    cr ." fits_get_hdrspace returned " . 

    cr
    nkeys @ 1+ 1 DO
      file_fptr @ I card status  fits_read_record  drop \ read keyword
      card zstr>$ type cr
    LOOP

    ." END" cr cr
    file_fptr @ status  fits_close_file drop
    
    status @ IF
      \ stderr status  fits_report_error
    THEN

    status @
;



   
