// IEEE 1364-2005 §3.7, p. 14: "The first character of a simple identifier
// shall not be a digit or $; it can be a letter or an underscore."
//
// $abc begins with $ (a system name, §3.7.3, never a variable). Legal
// neighbour: identifier_examples.v, whose _bus3 begins with an
// underscore and n$657 holds $ after its first character.
//! inherited IEEE 1364-2005 3.7
//! reject E0208
//! reject expected an identifier: found $abc
//! neighbour identifier_examples.v
module b_3_7_leading_dollar_rejected;
  reg $abc;
  initial $display("unreachable");
endmodule
