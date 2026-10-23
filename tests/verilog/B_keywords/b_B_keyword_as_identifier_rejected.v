// IEEE 1364-2005 Annex B, p. 510: "Keywords are predefined nonescaped
// identifiers that define Verilog language constructs." begin is on the list.
// §3.7.2, p. 14 (quoted for context): "Keywords are predefined nonescaped
// identifiers that are used to define the language constructs."
//
// `reg begin;` uses the nonescaped keyword begin as a variable name. Legal
// neighbour: b_B_keywords.v (`reg [3:0] \begin ;`).
//@ std 1364-2005
//! inherited IEEE 1364-2005 B
//! reject E0208
//! reject found `begin`
//! neighbour b_B_keywords.v
module b_B_keyword_as_identifier_rejected;
  reg begin;
  initial $display("unreachable");
endmodule
