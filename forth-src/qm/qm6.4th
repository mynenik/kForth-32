\ qm6.4th
\
\ The Pauli Spin Matrices, Spinors, and Measurement Probabilities
\
\ Copyright (c) 2003--2017 Krishna Myneni, krishna.myneni@ccreweb.org
\ Provided under the GNU General Public License
\
\ Use the spin state of an electron (or any fermion) to numerically 
\ illustrate the fundamental principles of quantum mechanics:
\
\     a) measurement of a physical quantity is represented by an operator.
\
\     b) state of the system (particle) can be represented as a vector in
\          an N-dimensional space[1].
\
\     c) eigenvalues of an operator represent possible measurement 
\          values for the measurement associated with that operator.
\
\     d) probability of measuring a particular eigenvalue is
\          the magnitude squared of the projection of the state
\          vector onto the eigenvector corresponding to the
\          particular eigenvalue of the measurement operator
\          (caveat: this statement assumes the state vector and
\          eigenvectors of the measurement operator are normalized,
\          i.e. have unit length).
\
\ [1] In the simple case of fermion spin, N=2 because there are only two
\     possible outcomes for the measurement of the particle's spin along
\     *any* axis. The spin state of a fermion is represented by an ordered
\     set of 2 complex numbers, which are the amplitudes along two basis
\     vectors. The basis vectors for fermion spin are *chosen* to be the
\     two eigenvectors of the "sz" operator.
\
\
\ Suggested reading:
\
\     1) Quantum Physics of Atoms, Molecules, Solids, Nuclei, and
\        Particles, by R. Eisberg and R. Resnick, 2nd ed., Wiley 1985.
\        (sections 8-1 through 8-3; college undergraduate level).
\
\     2) Introduction to Quantum Mechanics, by D. J. Griffiths,
\        Prentice Hall 1995. (section 4.4; advanced undergrad level).
\
\     3) Quantum Mechanics, by. E. Merzbacher, 3rd ed., Wiley 1998.
\        (chapter 16; graduate course level).
\
\ -----------------------------------------------------------------------
\
\ Usage:
\
\  sx, sy, and sz are the three predefined Pauli spin matrices (operators).
\  Note that the actual spin operators (S_x, S_y, and S_z) are the corresponding 
\  Pauli matrices (sx, sy, sz) multiplied by hbar/2. The factor of hbar/2 will
\  therefore be absent in the calculation of eigenvalues and expectation values.
\  "one" is the predefined identity matrix.
\
\  sx s.                  \ print the sigma x Pauli spin matrix
\  sy s.                  \                 y
\  sz s.                  \                 z
\  sx sy s* s.            \ multiply sx and sy and print the result
\  sx adjoint s.          \ print the adjoint of sx 
\  sx sy [,] s.           \ compute and print the commutator of sx and sy
\  sz s-eigenvalues f. f. \ compute and print the eigenvalues of sz
\  sz s-eigenvectors s. cr s. \ compute and print the eigenvectors of sz
\  z=1  z=0 spinor x1     \ define the spinor x1 with components 1+i0, 0+i0
\  x1 s.                  \ print the spinor x1
\  x1 adjoint x1 s* s.    \ compute and print inner product <x1|x1>
\  x1 x1 <|> n.           \ same as above: <x1|x1>, except return of <|>
\                         \   is a complex number rather than 1x1 matrix.
\  sx x1 s* s.            \ apply sx operator to vector x1 and show new vector
\  x1 adjoint sx x1 s* s* s.  \ compute and print <x1|sx|x1>, the expectation
\                             \   value of operator sx for the state x1.
\  x1 sx x1 <||> n.           \ same as above: <x1|sx|x1>, except <||> returns
\                             \   a complex number.
\  x1 <sx> f.             \ same as above: <x1|sx|x1>, except return is a real 
\                         \   number; only <sx>, <sy>, and <sz> are predefined
\                         \   for computing expectation values.
\  z=1  z=i spinor x2     \ define spinor x2 with components 1+i0, 0+i1
\  x2 normalize s.        \ print the normalized spinor
\  x2 normalize x2 s:=    \ set x2 = normalized(x2)
\  x1 x2 <|> n.           \ compute and print projection of x2 along x1
\  x1 x2 |<|>|^2 f.       \ print the probability of finding x1 given x2
\  sx s-eigenvectors <|> n.  \ verify orthogonality of the eigenvectors of sx
\  0e 3e  4e 0e spinor x3 \ define spinor x3 with components 0+i3, 4+i0
\  x3 normalize x3 s:=    \ normalize spinor x3
\  z=0 z=0 spinor e-up    \ create a dummy vector
\  z=0 z=0 spinor e-down  \ "   "
\  sz s-eigenvectors  e-down s:=  e-up s:=  \ set e-down and e-up to the
\                                           \ eigenvectors of sz
\  e-down s.              \ verify the spin down eigenvector for sz
\  e-up s.                \  "         spin up     "
\  e-down x3 |<|>|^2 f.   \ print probability of measuring spin down along
\                         \   z-axis for particle in state x3
\  e-up   x3 |<|>|^2 f.   \ print probability of measuring spin up for state x3
\  z=0 z=0 z=0 z=0 operator s1  \ create a new operator s1, initialized to zeros
\  sx sz s+ s1 s:=        \ set the operator s1 to sx+sz
\  0.707e s1 f*s s1 s:=   \ set the operator s1 = 0.707*s1
\ ----------------------------------------------------------------------
\		
\ Exercises:
\
\ 1. Show that the Pauli spin matrices are unitary, i.e.
\
\	sx*sx = sy*sy = sz*sz = one
\
\ 2. Show that the spin matrices are Hermitian, i.e.
\
\	adjoint(si) = si
\
\       where adjoint means take the complex conjugate, then the transpose, 
\       and i = x, y, or z
\
\ 3. Verify that the sx, sy, and sz matrices do not commute with each other,
\    and that they satisfy the commutation relations for angular momentum:
\
\	[sx, sy] = c*i*sz
\	[sy, sz] = c*i*sx
\	[sz, sx] = c*i*sy
\
\    where c is a real constant.
\
\ 4. Determine the eigenvectors and eigenvalues for sx, sy, and sz.
\
\ 5. Given the spin state
\
\		      / \
\		     | 1 |
\		x1 = |   |
\		     | 0 |
\		      \ /
\
\    compute the probability of measuring +1 ("spin up") and the 
\    probability of measuring -1 ("spin down") along the x, y, 
\    and z axes.
\
\    Hint: Find the eigenvectors for spin-up and spin-down of the
\          appropriate measurement operator (sx, sy, or sz). Then,
\          find the projection of the given spinor onto the
\          spin-up and spin-down eigenvectors. The final step is
\          to square the magnitudes of the projections. 
\
\    Example: The probability of measuring spin down along the
\                    y-axis is 0.5, or 50%.
\
\
\ 6. Normalize the following spin states and compute their spin up
\    and spin down measurement probabilities for sx, sy, and sz.
\
\	      / \     / \     /  \     /     \     /      \
\	     | 0 |   | 1 |   | -1 |   | 1 - i |   | -1 + i |
\	x1 = | 	 |   |   |   |    |   |       |   |        |
\	     | 1 |,  | 1 |,  |  1 |,  | 1 + i |,  |  1 + i | 
\	      \ /     \ /     \  /     \     /     \      /
\
\
\ 7. Compute the expectation values for sx, sy, and sz for the
\    normalized spin states of exercises 5 and 6.
\
\
\ 8. Compute the probability of measuring spin down for the input
\      state of problem 5, along an axis in the x-z plane which is
\      45 degrees from both the z and x axes.
\
\    Hint 1: The spin measurement operator along an axis in the x-z
\            plane is the following linear combination of sx and sz 
\            operators:
\
\               s_theta = sin(theta)*sx + cos(theta)*sz
\
\            where theta is the angle between the measurement axis and
\            the z-axis. For this problem, theta is 45 degrees (don't
\            forget to convert to radians when computing the new operator). 
\
\   Answer: The probability of observing the particle with spin down along the 
\           45 degree axis in the x-z plane is 14.6%. 
\
\  If you are able to arrive at the answer to exercise 8, 
\  then you have successfully applied the fundamental principles 
\  of quantum mechanics to solve a real-world problem.
\
\ ------------------------------------------------------------------
\ 
\ Revisions:
\   
\	2004-02-19  first release version  km
\       2017-12-01  revised comments, particularly for hint in
\                   exercise 5, which was mis-stated.  km         
\
\ Requires:
\
\	ans-words.4th
\	complex.4th
\	matrix.4th
\	zmatrix.4th
\	zeigen22h.4th
\
\ --------------------------------------------------------------------

include ans-words
include fsl/complex
include matrix
include zmatrix
include zeigen22h

2 2 zmatrix one		\ one is the 2x2 identity matrix
2 2 zmatrix sx
2 2 zmatrix sy
2 2 zmatrix sz


: zfloats ( n -- nbytes ) DFLOATS 2* ;


\ Storage and creation of operators and spinors

: s! ( z1 ... zn  v|op -- | store the components of a vector or operator)
        dup mat_size@ 2dup * >r rot zmat_addr
	r> 0 do dup >r z! r> 1 zfloats - loop drop ;

: s@  ( v|op -- z1 ... zn | fetch the components of a vector or operator)
	dup mat_size@ * >r 1 1 rot zmat_addr
	r> 0 do >r r@ z@ r> 1 zfloats + loop drop ; 

: s:=  ( v1|op1  v2|op2 --  | set v2|op2 components to v1|op1 components)
	zmat-copy ;

: initialized-zmatrix ( z1 ... zn  rows cols <name> -- | create an initialized zmatrix)
        create 2dup * zfloats 2 cells + allot? dup >r mat_size! r> s! ;
	  
: spinor ( z1 z2 <name> -- | create and initialize a new spinor)  
	2 1 initialized-zmatrix ;

: operator ( z1 z2 z3 z4 <name> -- | create and initialize a new operator)
	2 2 initialized-zmatrix ;


\ Dynamic buffer for transient spin matrices and vectors

32768 constant SBUF_SIZE
create sbuf SBUF_SIZE allot
variable sptr   sbuf sptr !

: alloc_sbuf ( size -- a | allocate size bytes and return address)
	>r sptr a@ dup r@ + dup sbuf SBUF_SIZE + >=
	IF 2drop sbuf dup r> +		\ wraparound 
	ELSE r> drop THEN
	sptr ! ;

: alloc_zmat ( n m -- a | allocate a nxm complex matrix and return address)
	2DUP * zfloats 2 CELLS + alloc_sbuf
	dup >r mat_size! r> ; 
 
: alloc_op ( -- op | allocate an operator )   2 2 alloc_zmat ; 
: alloc_vec ( -- v | allocate a ket vector )  2 1 alloc_zmat ;


\ Operator and Vector Manipulation

: adjoint ( op1|v1 -- op2|v2  | return the transponse of the conjugate of inp)
        alloc_op dup >r zmat-copy
	r@ zmat-conjg
	r> alloc_op dup >r zmat-transpose r> ;

: s+   ( op1 op2 -- op3 | return the sum of two operators )
	alloc_op dup >r zmat+ r> ;

: s*   ( op1 op2 -- op3 | return the product of two operators )
	alloc_op dup >r zmat-mul r> ;

: f*s  ( f op1 -- op2 | return the product of a real number and an operator )
	alloc_op dup >r zmat-copy r@ f*zmat r> ;

: z*s  ( z op1 -- op2 | return the product of a complex number and an operator )
	alloc_op dup >r zmat-copy r@ z*zmat r> ;

: [,]  ( o1 o2 -- o3 | return the commutator of two operators )
	2dup s* >r
	swap s* dup >r zmat-negate
	r> r> s+ ;


: <|>  ( v1 v2 -- z | return the complex inner product of two spinors)
	>r adjoint r> 1 1 alloc_zmat dup >r zmat-mul
	1 1 r> zmat@ ;


: |<|>|^2  ( v1 v2 -- f )   <|>  |z|^2 ;		


: normalize ( v1 -- v2 | return a normalized spinor)
	alloc_vec dup >r zmat-copy
	1 1 r@ zmat@ |z|^2 
	2 1 r@ zmat@ |z|^2 
	f+ fsqrt 1e fswap f/ r@ f*zmat r> ;

: <||> ( v1 op v2 -- z | return the complex value <v1|op|v2> ) 
	alloc_vec dup >r zmat-mul r> <|> ;

  
\ Since sx, sy, and sz are Hermitian, they will have real expectation values:

: <sx> ( v -- f )  sx over <||> real ;
: <sy> ( v -- f )  sy over <||> real ;
: <sz> ( v -- f )  sz over <||> real ;

: pol. ( v -- | compute and print the polarization vector for a spin state)
	dup <sx> f. ."  x^  + " dup <sy> f. ."  y^  + " <sz> f. ."  z^" ;

: s-eigenvalues ( op -- f1 f2 | return the eigenvalues of the operator)
        eigenvalues fswap ;

: s-eigenvectors ( op -- v1 v2 | return the eigenvectors of the operator)
        alloc_op dup >r eigenvectors 
	1 r@ zcol@  
	alloc_vec dup >r 1 swap zcol! r>
	2 r> zcol@ 
	alloc_vec dup >r 1 swap zcol! r> 
	swap ;

\ Initialize the identity and Pauli matrices. 
	
: s-init ( -- | initialize the fundamental 2x2 matrices)

	z=1 z=0 
	z=0 z=1  one s!

	z=0 z=1  
	z=1 z=0  sx  s!

	z=0 z=i conjg
	z=i z=0  sy  s!

	z=1 z=0
	z=0 z=1 znegate sz s!
;

s-init


\ Formatted output routines

\ n. prints a complex number in easier to read, more natural form 
\    than z. particularly when one of the components is zero. 
: n. ( x y -- | print a pair of floating point numbers as a complex number)
	FSWAP FDUP F0= DUP >R IF FDROP ELSE F. THEN
	FDUP F0= IF 
	  R> IF [CHAR] 0 EMIT THEN FDROP EXIT 
	THEN
	FDUP F0< IF 
	  [CHAR] - EMIT R> INVERT IF SPACE THEN
	ELSE 
	  R> INVERT IF [CHAR] + EMIT SPACE THEN
	THEN 
	[CHAR] i EMIT
	FABS FDUP 1E F<> IF SPACE F. ELSE FDROP THEN ;
  
 
\ print spin matrices and spinors

: s. ( a -- | print a complex matrix using natural form)
	dup mat_size@ 1+
	swap 1+
	1 do
	  dup
	  1 do
	    over j i rot zmat@ n. 9 emit 
	  loop
	  cr
	loop
	2drop ;
