\ qm4.4th
\
\ Quantum Mechanics Demo 4, Properties of Eigenfunctions and Operators
\
\ Copyright (c) 2001 Krishna Myneni  ( krishna.myneni@ccreweb.org )
\ Provided under the GNU General Public License.
\
\
\ This demo illustrates several properties of eigenfunctions and 
\ operators in quantum mechanics. The radial eigenfunctions for the
\ hydrogen atom with zero angular momentum (L=0), phi_n(r) for n=1--4,
\ are used to illustrate properties such as orthogonality and 
\ normalization of eigenfunctions. In addition, the Hamiltonian and 
\ other operators are defined. These operators allow the user to verify 
\ that the functions presented are in fact eigenfunctions of the Hamiltonian
\ operator, and perform other computations such as determination of
\ eigenvalues (allowed energy levels), averages of radii, potential 
\ energy, and the probability of an electron with a specified
\ wavefunction being between r1 and r2.
\ 
\ Some Examples of Usage:
\
\  1 phi		\ compute phi_1(r) and leave address of the
\			\   wavefunction on the stack
\
\  1 phi psi.	      	\ compute and print phi_1 vs r
\
\  >file d1.dat 1 phi psi. console \ compute and output phi_1 to file d1.dat
\
\  1 phi 1 phi ip f.	\ compute and print inner product of phi_1 and phi_1,
\                   	\   i.e. integral from 0 to RMAX of r^2*phi_1*phi_1
\
\  1 phi dup ip f.	\ same as above
\
\  1 phi 2 phi ip f.	\ demonstrate orthogonality of phi_1 and phi_2
\
\  3 phi r	     	\ operate on phi_3 with r and leave result on stack
\
\  3 phi d/dr		\ operate on phi_3 with d/dr, i.e. compute first
\			\   derivative of phi_3; leave result on stack
\
\  1 phi dup prod r r psi.  \ compute and print radial probability density
\			\  function vs r for state 1 (or redirect to a file
\			\  using previous example)
\ 
\  1 phi dup r ip f.	\ compute average value of r in state phi_1
\			\ (units are Bohr radii)
\
\  3 phi H psi.		\ operate on phi_3 with Hamiltonian and print
\			\   (or redirect to a file using previous example)
\
\  1 phi dup H ip f.	\ compute expectation value of H in state phi_1
\			\  (units are Rydbergs)
\
\  1 phi 2 phi V ip f.  \ compute matrix element of V between states 1 & 2
\
\  1 phi 3 phi r ip f.  \ compute matrix element of r between states 1 & 3
\
\  1 phi dup prod 1e 20e integrate f.  \ compute and print integral of 
\	\   r^2*phi_1*phi_1  from r=1.0 to 20.0 Bohr radii, i.e., the
\	\   probability that the electron in state 1 will be found between
\	\   r= 1 and r=20.
\
\ Notes:
\
\ 1. This demo deals with the radial wavefunctions of the
\    hydrogen atom, which are real (no imaginary component).
\    Therefore, the code assumes only real wavefunctions, and
\    thereby is limited in its application. For example, 
\    computations cannot be performed on arbitrary wavefunctions,
\    which are in general a complex superposition of the 
\    eigenfunctions. Such computations will be demonstrated in
\    subsequent demos. 
\
\ 2. This code was written for kForth. It assumes a common
\    stack for integer and floating point values. Non-standard
\    ANS words intrinsic to kForth have the following ANS equivalent
\    definitions.
\
\ : A@ @ ;
\ : S>F S>D D>F ;
\ : FROUND>S FROUND F>D D>S ;
\    
\ Revisions:
\
\ 	8-21-2001 -- First version
\	4-15-2003 -- Replaced F>S with FROUND>S

\
\ ---------------------------------------------------------------
\ Define the framework for storing wavefunctions and
\   performing operations upon them.
\ ---------------------------------------------------------------

1 dfloats constant DSIZE
1024 1024 * constant PSIBUFSIZE		\ 1 MB
create psi_buf PSIBUFSIZE allot		\ allocate wavefunction buffer
variable psi_ptr psi_buf psi_ptr !	\ pointer in psi_buf

fvariable RMAX 50e RMAX f!  \ maximum radius in Bohr units for computations
variable nsteps
10000 nsteps !		\ default number of points for wavefunctions
fvariable rstep

: set_step_size ( -- ) RMAX f@ nsteps @ s>f f/ rstep f! ;

: psi_size ( -- n | return number of bytes required to store wavefunction )
	nsteps @ dfloats ;

: psi_alloc ( -- a | reserve memory for wavefunction in psi_buf )
	\ return the address of start of wavefunction data
	psi_ptr a@ dup psi_size + 
	dup psi_buf PSIBUFSIZE + <
	if psi_ptr ! 
	else 2drop psi_buf dup psi_size + psi_ptr ! \ wraparound 
	then ; 

: @psi[] ( a n -- f | fetch the n^th element of wavefunction )
	\ n starts at 0 and can have maximum value of nsteps-1
	dfloats + f@ ;

: !psi[] ( f a n -- | store the n^th element of wavefunction )
	dfloats + f! ;

: psi. ( a -- | print the wavefunction value vs r )
	nsteps @ 0 do
	  i s>f rstep f@ f* f. 9 emit dup i @psi[] f. cr
	loop drop ; 	

: verify_address ( a -- a | abort if top item on stack is not an address )
	dup @ drop ; \ kForth will produce a VM error if item not an address

: verify_address_pair ( a1 a2 -- a1 a2 )
	2dup @ drop @ drop ;


\ ------------------------------------------------------------------ 
\ Define words to compute eigenfunctions.
\ ------------------------------------------------------------------

8 constant MAX_EF		\ maximum number of eigenfunctions
create efa MAX_EF cells allot	\ array of addresses to eigenfunctions

variable ne			\ number of eigenfunctions
4 ne !

2e fsqrt fconstant SQRT_TWO
3e fsqrt fconstant SQRT_THREE

\ In this example, we use the known radial eigenfunctions
\   for the hydrogen atom with no angular momentum (L = 0),
\   c.f. R.D. Cowan, The Theory of Atomic Structure and
\   Spectra (University of California Press, 1981).
	 
: phi_1 ( r -- f | return 2*exp[-r] )
	fnegate fexp 2e f* ;

: phi_2 ( r -- f | return [2^-.5]*exp[-r/2]*[1-r/2] )
	2e f/ fnegate fdup 
	1e f+ fswap fexp f* SQRT_TWO f/ ;

: phi_3 ( r -- f | return [2/27^.5]*exp[-r/3]*[1 - 2r/3 + 2r^2/27] )
	3e f/ fnegate fdup fdup fdup
	f* 2e f* 3e f/ fswap 2e f* f+ 1e f+
	fswap fexp f* 2e f* 3e f/ SQRT_THREE f/ ;

: phi_4 ( r -- f | return [1/4]*exp[-r/4]*[1-3r/4+r^2/8-r^3/192] )
	4e f/ fnegate fdup fdup fdup
	fdup fdup f* f* 3e f/ fswap fdup f* 2e f* f+
	fswap 3e f* f+ 1e f+ fswap fexp f* 4e f/ ;
	

\ Set up addresses to the eigenfunctions

' phi_1 efa !
' phi_2 efa 1 cells + !
' phi_3 efa 2 cells + !
' phi_4 efa 3 cells + !

: @efa[] ( n -- a | return the address of the n^th eigenfunction )
	1- cells efa + a@ ;

variable ntemp


: phi ( n -- a | compute the n^th eigenfunction n over the range r=0 to RMAX )
	\ Return the address of the start of the function data
	dup ne @ > if ." Invalid eigenfunction number." cr abort then
	ntemp !
	psi_alloc dup 	\ reserve memory for the data
	set_step_size
	nsteps @ 0 do
	  dup
	  i s>f rstep f@ f* ntemp @ @efa[] execute 
	  rot f! DSIZE +	  
	loop
	drop ;

	
\ ---------------------------------------------------------------
\ Define arithmetic operations on wavefunctions
\ ---------------------------------------------------------------

variable wf_a1
variable wf_a2
variable wf_a3
fvariable temp

: c* ( a1 f -- a2 | multiply wavefunction by a constant )
	temp f!
	verify_address wf_a1 !
	psi_alloc wf_a2 !
	nsteps @ 0 do
	  wf_a1 a@ i @psi[] temp f@ f*
	  wf_a2 a@ i !psi[]
	loop 
	wf_a2 a@ ;		

: add ( a1 a2 -- a3 | add two functions )
	\ a3 is the address of the sum wavefunction
	psi_alloc wf_a3 ! 
	verify_address_pair wf_a2 ! wf_a1 !
	nsteps @ 0 do
	  wf_a1 a@ i @psi[] wf_a2 a@ i @psi[] f+
	  wf_a3 a@ i !psi[]
	loop
	wf_a3 a@ ;

: prod ( a1 a2 -- a3 | compute product of functions )
	psi_alloc wf_a3 ! 
	verify_address_pair wf_a2 ! wf_a1 !
	nsteps @ 0 do
	  wf_a1 a@ i @psi[] wf_a2 a@ i @psi[] f*
	  wf_a3 a@ i !psi[]
	loop
	wf_a3 a@ ;	

: r_index ( r -- n | return index corresponding to r )
	RMAX f@ f/ nsteps @ s>f f* fround>s nsteps @ min 0 max ;

fvariable r1
fvariable r2
	 
: integrate ( a r1 r2 -- f | compute volume integral from r1 to r2 )
	r2 f! r1 f! 
	verify_address wf_a1 !
	set_step_size
	0e		\ initial value of integral
	r2 f@ r_index r1 f@ r_index do
	  wf_a1 a@ i @psi[]
	  i dup * s>f f* f+
	loop
	rstep f@ fdup fdup f* f* f* ;

: ip ( a1 a2 -- f | integrate the product of a1 and a2 from r=0 to RMAX )
	verify_address_pair prod 0e RMAX f@ integrate ;


\ ---------------------------------------------------------------
\ Define operators that act on the wavefunctions to produce
\	new functions.
\ ---------------------------------------------------------------

: r ( a1 -- a2 | compute the product of r and a wavefunction )
	verify_address wf_a1 !
	psi_alloc wf_a2 !
	nsteps @ 0 do 
	  wf_a1 a@ i @psi[] rstep f@ i s>f f* f*
	  wf_a2 a@ i !psi[]
	loop
	wf_a2 a@ ;

 
: 1/r ( a1 -- a2 | compute the product of 1/r and a wavefunction )
	verify_address wf_a1 !
	psi_alloc wf_a2 !
	nsteps @ 0 do
	  wf_a1 a@ i @psi[] rstep f@ i s>f f* 
	  fdup f0= 
	  if fswap fdrop 	\ avoid singularity at r=0 
	  else f/
	  then
	  wf_a2 a@ i !psi[]
	loop
	wf_a2 a@ ;

\ Derivative operators

: d/dr ( a1 -- a2 | compute the first derivative of a wavefunction )
	\ a1 is the address of psi
	\ a2 is the address of d(psi)/dr

	verify_address wf_a1 !
	psi_alloc wf_a2 !

	\ Compute forward slope at first point

	wf_a1 a@ 1 @psi[] wf_a1 a@ 0 @psi[] f- rstep f@ f/ 
	wf_a2 a@ 0 !psi[]

	\ Compute derivative at interior points by averaging
	\   forward and backward slopes

	nsteps @ 1- 1 do
	  wf_a1 a@ dup i @psi[] rot i 1- @psi[] f-  
	  wf_a1 a@ dup i 1+ @psi[] rot i @psi[] f-
	  f+ rstep f@ f/ 2e f/
	  wf_a2 a@ i !psi[]
	loop
	  
	\ Compute backward slope at last point	  	  	  

	wf_a1 a@ dup nsteps @ 1- @psi[] rot nsteps @ 2- @psi[] f- 
	rstep f@ f/ wf_a2 a@ nsteps @ 1- !psi[]

	wf_a2 a@ ;


: d2/dr2 ( a1 -- a2 | compute the second derivative of a wavefunction )
	d/dr d/dr ;

\ Define the Hamiltonian operator
\
\ The Hamiltonian operator defined below is for the case of a 
\ central potential (V = V(r)) and with zero angular momentum :
\
\	H = -d2/dr2 - (2/r)d/dr + V
\
\ where V is the potential energy. Energy units are Rydbergs and 
\ distance units are Bohr radii:
\
\	1 Rydberg = 13.6058 eV
\	1 Bohr radius = 0.529177 Angstroms
\
\ For the hydrogen atom, V = -2/r
\
: V ( a1 -- a2 | operate on the wavefunction with the potential energy )
	1/r -2e c* ;	

		
: H ( a1 -- a2 | compute and return the function H psi )
	dup d/dr dup d/dr swap 1/r 2e c* add -1e c* swap V add ;









	  
