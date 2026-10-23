// IEEE 1364-2005 A.6.3, p. 497-498:
//   par_block ::= fork [ : block_identifier { block_item_declaration } ] { statement } join
//   seq_block ::= begin [ : block_identifier { block_item_declaration } ] { statement } end
//
// A named seq_block declaring integer k, real x and time t; inside it a named
// par_block declaring integer m, whose two statements run in parallel. The
// second branch waits #1 before reading m, so it runs after the first branch
// whatever order §11 picks for two statements at one time: k = 2,
// x = k * 1.5 = 3.0, t = 7; the fork sets m = 4, then k = k + m = 6.
// (A reg declared in a named block is b_A_6_3_named_block_reg.v.)
// Output: "k=6 x=3.0 t=7".
//! inherited IEEE 1364-2005 A.6.3
`timescale 1ns/1ns
module b_A_6_3_named_block_declarations;
  initial begin : blk
    integer k;
    real x;
    time t;
    k = 2;
    x = k * 1.5;
    t = 7;
    fork : par
      integer m;
      m = 4;
      #1 k = k + m;
    join
    $display("k=%0d x=%.1f t=%0d", k, x, t);
    $finish(0);
  end
endmodule
