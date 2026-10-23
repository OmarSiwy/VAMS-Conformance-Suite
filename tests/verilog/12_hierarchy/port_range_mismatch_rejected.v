// IEEE 1364-2005 §12.3.3, p. 174: "If a port declaration does not include a net
// or variable type, then the port can be again declared in a net or variable
// declaration. If the net or variable is declared as a vector, the range
// specification between the two declarations of a port shall be identical."
//
// a is declared input [7:0] and then wire [3:0]. Legal neighbour:
// port_signed_inheritance.v (input [7:0] b; wire signed [7:0] b).
//! lrm 6.5.2.2
//! lrm 6.5.2.2:2
//! inherited IEEE 1364-2005 12.3.3
//! reject E1100
//! reject range differs from its port declaration
//! neighbour port_signed_inheritance.v
module m(a, y);
  input [7:0] a;
  wire [3:0] a;
  output y;
  assign y = a[0];
endmodule
module b_12_3_3_port_range_mismatch_rejected;
  wire [7:0] p;
  wire q;
  m u(p, q);
endmodule
