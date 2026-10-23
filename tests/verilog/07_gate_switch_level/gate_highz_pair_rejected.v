// IEEE 1364-2005 §7.9, p. 87: "The combinations (highz0, highz1) and (highz1,
// highz0) shall be considered illegal." §7.1.2, p. 77: "The strength
// specifications (highz0, highz1) and (highz1, highz0) shall be considered
// invalid."
//
// A gate whose both strengths are high impedance. Legal neighbour: the
// (weak1, highz0) assignment in strength_levels.v.
//! inherited IEEE 1364-2005 7.9 7.1.2
//! reject E0207
//! reject both drive strengths cannot be high impedance
//! neighbour strength_levels.v
module b_7_9_gate_highz_pair_rejected;
  reg a, b;
  wire o;
  and (highz1, highz0) g(o, a, b);
  initial $finish(0);
endmodule
