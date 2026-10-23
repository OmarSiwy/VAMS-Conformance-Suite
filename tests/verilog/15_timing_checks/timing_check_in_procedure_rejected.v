// IEEE 1364-2005 §15.1, p. 240: "Although they begin with a $, timing checks
// are not system tasks." ... "In particular, no system task can appear in a
// specify block, and no timing check can appear in procedural code."
//
// $setup(d, clk, 2) is written as a statement of an initial block. Legal
// neighbour: timing_check_forms.v, the same check in a specify
// block.
//! inherited IEEE 1364-2005 15.1
//! reject timing check
//! neighbour timing_check_forms.v
`timescale 1ns/1ns
module b_15_1_timing_check_in_procedure_rejected;
  reg d, clk;
  initial begin
    d = 0;
    clk = 0;
    $setup(d, clk, 2);
  end
endmodule
