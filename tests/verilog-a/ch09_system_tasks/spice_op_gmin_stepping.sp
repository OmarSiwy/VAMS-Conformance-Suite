* LRM 9.15 Table 9-27 gmin, "Minimum conductance placed in parallel with
* nonlinear branches": the conductance a host steps (ngspice dynamic_gmin)
* when plain Newton cannot solve the operating point.
*
* in --[k*v^3]-- mid --[k*v^3]-- 0, from a 1 V source, k = 1e-3 A/V^3.
* Each conductance is 3k*v^2, zero at v = 0, so at the SPICE cold start
* (every node 0 V) the mid row and column of the Newton matrix are all zero:
* the first factorization is singular and plain Newton has no step. With gmin
* on every node the matrix is regular, the stepped solves walk gmin down from
* 1e-3 to 1e-12, and the last solve, without gmin, starts beside the answer.
*
* The answer, by hand: one current through both, k(1 - m)^3 = k*m^3, so
* 1 - m = m and V(mid) = 0.5 exactly, V(in) = 1 (the source). The circuit
* holds no charge, so every transient row repeats the operating point.
* Tolerance 1e-6: the published point is Newton's last linearization point,
* within SPICE's reltol of the root; a runner that left gmin = 1e-3 in the
* answer gets (1 - m)^3 = m^3 + m, m = 0.3059 (python3 bisection).
* Expected results: spice_op_gmin_stepping.expected.json
.hdl "spice_op_cubic_conductance.va"
V1 in 0 DC 1
N1 in mid spice_op_cubic_conductance
N2 mid 0 spice_op_cubic_conductance
.tran 1e-4 1e-3
.end
