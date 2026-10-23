// IEEE 1364-2005 §12.3.7, p. 178: "The real data type shall not be directly
// connected to a port."
//
// The real variable r is the connection to m's input a. Legal neighbour:
// real_through_bits.v (the bits of a real, via $realtobits).
//! inherited IEEE 1364-2005 12.3.7
//! reject E1100
//! reject a real cannot be connected to a port
//! neighbour real_through_bits.v
module m(a, y);
  input a;
  output y;
  assign y = a;
endmodule
module b_12_3_7_real_connected_to_port_rejected;
  real r;
  wire w;
  m u(r, w);
endmodule
