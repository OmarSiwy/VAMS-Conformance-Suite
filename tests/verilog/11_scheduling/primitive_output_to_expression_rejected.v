// IEEE 1364-2005 §11.6.6, p. 162: "Primitive output and inout terminals shall
// be connected directly to 1-bit nets or 1-bit structural net expressions
// (see 12.3.9.2), with no intervening process that could alter the
// strength."
//
// ~y is an operator expression, not a net or a structural net expression
// (§12.3.9.2: a net, a constant bit-select or a part-select of one, or a
// concatenation of those), so it cannot be the
// and gate's output terminal. Legal neighbour:
// terminal_and_port_connections.v, whose gate output is the wire y.
//! inherited IEEE 1364-2005 11.6.6
//! reject E0207
//! reject a gate's output terminal is a net_lvalue
//! neighbour terminal_and_port_connections.v
module b_11_6_6_primitive_output_to_expression_rejected;
  wire y, a, b;
  and g(~y, a, b);
endmodule
