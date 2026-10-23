// IEEE 1364-2005 §12.3.1, p. 173, Syntax 12-3: "port ::= [ port_expression ] |
// . port_identifier ( [ port_expression ] ) port_expression ::= port_reference
// | { port_reference { , port_reference } } port_reference ::= port_identifier
// [ [ constant_range_expression ] ]".
//
// a + b is no port_reference: a port expression is an identifier, a select of
// one, or a concatenation of them, never an operator. Legal neighbour:
// module_header_forms.v (b_12_1_plain(a, y)).
//! lrm 6.5.1
//! lrm 6.5.1:1
//! inherited IEEE 1364-2005 12.3.1
//! reject E0207
//! reject unexpected token: found `+`
//! neighbour module_header_forms.v
module m(a + b);
  input a, b;
endmodule
module b_12_3_1_port_expression_operator_rejected;
  m u(1'b1);
endmodule
