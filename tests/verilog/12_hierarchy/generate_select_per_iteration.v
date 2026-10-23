// IEEE 1364-2005 §12.4.1: in each iteration of a loop generate the genvar is
// "a localparam" of that iteration's block, so every constant it appears in
// is folded per ITERATION. §5.2.1: a part-select's bounds are constant
// expressions, and bus[i*4+3:i*4] selects bits i*4+3 down to i*4.
//
// bus = 8'b1010_0101:
//   g[0]: bus[3:0] = 0101
//   g[1]: bus[7:4] = 1010
// Each leaf prints at its own delay #(i+1), so the order is not a race.
// Folding the bounds once for the one ExprId both iterations share gives
// g[1] the first iteration's bits: 0101 twice.
//! inherited IEEE 1364-2005 12.4.1 5.2.1
module leaf(input [3:0] x);
  parameter ID = 1;
  initial #ID $display("%m x=%b", x);
endmodule

module audit_generate_select_per_iteration;
  wire [7:0] bus = 8'b1010_0101;
  genvar i;
  generate for (i = 0; i < 2; i = i + 1) begin : g
    leaf #(i + 1) u(.x(bus[i*4+3:i*4]));
  end endgenerate
  initial #3 $finish(0);
endmodule
