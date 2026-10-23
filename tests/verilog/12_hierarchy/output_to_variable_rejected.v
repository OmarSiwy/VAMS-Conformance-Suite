// IEEE 1364-2005 §12.3.9.2, p. 179: "Only nets or structural net expressions
// shall be the sinks in an assignment." ... "The following external items
// shall not be connected to the output or inout ports of modules: - Variables".
// §12.3.8, p. 179: "the item receiving the value through the port (the
// internal item for inputs, the external item for outputs) shall be a
// structural net expression."
//
// m's output y is connected to the reg q. Legal neighbour:
// structural_sinks_and_expression_sources.v (outputs into nets).
//! inherited IEEE 1364-2005 12.3.9 12.3.9.2 12.3.8
//! reject E1100
//! reject an output port can only drive a net
//! neighbour structural_sinks_and_expression_sources.v
module m(a, y);
  input a;
  output y;
  assign y = a;
endmodule
module b_12_3_9_2_output_to_variable_rejected;
  reg r;
  reg q;
  m u(r, q);
endmodule
