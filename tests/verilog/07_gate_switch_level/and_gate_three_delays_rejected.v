// IEEE 1364-2005 §7.2, p. 80: "The delay specification shall be zero, one, or
// two delays." Syntax 7-1: n_input_gatetype [drive_strength] [delay2].
//
// An and gate with three delays. Legal neighbour: and #(10,12) in
// gate_delays.v.
//! inherited IEEE 1364-2005 7.2
//! reject E0210
//! reject expected ')'
//! neighbour gate_delays.v
module b_7_2_three_delays_rejected;
  reg a, b;
  wire o;
  and #(1,2,3) g(o, a, b);
  initial $finish(0);
endmodule
