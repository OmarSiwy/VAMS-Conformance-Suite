// IEEE 1364-2005 §12.1, p. 163: "Ports declared in the list of port
// declarations shall not be redeclared within the body of the module."
// §12.3.4, p. 176, in the clause's example: "It is illegal to redeclare any
// ports of the module in the body of the module."
//
// m declares a in its list of port declarations and again as a wire in its
// body. Legal neighbour: module_header_forms.v (b_12_1_adder declares
// its ports only in the header).
//! lrm 6.2
//! lrm 6.2:6
//! inherited IEEE 1364-2005 12.1 12.3.4
//! reject E0218
//! reject port redeclared in the module body
//! neighbour module_header_forms.v
module m(input a, output y);
  wire a;
  assign y = a;
endmodule
module b_12_1_ansi_port_redeclared_rejected;
  wire p, q;
  m u(p, q);
endmodule
