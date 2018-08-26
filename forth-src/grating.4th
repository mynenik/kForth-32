\ grating.4th
\
\   Compute the diffraction properties of a diffraction grating, 
\   given the input beam specs. This program is useful in the design
\   of a grating spectrometer, or in determining the properties
\   of a grating with unknown groove spacing. For example, one may 
\   illuminate the grating with a collimated beam from a Helium-Neon 
\   laser. Using the known incidence angle and measured beam angles 
\   for the different diffraction orders, the groove spacing of the 
\   unknown grating may be determined with the output of this program.
\
\   Copyright (c) 2004 Krishna Myneni
\   Provided under the GNU General Public License
\
\ Revisions:
\   2004-11-04  created  km
\   2004-11-05  added formatted output and dispersion and resolution calcs  km
\
\ Notes:
\
\ 1) Usage Example:
\
\      800 633 calc
\
\    For an 800 groove/mm grating and a wavelength of 633 nm, print a table of 
\    diffraction angles, dispersion, and resolution for various incidence angles. 
\    Labels shown on the table are:
\      
\      Theta_i     incidence angle of beam on grating, measured from grating 
\                  normal (in degrees).
\
\      m           diffraction order; only allowed orders are shown.
\
\      Theta_d     diffraction angle, w.r.t. grating normal, for the
\		   corresponding order (in degrees).
\
\      Dispersion  angular deflection per wavelength interval, d (Theta_d)/d lambda
\                  ( in milliradians of deflection per nanometer wavelength change)
\
\      Resolution  wavelength resolution for a specified beam size which is 
\                  assumed to be smaller than the width of the grating. Since
\                  the beam is incident on only a finite number of grooves,
\                  the resolving power of the grating will be determined by
\                  both the diffraction angle and the beam width. The beam
\		   width is set to 5 mm by default, but can be changed in the
\                  variable "fwhm". Resolution is shown in nm.



\ grating properties

fvariable  a            \ groove spacing in mm

\ beam properties

fvariable  lambda	\ wavelength in nm
fvariable  fwhm         \ beam full width at half max along diffraction plane in mm

5e fwhm f!  \ default beam diameter

      
: diff_angle ( ftheta_i  order -- ftheta_d  flag | angles are in rad, order is integer)
    s>f lambda f@ 1e-9 f* f*   \   m*lambda in meters
    a f@ 1e-3 f*               \   groove spacing in meters
    f/                         \   m*lambda/a
    fswap fsin f-              \   m*lambda/a - sin(theta_i)
    fdup 1e f> 
    IF  false ELSE fasin true THEN ;

: dispersion ( ftheta_d  order -- fdispersion | dispersion in mrad/nm )
      s>f fswap fcos a f@ 1e6 f* f* f/ 1000e f* ;

: resolution ( ftheta_i  ftheta_d  -- fdlambda | wavelength resolution in nm)
      fsin fabs fswap fsin f+ fwhm f@ 1e-3 f* f*
      lambda f@ 1e-9 f* fdup f* fswap f/ 1e-9 f/ ;

\ -- number formatting words

: fstring ( f n -- a u | convert f to a formatted string with n decimal places )
    1 swap dup >r 0 ?do 10 * loop s>f f* fround f>d dup -rot dabs
    <# r> 0 ?do # loop [char] . hold #s rot sign #> ; 

: fprint ( f n width -- | print an fp number to n decimal places in width)
    >r fstring r> over - dup 0> IF spaces ELSE drop THEN type ;


 
: .table-header ( -- | print table header )
    cr ." Theta_i  m    Theta_d  Dispersion    Res(" 
       fwhm f@ f>d d. ." mm)"   
    cr ."  (deg)         (deg)    (mrad/nm)       (nm)"
    cr ." ----------------------------------------------"
;


    
: calc ( gr/mm  nm -- | inputs are integers for groove density and wavelength)
    s>f lambda f!
    s>f 1e fswap f/ a f!
    .table-header
    90 0 DO		    \ loop over theta_i from 0 to 90 deg
      cr i 4 .r 4 spaces
      10 1 DO
	j s>f deg>rad i diff_angle
	IF   i 2 .r fdup fdup
	     rad>deg        2 spaces  2  8 fprint      \ print theta_d
	     i dispersion   2 spaces  2  8 fprint      \ print dispersion
	     j s>f deg>rad fswap 
	     resolution     6 spaces  3  8 fprint      \ print resolution
	     cr 8 spaces 
	ELSE fdrop leave  ( no valid solution for this order ) 
	THEN
      LOOP
    10 +LOOP ;


