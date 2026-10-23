// IEEE 1364-2005 §12.5, p. 192: "Names in a hierarchical path name that refer to
// instance arrays or loop generate blocks may be followed immediately by a
// constant expression in square brackets. This expression selects a particular
// instance of the array and is, therefore, called an instance select. The
// expression shall evaluate to one of the legal index values of the array."
// §12.4.1, p. 186, Example 5: "B1[0].N1 B1[1].N1".
//
// leaf's x = ID; arr[1:0] passes ID 5 to both, g[i].l gets ID = i * 10 via
// the implicit localparam i. The parent reads through instance selects:
//   g[0].l.x = 0, g[1].l.x = 10, g[2].l.x = 20, arr[0].x = 5, arr[1].x = 5
//! inherited IEEE 1364-2005 12.5 12.4.1
`timescale 1ns/1ns
module leaf;
  parameter ID = 0;
  integer x;
  initial x = ID;
endmodule
module b_12_5_instance_select;
  genvar i;
  for (i = 0; i < 3; i = i + 1) begin : g
    leaf #(i * 10) l();
  end
  leaf #(5) arr[1:0] ();
  initial #1 $display("%0d %0d %0d %0d %0d", g[0].l.x, g[1].l.x, g[2].l.x, arr[0].x, arr[1].x);
endmodule
