// IEEE 1364-2005 §12.3.3, p. 174: "Each port_identifier in a port_expression in
// the list of ports for the module declaration shall also be declared in the
// body of the module as one of the following port declarations: input,
// output, or inout (bidirectional)." §12.1, p. 163: "The identifiers in this
// list shall be declared in input, output, and inout statements within the
// module definition."
//
// m lists b but declares no direction for it. Legal neighbour:
// module_header_forms.v (b_12_1_plain declares both a and y).
//! lrm 6.2
//! lrm 6.2:5
//! lrm 6.5.2.2
//! lrm 6.5.2.2:1
//! inherited IEEE 1364-2005 12.3.3 12.1
//! reject E1100
//! reject has no direction declaration
//! neighbour module_header_forms.v
module m(a, b);
  input a;
endmodule
module b_12_3_3_listed_port_undeclared_rejected;
  wire p, q;
  m u(p, q);
endmodule
