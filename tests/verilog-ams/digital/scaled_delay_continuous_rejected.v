// AMS §2.6.2's restriction includes A.6.1's continuous-assignment delay3.
// A scale factor is forbidden in the fall delay as well as the rise delay.
// Legal neighbour: digital_delay_primitive_notation.v runs assign #2.5e-1.
//! lrm 2.6.2
//! lrm 2.6.2:3
//! reject E0247
//! neighbour digital_delay_primitive_notation.v
module scaled_delay_continuous_rejected;
  wire q;
  assign #(1, 2u) q = 0;
endmodule
