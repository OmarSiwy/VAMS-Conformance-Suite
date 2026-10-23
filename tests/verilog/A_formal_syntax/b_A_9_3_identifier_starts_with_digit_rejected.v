// IEEE 1364-2005 A.9.3, p. 508-509:
//   simple_identifier ::= [ a-zA-Z_ ] { [ a-zA-Z0-9_$ ] }
// Details, p. 509: "3) A simple_identifier shall start with an alpha or
// underscore (_) character, shall have at least one character, and shall not
// have any spaces."
//
// `reg 9r;` names a variable with an identifier that starts with a digit.
// Legal neighbour: grammar_escaped_system_name.v and every other
// fixture here (`reg [3:0] a, b;`); `\9r ` would be a legal escaped name.
//! inherited IEEE 1364-2005 A.9.3
//! reject E0208
//! reject expected an identifier: found 9
//! neighbour grammar_escaped_system_name.v
module b_A_9_3_identifier_starts_with_digit_rejected;
  reg 9r;
  initial $display("unreachable");
endmodule
