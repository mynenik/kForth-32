\ 3ds-transform.4th
\
\ Transformations on 3d models
\
\ Copyright (c) 2009 Krishna Myneni, Creative Consulting for Research & Education
\ 
\ This code is provided under the GNU Lesser General Public License (LGPL)
\
\ Revisions:
\   2009-12-03  km  fixed a problem with Rtransform-Vertices

[UNDEFINED] 3ds_Vertex% [IF]  s" 3ds.4th" included  [THEN]

[undefined] fpick [IF] : fpick floats sp@ cell+ + f@ ;  [THEN]  \ kForth-specific definition
: f3dup  2 fpick 2 fpick 2 fpick ;
 
\ View rotation

\ Object rotation angles (Euler angles)
fvariable phi
fvariable theta
fvariable psi

fvariable cos_phi
fvariable sin_phi
fvariable cos_theta
fvariable sin_theta
fvariable cos_psi
fvariable sin_psi

create Rmatrix 9 floats allot

\ Setup the rotation matrix for the current object rotation angles
: update-rotation-matrix ( -- )
    phi f@   fsincos  cos_phi f!   sin_phi f!
    theta f@ fsincos  cos_theta f! sin_theta f!
    psi f@   fsincos  cos_psi f!   sin_psi f!

    cos_psi f@ cos_phi f@ f*   cos_theta f@ sin_phi f@ f* sin_psi f@ f*  f-
    Rmatrix f!
    cos_psi f@ sin_phi f@ f*   cos_theta f@ cos_phi f@ f* sin_psi f@ f*  f+
    [ Rmatrix FLOAT+ ] literal f!
    sin_psi f@ sin_theta f@ f*  
    [ Rmatrix 2 FLOATS + ] literal f!

    sin_psi f@ cos_phi f@ f*  cos_theta f@ sin_phi f@ f* cos_psi f@ f* f+ fnegate
    [ Rmatrix 3 FLOATS + ] literal f!
    sin_psi f@ sin_phi f@ f* fnegate cos_theta f@ cos_phi f@ f* cos_psi f@ f* f+
    [ Rmatrix 4 FLOATS + ] literal f!
    cos_psi f@ sin_theta f@ f*  [ Rmatrix 5 FLOATS + ] literal f!

    sin_theta f@ sin_phi f@ f*  [ Rmatrix 6 FLOATS + ] literal f!
    sin_theta f@ cos_phi f@ f* fnegate [ Rmatrix 7 FLOATS + ] literal f!
    cos_theta f@  [ Rmatrix 8 FLOATS + ] literal f!
;


\ Rotation transformation of an array of vertices using the current object 
\ rotation angles.
\ Input array is a1, output array is a2, and u points will be transformed
fvariable xp
fvariable yp
fvariable zp

: Rtransform-Vertices ( a1 a2 u -- )
    0 ?DO
      >r >r
      r@ 3ds_Vertex->z sf@  r@ 3ds_Vertex->y sf@  r@ 3ds_Vertex->x sf@ 
      f3dup f3dup

      Rmatrix f@ f* fswap 
      [ Rmatrix 3 floats + ] literal f@ f* f+ fswap 
      [ Rmatrix 6 floats + ] literal f@ f* f+ xp f!

      [ Rmatrix 1 floats + ] literal f@ f* fswap 
      [ Rmatrix 4 floats + ] literal f@ f* f+ fswap
      [ Rmatrix 7 floats + ] literal f@ f* f+  yp f!

      [ Rmatrix 2 floats + ] literal f@ f* fswap 
      [ Rmatrix 5 floats + ] literal f@ f* f+ fswap
      [ Rmatrix 8 floats + ] literal f@ f* f+ zp f!

      r> r> dup 2dup 2>r >r
      zp f@  r> 3ds_Vertex->z sf!
      yp f@  r> 3ds_Vertex->y sf!
      xp f@  r> 3ds_Vertex->x sf!
      
      VTX_SIZE + swap VTX_SIZE + swap
    LOOP
    2drop
;

