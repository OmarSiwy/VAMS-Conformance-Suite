// IEEE 1364-2005 §3.7, p. 14: "The first character of a simple identifier
// shall not be a digit or $; it can be a letter or an underscore."
//
// 1abc begins with a digit. Legal neighbour: identifier_examples.v,
// whose n$657 holds a digit and a $ after its first character.
//! inherited IEEE 1364-2005 3.7
//! reject E0208
//! reject expected an identifier
//! neighbour identifier_examples.v
module b_3_7_leading_digit_rejected;
  reg 1abc;
  initial $display("unreachable");
endmodule
