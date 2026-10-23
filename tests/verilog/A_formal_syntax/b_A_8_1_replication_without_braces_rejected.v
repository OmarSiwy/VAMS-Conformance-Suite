// IEEE 1364-2005 A.8.1, p. 504:
//   multiple_concatenation ::= { constant_expression concatenation }
//   concatenation ::= { expression { , expression } }
// The replicated part is itself a concatenation, with its own braces.
//
// `{2 a}` has the multiplier but no inner braces. Legal neighbour:
// b_A_8_1_concatenations.v (`{2{a}}`).
//! inherited IEEE 1364-2005 A.8.1
//! reject E0207
//! reject unexpected token: found a
//! neighbour b_A_8_1_concatenations.v
module b_A_8_1_replication_without_braces_rejected;
  reg [1:0] a;
  initial begin
    a = 2'b10;
    $display("%b", {2 a});
  end
endmodule
