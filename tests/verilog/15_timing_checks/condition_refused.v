// IEEE 1364-2005 §15.5.2: the negative timing check's timestamp condition and
// timecheck condition, the sixth and seventh arguments of $setuphold and
// $recrem. "The timestamp condition and the timecheck condition can be used to
// control the operation of the timing check", the delayed signals of §15.5.1
// pairing with them, all for the negative timing checks of §15.8.
//
// VerA's digital engine does not evaluate it, so it refuses the design by name
// (E1149) rather than run a check that would never report; CLAUSES.tsv keeps
// §15.5.2 not-supported. The refusal names the argument, so the fixture pins
// that the sixth argument is what the engine declines, not the check as a
// whole: the same $setuphold without it runs (setuphold.v).
//! inherited IEEE 1364-2005 15.5.1 15.5.2
//! reject-only E1149
//! reject argument 6
//! neighbour setuphold.v
`timescale 1ns/1ns
module b_15_5_2_condition_refused(clk, d, en);
  input clk, d, en;
  reg ntfr;
  specify
    $setuphold(posedge clk, d, 4, 2, ntfr, en);
  endspecify
endmodule
