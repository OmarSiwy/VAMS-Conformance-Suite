// IEEE 1364-2005 A.9.3, p. 508:
//   hierarchical_identifier ::= { identifier [ [ constant_expression ] ] . } identifier
// A hierarchical name's scopes may carry a constant index, naming one block
// of a loop generate (§12.4.1) or one instance of an array.
//
// A loop generate declares a wire w in each of blk[0] and blk[1], set to
// g + 5; the top reads them as blk[0].w and blk[1].w: 5 and 6.
// Output: "w0=5 w1=6".
//! inherited IEEE 1364-2005 A.9.3
`timescale 1ns/1ns
module b_A_9_3_indexed_hierarchical_name;
  genvar g;
  for (g = 0; g < 2; g = g + 1) begin : blk
    wire [3:0] w = g + 5;
  end
  initial #1 begin
    $display("w0=%0d w1=%0d", blk[0].w, blk[1].w);
    $finish(0);
  end
endmodule
