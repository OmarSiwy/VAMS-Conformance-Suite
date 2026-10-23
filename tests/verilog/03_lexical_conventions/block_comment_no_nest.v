//! inherited IEEE 1364-2005 3.3
// Block comments do not nest: each `/*` inside one is plain text and the
// comment ends at the first `*/` (comment1).
/* )* */
/* (* /* *) */
module triage_block_comment_no_nest;
  initial $display("PASSED");
endmodule
