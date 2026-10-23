// IEEE 1364-2005 §17.1.1.6, p. 285: %m prints "the hierarchical name of the
// module, task, function, or named block that invokes the system task".
// §12.5, p. 191: each "generate block instance ... shall define a new branch
// of the hierarchy." §12.4.3, p. 190: "All unnamed generate blocks will be
// given the name "genblk<n>" where <n> is the number assigned to its
// enclosing generate construct." §12.4.1, p. 186: a loop generate's block
// instances are named "name[value]" by genvar value.
//
// The module's only generate construct is number 1, so its unnamed block is
// genblk1; two iterations i = 0, 1, each printing at time i:
//   b_17_1_1_6_scope_unnamed_loop_generate.genblk1[0]
//   b_17_1_1_6_scope_unnamed_loop_generate.genblk1[1]
//! inherited IEEE 1364-2005 17.1.1.6 12.4.3
`timescale 1ns/1ns
module b_17_1_1_6_scope_unnamed_loop_generate;
  genvar i;
  for (i = 0; i < 2; i = i + 1) begin
    initial #i $display("%m");
  end
endmodule
