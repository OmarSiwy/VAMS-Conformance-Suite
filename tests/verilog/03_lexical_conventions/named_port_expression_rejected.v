// IEEE 1364-2005 §3.8.2, p. 20, Syntax 3-8: "named_port_connection ::=
// { attribute_instance } . port_identifier ( [ expression ] )"
//
// The attribute goes before .i; inside the parentheses only an expression
// is allowed, and an expression cannot begin with an attribute (§3.8). Legal
// neighbour: attribute_positions.v, which writes (* k *) .i(r).
//! inherited IEEE 1364-2005 3.8.2
//! reject E0209
//! reject expected an expression: found `(*`
//! neighbour attribute_positions.v
module b_3_8_2_named_port_expression_rejected_child (input i, output o);
  assign o = i;
endmodule
module b_3_8_2_named_port_expression_rejected;
  reg r;
  wire w;
  b_3_8_2_named_port_expression_rejected_child c (.i((* k *) r), .o(w));
  initial $display("unreachable");
endmodule
