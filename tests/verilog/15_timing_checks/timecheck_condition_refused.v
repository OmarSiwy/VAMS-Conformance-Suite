// IEEE 1364-2005 §15.5.1: "To facilitate these modeling requirements, delayed
// copies of the data and reference signals are generated in the timing
// checks ... The setup and hold times used internally are adjusted to shift
// the violation window", and "The delayed timing check signals are only
// actually delayed when negative limit values are present." With the
// non-negative limits here, the delayed reference signal `dclk` (argument 8)
// is `clk` itself, which VerA evaluates (neighbour
// setuphold_delayed_args.v).
//
// What VerA's digital engine does not evaluate is §15.5.2's timecheck
// condition, the seventh argument, so it refuses the design by name (E1149)
// at that argument rather than run a check that ignores it. The timestamp
// condition (argument 6) is condition_refused.v.
//! inherited IEEE 1364-2005 15.5.1 15.5.2
//! reject-only E1149
//! reject argument 7
//! neighbour setuphold_delayed_args.v
`timescale 1ns/1ns
module b_15_5_1_timecheck_condition_refused(clk, clkb, d);
  input clk, clkb, d;
  reg ntfr;
  wire dclk;
  specify
    $setuphold(posedge clk, d, 2, 5, ntfr, , d, dclk);
  endspecify
endmodule
