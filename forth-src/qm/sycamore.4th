\ sycamore.4th
\
\ Simulate the unit cell of the Sycamore processor
\
\ K. Myneni, 2019-11-09
\
\ References:
\   1. F. Arute, et al., Nature vol. 574, pp. 505--511 (2019).
\   2. F. Arute, et al., Supplementary Information to [1]. 
\
\  Requires: qcsim.4th
\               A       B       C       D       C       D       A       B
\               :       :       :       :       :       :       :       :
\  q4 |0>--[3]-----[?]-----[?]-[x]-[?]-----[?]-[x]-[?]-----[?]-----[?]-----
\               :       :       |       :       |       :       :       :
\  q3 |0>--[1]-[x]-[?]-----[?]--|--[?]-----[?]--|--[?]-----[?]-[x]-[?]-----
\               |       :       |       :       |       :       |       :
\  q2 |0>--[1]-[x]-[?]-[x]-[?]-[x]-[?]-[x]-[?]-[x]-[?]-[x]-[?]-[x]-[?]-[x]-
\               :       |       :       |       :       |       :       |
\  q1 |0>--[3]-----[?]-[x]-[?]-----[?]--|--[?]-----[?]--|--[?]-----[?]-[x]-
\               :       :       :       |       :       |       :       :
\  q0 |0>--[2]-----[?]-----[?]-----[?]-[x]-[?]-----[?]-[x]-[?]-----[?]-----
\               :       :       :       :       :       :       :       :
\               A       B       C       D       C       D       A       B   
\  One-Qubit Gates:
\
\  [1] = SQRTX
\  [2] = SQRTY
\  [3] = SQRTW
\
\  [x] = 2-qubit iSWAP 
\
\  The Sycamore uses a hybrid iSWAP + controlled phase gate, called
\  an fSim gate [2]; the full iSWAP is fine for our purposes.
\   
include qm/qcsim.4th
include qm/bket.4th
include qm/iswap.4th

1 gate W      1/sqrt2 X Y q+ f*q  W ->
1 gate SQRTW
z=1 z=sqrti znegate
z=sqrt-i z=1  SQRTW q!
1/sqrt2 SQRTW f*q SQRTW ->

\ The input state to the random circuit cycle is defined below
5 ket |in> 
  SQRTW  SQRTX %x% SQRTX %x% SQRTW  %x% SQRTY %x%
  |00000> %*% |in> ->

5 gate UA  2 3 5 U_isw  UA ->
5 gate UB  2 1 5 U_isw  UB ->
5 gate UC  2 4 5 U_isw  UC ->
5 gate UD  2 0 5 U_isw  UD ->

\ Test case:
\
\ We will first run a simulation with a hand-picked
\ selection of gates
\ 
\  q4 |0>--[3]-----[1]-----[3]-[x]-[2]-----[1]
\                               |
\  q3 |0>--[1]-[x]-[2]-----[3]--|--[1]-----[3]
\               |               |
\  q2 |0>--[1]-[x]-[2]-[x]-[1]-[x]-[3]-[x]-[2]
\               :       |       :       |
\  q1 |0>--[3]-----[1]-[x]-[2]-----[1]--|--[2]
\               :       :       :       |
\  q0 |0>--[2]-----[1]-----[2]-----[1]-[x]-[3]
\               :       :       :       :
\               A       B       C       D

\ The gate for the above "random" circuit test case, starting
\ at A is given below
5 gate U5RQC1
  UA           \ A
  SQRTX SQRTY %x% SQRTY %x% SQRTX %x% SQRTX %x%
  swap %*%  
  UB swap %*%  \ B
  SQRTW SQRTW %x% SQRTX %x% SQRTY %x% SQRTY %x%
  swap %*%
  UC swap %*%  \ C
  SQRTY SQRTX %x% SQRTW %x% SQRTX %x% SQRTX %x%
  swap %*%
  UD swap %*%  \ D
  SQRTX SQRTW %x% SQRTY %x% SQRTY %x% SQRTW %x%
  swap %*%
  U5RQC1 ->

5 ket |out>
U5RQC1 |in> %*% |out> ->
\ |out> all-prob

\ Random gate selection 

3 integer array RQC_gates{
RQC_gates{ 
SQRTX over ! cell+
SQRTY over ! cell+ 
SQRTW swap ! 

1e 3e f/ fconstant 1/3
2e 3e f/ fconstant 2/3

\ Return a random 1-qubit gate from the set of 3, 1-qubit gates,
\ stored in RQC_gates{
: Random1G ( -- q )
    ran0
    fdup 1/3 f< IF fdrop 0 
    ELSE
      2/3 f< IF 1 ELSE 2 THEN
    THEN
    RQC_gates{ swap } a@ ;

\ Generate a random n-qubit gate by taking the outer product
\   of n, 1-qubit gates
: nRandom1G ( n -- q )
    dup MAXN > Abort" Dimensionality is too large!"
    one swap 0 ?DO  Random1G swap %x%  LOOP ;

\ Full cycle (m=1) random circuit. We will not enforce the rule that
\ two sequential single-qubit gates cannot be the same, as restricted
\ in [1--2]. 

\ Return the 5-qubit gate for a random circuit executing one 
\ full cycle (m=1), ABCDCDAB.
: ABCDCDAB ( -- qgate )
    UA           5 nRandom1G swap %*%
    UB swap %*%  5 nRandom1G swap %*%
    UC swap %*%  5 nRandom1G swap %*%
    UD swap %*%  5 nRandom1G swap %*%
    UC swap %*%  5 nRandom1G swap %*%
    UD swap %*%  5 nRandom1G swap %*%
    UA swap %*%  5 nRandom1G swap %*%
    UB swap %*%  5 nRandom1G swap %*% ;

\ Return a gate for m cycles of ABCDCDAB
: cycles ( m -- qgate )
    ABCDCDAB swap 1- 0 ?DO ABCDCDAB swap %*%  LOOP ;

cr
cr .( Computing bit string probabilities for 10-cycles of 5-qubit)
cr .( random quantum circuit: "10 cycles |in> %*% show-prob" )
cr
10 cycles |in> %*% show-prob


