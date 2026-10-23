// IEEE 1364-2005 §12.3.9.2, p. 179: "The following external items shall not be
// connected to the output or inout ports of modules: ... - Expressions other
// than the following: - A scalar net - A vector net - A constant bit-select of
// a vector net - A part-select of a vector net - A concatenation of the
// expressions listed above".
//
// m's output y is connected to w1 & w2, an operator expression. Legal
// neighbour: structural_sinks_and_expression_sources.v (a
// concatenation of nets and whole vector nets).
//! inherited IEEE 1364-2005 12.3.9.2
//! reject E1100
//! reject an output port connects to a net
//! neighbour structural_sinks_and_expression_sources.v
module m(a, y);
  input a;
  output y;
  assign y = a;
endmodule
module b_12_3_9_2_output_to_expression_rejected;
  reg r;
  wire w1, w2;
  m u(r, w1 & w2);
endmodule
