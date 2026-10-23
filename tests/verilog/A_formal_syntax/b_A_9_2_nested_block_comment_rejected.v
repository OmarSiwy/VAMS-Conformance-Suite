// IEEE 1364-2005 A.9.2, p. 508:
//   block_comment ::= /* comment_text */
// A block comment ends at the first `*/`: comment_text cannot contain the
// closing delimiter, so block comments do not nest. §3.3, p. 8 (quoted for
// context): "Block comments shall not be nested."
//
// In `/* outer /* inner */ tail */`, the comment ends after `inner`, and
// `tail */` is left as source text, which derives nothing. Legal neighbour:
// b_A_9_2_comments.v.
//! inherited IEEE 1364-2005 A.9.2
//! reject E0240
//! reject not a module item: found tail
//! neighbour b_A_9_2_comments.v
module b_A_9_2_nested_block_comment_rejected;
  /* outer /* inner */ tail */
  initial $display("unreachable");
endmodule
