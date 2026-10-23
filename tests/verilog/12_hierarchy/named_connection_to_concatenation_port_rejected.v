// IEEE 1364-2005 §12.3.2, p. 174: "Named port connections shall not be used for
// implicit ports unless the port_expression is a simple identifier or escaped
// identifier, which shall be used as the port name." §12.3.3, p. 175, of
// complex_ports ({c,d}, .e(f)): "Can't use named port connections of first
// port."
//
// u connects complex_ports' first port, the implicit {c,d}, by the name c.
// Legal neighbour: explicit_port_names.v (named connections to
// explicit ports and to the simple implicit port en).
//! inherited IEEE 1364-2005 12.3.2 12.3.6
//! reject E1100
//! reject no such port
//! neighbour explicit_port_names.v
module complex_ports ({c,d}, .e(f));
  input [1:0] c, d;
  output [3:0] f;
  assign f = {d, c};
endmodule
module b_12_3_2_named_connection_to_concatenation_port_rejected;
  wire [3:0] cf;
  complex_ports u1(.c(2'b10), .e(cf));
endmodule
