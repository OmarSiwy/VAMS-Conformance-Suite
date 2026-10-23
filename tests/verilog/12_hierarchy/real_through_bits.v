// IEEE 1364-2005 §12.3.7, p. 178: "The real data type shall not be directly
// connected to a port. It shall be connected indirectly, as shown in the
// following example. The system functions $realtobits and $bitstoreal shall be
// used for passing the bit patterns across module ports."
//
// The clause's driver/receiver pair (its receiver's `initial assign r = ...`
// kept), joined by a 64-bit net. driver sets r = 2.5 at t = 0; net_r carries
// its 64-bit pattern; receiver's r follows $bitstoreal of it, so at t = 1
// receiver prints 2.5 (%f -> 2.500000).
// The clause's port declarations are scalar (`output net_r;`, `input net_r;`)
// while their nets are [64:1], which §12.3.3 (p. 174) forbids: "If the net or
// variable is declared as a vector, the range specification between the two
// declarations of a port shall be identical." Both port declarations carry
// [64:1] here.
//! inherited IEEE 1364-2005 12.3.7
`timescale 1ns/1ns
module driver (net_r);
  output [64:1] net_r;
  real r;
  wire [64:1] net_r = $realtobits(r);
  initial r = 2.5;
endmodule
module receiver (net_r);
  input [64:1] net_r;
  wire [64:1] net_r;
  real r;
  initial assign r = $bitstoreal(net_r);
  initial #1 $display("%f", r);
endmodule
module b_12_3_7_real_through_bits;
  wire [64:1] w;
  driver d(w);
  receiver q(w);
endmodule
