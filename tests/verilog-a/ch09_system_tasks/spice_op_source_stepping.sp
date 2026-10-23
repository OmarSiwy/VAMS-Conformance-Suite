* LRM 9.15 Table 9-27 sourceScaleFactor, "Multiplicative factor for
* independent sources for source stepping homotopy": the factor a host steps
* from 0 to 1 when neither plain Newton nor gmin stepping solves the
* operating point. VerA's Annex E sources multiply their value by it.
*
* 5 V through 1 ohm into is*(exp(v/vt) - 1), is = 1e-14, vt = 0.025, with no
* $limit. From the cold start Newton's first iterate puts V(a) near 5 V and
* each later step comes down about vt, (5 - 0.84)/0.025 ~ 165 steps to the
* knee: more than plain Newton's 100 (itl1), and more than each gmin step's
* 50 (itl2), whose gmin <= 1e-2 S cannot pull a node 1 ohm holds. Source
* stepping starts from every source at 0, where 0 V everywhere is exact,
* and raises the 5 V a step at a time from the last solution.
*
* The answer, by hand: the root of (5 - v)/1 = 1e-14*(exp(v/0.025) - 1),
* V(a) = 0.8415334423073747 (Newton in python3, 300 iterations from 0.9), and
* V(in) = 5. No charge, so every transient row repeats it. At t = 0 the
* published point is Newton's last linearization point, inside SPICE's
* reltol of the root (atol 1e-3); each transient point re-solves from the
* last, so the samples inside the run are held to 1e-6. A runner that left
* the factor at 0.9375 (its last step before 1) gets 0.83959, outside both.
* Expected results: spice_op_source_stepping.expected.json
.hdl "spice_op_exp_junction.va"
V1 in 0 DC 5
R1 in a 1
N1 a 0 spice_op_exp_junction
.tran 1e-4 1e-3
.end
