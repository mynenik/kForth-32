\ qcsim.4th
\
\ Quantum Circuit Simulation language for few qubit circuits.
\
\ Copyright (c) 2019, Krishna Myneni
\ Permission is granted to reuse this work, with attribution,
\ under the Creative Commons CC-BYSA license.
\
\ Notes:
\
\ 0. "n" refers to the number of qubits in the quantum circuit.
\    The quantum state vector of the circuit has 2^n dimensions in 
\    a complex state space.
\
\ 1. A quantum state for n qubits is a data structure containing the
\    following:
\
\      # of dimensions (2^n),  size = 1 cells
\      complex matrix, size = 2^n zfloats + 2 cells
\
\    The dimensions of the complex matrix are 2^n x 1 for a ket vector
\    and 1 x 2^n for bra vector.
\
\ 2. Quantum gates operating on n-qubit quantum states are represented
\    as a data structure containing the following:
\
\      # of dimensions (2^n), size = 1 cells
\      2^n x 2^n complex matrix, size = 2^(2n) zfloats + 2 cells  
\
\ 3. Executing the name of a bra, ket, or gate returns the address
\    of the first element in its complex matrix (see zmatrix.4th),
\    allowing it to be used in the same way as a zmatrix.
\
\ Special stack notation:
\
\   c  unsigned single cell value interpreted as a series
\      of n classical bits (where n must be specified).
\
\   q  pointer to an n-qubit quantum state vector (ket or bra), or
\      or to an n-qubit quantum gate, which may be stored in either the 
\      dynamic buffer (transient persistence) or to the reserved 
\      storage in a named child of one the following defining words:
\      KET  BRA  GATE
\      
\ Glossary:
\
\  2^      ( n -- m )  m = 2^n
\  DIM     ( a -- nrows ncols ) return dimensions of xzmatrix
\  QDIM    ( q -- 2^n ) return dimensionality of quantum state or gate
\  ALLOC_QBUF ( u -- a )  get transient memory for u bytes  
\  ALLOC_XZMAT ( nrows ncols -- a ) get transient memory for xzmatrix 
\  ALLOC_K ( 2^n -- q ) get transient memory for n-qubit ket vector
\  ALLOC_B ( 2^n -- q ) get transient memory for n-qubit bra vector
\  ALLOC_G ( 2^n -- q ) get transient memory for n-qubit gate
\
\  KET    ( n "name" -- ) create named n-qubit ket vector
\  BRA    ( n "name" -- ) create named n-qubit bra vector
\  GATE   ( n "name" -- ) create named n-qubit unitary gate
\
\  CBITS   ( c n -- caddr u ) return n-bit string for c 
\  C.      ( c -- )    print binary representation of c
\  Q.      ( q -- )    print a qubit state or gate matrix
\  Q!      ( z1 ... zm o -- )  store elements of o from stack
\  ->      ( q1 q2 -- ) copy qubit state or gate: q1->q2
\
\  Q+      ( q1 q2 -- q3 ) add two q's
\  %*%     ( q1 q2 -- q3 ) Matrix multiplication of q1 and q2
\  %x%     ( q1 q2 -- q3 ) Kronecker outer product of q1 and q2
\  ADJOINT ( q1 -- q2 )    q2 = adjoint of q1 (q1 "dagger")
\
\  PROB     ( c q -- r )  return probability for measuring c for state q
\  ALL-PROB ( q -- )   show all bit string probabilities for state q
\
\  Not yet implemented:
\
\  U_C     ( icntrl itarg qgate n -- qgate2 ) conditional n-qubit gate
\  Q-      ( q1 q2 -- q3 ) subtract two q's
\  F*Q     ( r  q1 -- q2 ) Multiply q1 by a real scalar
\  Z*Q     ( z  q1 -- q2 ) Multiply q2 by a complex scalar
\  SAMPLES  ( q u a -- ) obtain u measurement samples for state q  
\  MEASURE  ( qin xtqc -- c ) execute quantum circuit with state qin
\                       and measure bit outputs c
\ Requires:
\   fsl/fsl-util.4th
\   fsl/complex.4th
\   fsl/extras/zmatrix.4th
\
\ Revisions:
\   2019-11-02 km  first version, one and two-qubit quantum circuits
\   2019-11-07 km  generic operators for quantum states and gates;
\                    simplified notation.

include ans-words.4th
include strings.4th
include fsl/fsl-util.4th
include fsl/complex.4th
include fsl/extras/zmatrix.4th

\ General utilities

: 2^ ( n -- m ) 1 swap lshift ;
: c. ( c -- | print binary form of c) 
   base @ binary swap . base ! ;

\ Return n-bit binary string for c
: cbits ( c n -- caddr u )
   base @ >r binary 
   >r s>d <# r>
   0 ?DO # LOOP #> 
   r> base ! ;

\ An extended zmatrix structure. FSL matrices do not store the
\ number of rows in the header. To abstract the interface for
\ both quantum state vectors (ket and bra) and quantum gates,
\ we extend the zmatrix structure to store the number of rows
\ as well, while allowing the extended "xzmatrix" to be used 
\ transparently as a zmatrix

3 cells constant HDRSIZE

: xzmat-hdr! ( nrows ncols a -- )
    tuck cell+ complex over cell+ ! ! ! ;

: xzmat-size ( nrows ncols -- u ) * zfloats HDRSIZE + ;

: xzmatrix ( nrows  ncols "name" -- )
    create 2dup xzmat-size ?allot xzmat-hdr!
    does> HDRSIZE + ;

\ Return the dimensions of an xzmatrix
: dim ( a -- nrows ncols ) HDRSIZE - dup @ swap cell+ @ ;
: }}nrows ( a -- nrows )   HDRSIZE - @ ;

\ Dynamic buffer for transient, unnamed quantum states and gates
1024 2048 * constant QBUF_SIZE
create qbuf QBUF_SIZE allot
variable qptr   qbuf qptr !
 
\ Allocate usize bytes and in dynamic buffer;
\ Return start address of newly allocated region.
: alloc_qbuf ( usize -- a | allocate size bytes and return address)
    >r qptr a@ dup r@ + dup qbuf QBUF_SIZE + >=
    IF 2drop qbuf dup r> +          \ wraparound 
    ELSE r> drop THEN
    qptr ! ;

\ allocate an xzmatrix in the dynamic buffer;
\ return address is to start of matrix data
: alloc_xzmat ( nrows ncols -- a ) 
    2dup xzmat-size alloc_qbuf 
    dup >r xzmat-hdr! r> HDRSIZE + ;

\ allocate an n-qubit ket vector in the dynamic buffer
: alloc_k ( 2^n -- q ) 1 alloc_xzmat ;

\ allocate an n-qubit bra vector in the dynamic buffer
: alloc_b ( 2^n -- q ) 1 swap alloc_xzmat ;

\ allocate space for an n-qubit gate in the dynamic buffer
: alloc_g ( 2^n -- q ) dup alloc_xzmat ;

\ Adjoint of quantum state vector or gate
: adjoint ( q -- qd )
    dup dim swap alloc_xzmat >r
    dup }}nrows swap r@ }}ztranspose
    r@ dup }}nrows swap }}zconjg r> ;
    
\ Return dimensionality of quantum state or gate
: qdim ( q -- 2^n ) dim max ;

\ Print a state vector or a gate
: q. ( q -- )  dup }}nrows swap }}zprint ;

\ Store qubit state vector or gate matrix elements from stack
: q! ( z1 ... zm q -- )
    dup >r dim *   \ -- z1 ... zm nelem
    r> dup dim 1- swap 1- swap }}
    swap 0 ?DO  dup >r z! r> zfloat-  LOOP drop ;

\ Add two states or two gates
: q+ ( q1 q2 -- q3 )
    dup dim alloc_xzmat >r
    >r dup }}nrows swap r> 
    r@ }}z+ r> ;

0 [IF]
\ Subtract two states or two gates
: q- ( q1 q2 -- q3 )
    dup dim alloc_xzmat >r
    >r dup }}nrows swap r> 
    r@ }}z- r> ;
[THEN]
   
\ Copy ket, bra, or gate: q1 -> q2
: -> ( q1 q2 -- )
    2dup >r dim r>  dim d= invert Abort" Object size mismatch!"
    dup dim * zfloats move ;

\ Probability of measuring classical bits c in ket q
: prob ( c q -- r )
    dup >r qdim 1- and r> swap 0 }} z@ |z|^2 ;

\ Print the probabilities for measuring all n classical
\ outputs for ket q
: all-prob ( q -- )
    dup qdim   \ -- q 2^n
    dup 0 ?DO
      2dup I swap 
      2 spaces cbits type 2 spaces
      I swap prob f. cr
    LOOP  2drop ;

\ Create a named, uninitialized n-qubit ket state vector.
: ket ( n "name" -- )  2^ 1 xzmatrix ;

\ Create named dual n-qubit bra state vector.
: bra ( n "name" -- ) 1 swap 2^ xzmatrix ;

\ Create a named, uninitialized n-qubit unitary transformation
: gate ( n "name" -- ) 2^ dup xzmatrix ;

0 [IF]
\ Return flag indicating whether or not matrix object is unitary
: unitary? ( q -- flag )
    dup adjoint %*% identity? ;
[THEN]

\ Product of bra and ket vectors
: b*k ( q1 q2 -- z )
    2>r z=0 2r> 
    dup qdim 0 ?DO  \ -- q1 q2
      2>r 2r@ drop z@ 2r@ nip z@ z* z+
      2r> zfloat+ swap zfloat+ swap
    LOOP  2drop ;

\ Generic object matrix multiplication
: %*% ( q1 q2 -- q3|z )
    2dup >r dim r> dim >r <> Abort" Object sizes not compatible!"
    r>  \ -- q1 q2 nrow1 ncol2
    2dup 1 1 D= IF 
      2drop b*k
    ELSE
      alloc_xzmat \ -- a1 a2 a3
      >r >r   dup }}nrows swap 
      r>      dup }}nrows swap 
      r@ }}zmul r>
    THEN ;
 
\ Kronecker outer products of quantum states and gates.
: %x% ( q1 q2 -- q3 )
    2dup >r dim r> dim    \ -- o1 o2 nrows1 ncols1 nrows2 ncols2
    >r swap >r * r> r> *  \ -- o1 o2 nrows1*nrows2 ncols1*ncols2
    alloc_xzmat >r        \ -- o1 o2  r: o3
    >r dup }}nrows swap
    r> dup }}nrows swap
    r@ }}zkron r> ;

\ Predefined single and two-qubit states and their adjoints
1 ket |0>   z=1 z=0 |0> q! 
1 ket |1>   z=0 z=1 |1> q! 

1 bra <0|  |0> adjoint <0| ->
1 bra <1|  |1> adjoint <1| ->

\ Compose two-qubit states out of Kronecker products of 1-qubit states
2 ket |00>   |0> |0> %x%  |00> ->
2 ket |01>   |0> |1> %x%  |01> ->
2 ket |10>   |1> |0> %x%  |10> ->
2 ket |11>   |1> |1> %x%  |11> ->

2 bra <00|   |00> adjoint <00| ->
2 bra <01|   |01> adjoint <01| ->
2 bra <10|   |10> adjoint <10| ->
2 bra <11|   |11> adjoint <11| ->
 
\ Single qubit operators and gates: P0, P1, I1, X, Y, Z, S, T, H

1 gate P0  |0> <0| %*% P0 ->  \ projection operator |0><0|
1 gate P1  |1> <1| %*% P1 ->  \ projection operator |1><1|
1 gate I1  P0 P1 q+ I1 ->
1 gate X   z=0 z=1 z=1 z=0  X q!
1 gate Y   z=0 z=i znegate z=i z=0 Y q!
1 gate Z   z=1 z=0 z=0 z=1 znegate Z q!
1 gate S   z=1 z=0 z=0 z=i  S q!
1 gate T   z=1 z=0 z=0 pi 4e f/ fsincos fswap T q!
1 gate H   X Z q+ H ->
1e 2e f/ fsqrt 2 H }}f*z

\ Two qubit gates: I2, U2CN, U2CNR, U2CZ, U2SW

2 gate I2     I1 dup %x% I2 ->
2 gate U2CX
z=1 z=0 z=0 z=0
z=0 z=1 z=0 z=0
z=0 z=0 z=0 z=1
z=0 z=0 z=1 z=0  U2CX q!   \ CNOT gate: q0=target, q1=control

2 gate U2CXR
z=1 z=0 z=0 z=0
z=0 z=0 z=0 z=1
z=0 z=0 z=1 z=0
z=0 z=1 z=0 z=0  U2CXR q!   \ CNOT gate: q0=control, q1=target

2 gate U2CZ
z=1 z=0 z=0 z=0
z=0 z=1 z=0 z=0
z=0 z=0 z=1 z=0
z=0 z=0 z=0 z=1 znegate U2CZ q! \ CZ gate: q0=target, q1=control

2 gate U2SW   \ two-qubit SWAP gate
z=1 z=0 z=0 z=0
z=0 z=0 z=1 z=0
z=0 z=1 z=0 z=0
z=0 z=0 z=0 z=1  U2SW q!

\ Examples:
\
\ 1) Simple one-qubit quantum circuit. Input state is |0>.
\ 
\    q0 |0> ---[H]---
\
\    Compute output state and probabilities for 0 and 1.
\
\    1 ket |a>         \ make a 1-qubit ket state called '|a>' 
\    H |0> %*% |a> ->  \ compute and store output state
\    <0| |a> %*% z.    \ print complex probability amplitude <0|a>
\    0 |a> prob f.    \ print probability of measuring c=0 for |a>
\    1 |a> prob f.    \ print probability of measuring c=1 for |a>
\
\ 2) Two-qubit quantum circuit with only single qubit gates
\
\    q1 |0> ---[H]---
\    
\    q0 |0> ---[X]---
\
\    2 ket |ba>
\    H |0> %*%  X |0> %*%  %x% |ba> ->  \ compute output state for circuit
\    H X %x% |00> %*% |ba> ->  \ alternate way to compute output state
\    <10| |ba> %*% |z|^2 f. \ print probability of measuring c=10 (binary)
\    |ba> all-prob    \ display probabilities for measuring all bit strings
\
\ 3) Two-qubit quantum circuit to generate entangled qubits.
\               :      
\    q1 ---[H]-----*-----
\               :  |
\    q0 ---[X]----[CX]---
\               :
\               1
\
\ Define the quantum circuit operations on an input state of 2 qubits to
\ transform it into the output state.
\
\    : qc ( qin[2] -- qout[2] )
\        H X %x%  \ compose the 2-qubit gate prior to 1; note the order.
\        swap %*%      \ apply to input state to give quantum state at 1
\        U2CX swap %*% \ apply CNOT gate to give output state
\    ;
\
\    |00> qc q.  \ print output state for input |00>
\    |01> qc q.  \   "                   "      |01>
\    |10> qc q.  \   "                   "      |10>
\    |11> qc q.  \   "                   "      |11>
\

