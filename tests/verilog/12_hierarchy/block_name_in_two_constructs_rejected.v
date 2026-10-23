// IEEE 1364-2005 §12.4.2, p. 187: "It is not permissible for any of the named
// generate blocks to have the same name as generate blocks in any other
// conditional or loop generate construct in the same scope, even if the blocks
// with the same name are not selected for instantiation." §12.7, p. 195: "For
// generate blocks, this rule applies regardless of whether the generate block
// is instantiated."
//
// Two separate if-generate constructs each name a block u1; only one is
// selected, which does not make it legal. Legal neighbour:
// direct_nesting_and_recursion.v (every u1 inside one directly nested
// construct).
//! lrm 6.6.2
//! lrm 6.6.2:2
//! inherited IEEE 1364-2005 12.4.2 12.7
//! reject E0230
//! reject a generate block name collides with another declaration
//! neighbour direct_nesting_and_recursion.v
module b_12_4_2_block_name_in_two_constructs_rejected;
  parameter p = 0;
  if (p) begin : u1
    initial $display("a");
  end
  if (!p) begin : u1
    initial $display("b");
  end
endmodule
