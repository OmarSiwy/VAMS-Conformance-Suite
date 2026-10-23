// IEEE 1364-2005 §11.6.6, p. 162: "Port connection rules require that a value
// receiver be a net or a structural net expression." ... "Primitive output
// and inout terminals shall be connected directly to 1-bit nets or 1-bit
// structural net expressions (see 12.3.9.2), with no intervening process that
// could alter the strength."
//
// r is a reg: a variable, not a net, so it cannot receive the and gate's
// output. Legal neighbour: terminal_and_port_connections.v, whose
// gate output is the wire y.
//! inherited IEEE 1364-2005 11.6.6
//! reject E1100
//! reject a gate's output terminal must be a net
//! neighbour terminal_and_port_connections.v
module b_11_6_6_primitive_output_to_reg_rejected;
  reg r;
  wire a;
  and g(r, a, a);
endmodule
