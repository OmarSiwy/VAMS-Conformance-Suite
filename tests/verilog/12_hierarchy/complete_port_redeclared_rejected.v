// IEEE 1364-2005 §12.3.3, p. 174: "If a port declaration includes a net or
// variable type, then the port is considered completely declared, and it is an
// error for the port to be declared again in a variable or net data type
// declaration."
//
// `output reg y` includes the variable type, so the following `reg y` is the
// error. Legal neighbour: port_signed_inheritance.v (`output [7:0] f`
// with no type, then `reg signed [7:0] f`).
//! inherited IEEE 1364-2005 12.3.3
//! reject E1100
//! reject duplicate digital variable
//! neighbour port_signed_inheritance.v
module m(a, y);
  input a;
  output reg y;
  reg y;
  always @* y = a;
endmodule
module b_12_3_3_complete_port_redeclared_rejected;
  wire p, q;
  m u(p, q);
endmodule
