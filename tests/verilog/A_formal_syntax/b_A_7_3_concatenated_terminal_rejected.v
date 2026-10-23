// IEEE 1364-2005 A.7.3, p. 500:
//   specify_input_terminal_descriptor ::= input_identifier [ [ constant_range_expression ] ]
// A path terminal is a port identifier with at most one select; a
// concatenation of ports is not a terminal descriptor (A.7.2's lists are
// written with commas instead).
//
// `({a, b} *> y) = 1;` uses a concatenation as a path input. Legal
// neighbour: b_A_7_3_specify_terminals.v (`(a[3:2] *> y[3:2]) = 3;`).
//! inherited IEEE 1364-2005 A.7.3
//! reject E0208
//! reject expected an identifier: found `{`
//! neighbour b_A_7_3_specify_terminals.v
module b_A_7_3_concatenated_terminal_rejected (a, b, y);
  input a, b;
  output y;
  assign y = a & b;
  specify
    ({a, b} *> y) = 1;
  endspecify
endmodule
