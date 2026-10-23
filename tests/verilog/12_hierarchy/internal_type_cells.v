// IEEE 1364-2005 §12.3.10.2, p. 181: "The simulated net shall take the net
// type specified in the table". Table 12-1, external net "wire, tri": the
// internal rows tri0 and "wand, triand" read "int" ("The internal net type
// shall be used").
//
// Merging is the tool's choice (§12.3.10), so each value below is one both
// readings give:
//   u1: inside `input a; tri0 a;`, outside an undriven wire w. Merged: one
//       tri0 net with no driver, 0. Unmerged: the port drives w's z into the
//       tri0, which reads 0 (§4.6.4). y = 0 either way (w itself is z or 0,
//       so it is not printed).
//   u2: inside `inout b; wand b;` with two drivers 0 and 1, outside an
//       undriven wire v. Merged: one wand net, 0 & 1 = 0 (Table 4-3).
//       Unmerged: the wand resolves to 0 and the inout's transistor
//       connection (§12.3.9.2) carries it to v. b = 0 and v = 0 either way.
// Taking the external type instead gives u1 z and u2 x (two strong drivers
// on a wire, Table 4-2). The ext cells' neighbour is
// external_type_cells.v. No invalid form exists: every pair of
// net types has a cell.
//! inherited IEEE 1364-2005 12.3.10.1 12.3.10.2
`timescale 1ns/1ns
module b_12_3_10_2_tri0_in(a, y);
  input a;
  output y;
  tri0 a;
  assign y = a;
endmodule
module b_12_3_10_2_wand_io(b);
  inout b;
  wand b;
  assign b = 1'b0;
  assign b = 1'b1;
endmodule
module b_12_3_10_2_internal_type_cells;
  wire w, y, v;
  b_12_3_10_2_tri0_in u1(w, y);
  b_12_3_10_2_wand_io u2(v);
  initial #1 $display("y=%b b=%b v=%b", y, u2.b, v);
endmodule
