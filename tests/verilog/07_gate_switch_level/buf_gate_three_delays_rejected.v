// IEEE 1364-2005 §7.3, p. 81: "The delay specification shall be zero, one, or
// two delays." Syntax 7-1: n_output_gatetype [drive_strength] [delay2].
//
// A buf with three delays. Legal neighbours: the undelayed buf in
// every_primitive.v and the two-delay and in gate_delays.v.
//! inherited IEEE 1364-2005 7.3
//! reject E0210
//! reject expected ')'
//! neighbour every_primitive.v
//! neighbour gate_delays.v
module b_7_3_three_delays_rejected;
  reg a;
  wire o;
  buf #(1,2,3) g(o, a);
  initial $finish(0);
endmodule
