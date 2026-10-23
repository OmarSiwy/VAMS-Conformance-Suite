// IEEE 1364-2005 §12.4.1: a loop generate block "comprises a separate scope",
// and a named one "is a declaration of an array of generate block instances"
// indexed by the genvar's values; §12.4.2 names a conditional generate's
// block the same way; §12.5 reaches a declaration in such a scope by a
// hierarchical name (`g[1].r`, `c.v`). The declarations include variables,
// not only nets (#56: VerA declared a generate block's nets and processes
// but never its variables, so `g[1].r` was an undeclared variable).
// §6.2.1: a variable declaration assignment is an initial assignment, here
// once per iteration's own `k`.
//   g[0].r = 5 + 0 = 5, g[1].r = 5 + 1 = 6 (each block's own initial, t=0)
//   g[0].k = g[1].k = 9 (the declaration assignment)
//   c.v written from outside as 8'ha5 reads back a5
//   g[1].r written from outside as 42 reads back 42; g[0].r stays 5
//! inherited IEEE 1364-2005 12.4.1 12.4.2 12.5
`timescale 1ns/1ns
module b_12_4_1_generate_block_variables;
  genvar i;
  for (i = 0; i < 2; i = i + 1) begin : g
    integer r;
    reg [3:0] k = 4'd9;
    initial r = 5 + i;
  end
  if (1) begin : c
    reg [7:0] v;
  end
  initial begin
    #1 $display("%0d %0d", g[0].r, g[1].r);
    $display("%0d %0d", g[0].k, g[1].k);
    c.v = 8'ha5;
    $display("%h", c.v);
    g[1].r = 42;
    $display("%0d %0d", g[0].r, g[1].r);
    $finish(0);
  end
endmodule
