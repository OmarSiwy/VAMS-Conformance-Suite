// IEEE 1364-2005 §3.7.2, p. 15: "Keywords are predefined nonescaped
// identifiers that are used to define the language constructs. A Verilog HDL
// keyword preceded by an escape character is not interpreted as a keyword."
//
// Unescaped, wire is the net-type keyword and cannot name a reg. Legal
// neighbour: escaped_keyword.v, which declares \wire .
//! inherited IEEE 1364-2005 3.7.2
//! reject E0208
//! reject expected an identifier: found `wire`
//! neighbour escaped_keyword.v
module b_3_7_2_keyword_as_identifier_rejected;
  reg wire;
  initial $display("unreachable");
endmodule
