// IEEE 1364-2005 §12.1.2, p. 166: "The list of port connections shall be
// provided only for modules defined with ports. The parentheses, however, are
// always required."
//
// noports has no ports; u gives it a connection (w). Legal neighbour:
// module_header_forms.v instantiates b_12_1_noports as u3() with no
// connection.
//! lrm 6.2.2
//! lrm 6.2.2:1
//! inherited IEEE 1364-2005 12.1.2
//! reject E1100
//! reject more port connections than the module has ports
//! neighbour module_header_forms.v
module noports;
  initial $display("x");
endmodule
module b_12_1_2_connections_to_portless_module_rejected;
  wire w;
  noports u(w);
endmodule
