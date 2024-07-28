\ FITS file example
\
\ from section 2.6 of the manual, CFITSIO User's Reference Guide:
\ An Interface to FITS Format Files for C Programmers, version 3.0.,
\ April 2009. See file cfitsio.pdf at
\
\   http://heasarc.gsfc.nasa.gov/fitsio/
\
\ K. Myneni, krishna.myneni@ccreweb.org
\
include ans-words
include modules
include syscalls
include mc
include asm
include strings
include lib-interface
include struct
include struct-ext
include libcfitsio 
include fsl/fsl-util

variable file_fptr       \ pointer to the FITS file; defined in fitsio.h
variable status

2variable fpixel 
1 s>d fpixel 2! 
2 value naxis
2variable nelements
variable exposure

2 INTEGER array naxes{ 
 300 naxes{ 0 } !
 200 naxes{ 1 } !  \ image is 300 pixels wide by 200 rows

200 300 2 MATRIX array{{ 

: fits-ex1 ( -- status )
    0 status !         \ initialize status before calling fitsio routines 
    file_fptr z" testfile.fits" status fits_create_file   \ create new file
    cr ." fits_create_file returned " dup . 
    ABORT" Unable to open the output FITS file!"

    \ Create the primary array image (16-bit short integer pixels)
    file_fptr @ SHORT_IMG naxis naxes{ 0 } status  fits_create_img 
    cr ." fits_create_image returned " . 

    \ Write a keyword; must pass the ADDRESS of the value 
    1500 exposure !
    file_fptr @ TLONG z" EXPOSURE" exposure z" Total Exposure Time" status fits_update_key 
    cr ." fits_update_key returned " .

    \ Initialize the values in the image with a linear ramp function
    naxes{ 1 } @ 0 DO
        naxes{ 0 } @ 0 DO
            I J + array{{ J I }}  w! 
        LOOP
    LOOP
    naxes{ 0 } @  naxes{ 1 } @ * s>d nelements 2!  \ number of pixels to write 

    \ Write the array of integers to the image
    file_fptr @ TSHORT fpixel 2@ nelements 2@ array{{ 0 0 }} status fits_write_img
    cr ." fits_write_img returned " .

    file_fptr @ status fits_close_file             \ close the file
    cr ." fits_close_file returned " .
    \ 0 status @ fits_report_error \ (stderr, status)  \ print out any error messages 

    status @
;


