// IEEE 1364-2005 §12.3.10.1, p. 180: "When a dominating net type does not
// exist, the external net type shall be used." §12.3.10.2: "The simulated net
// shall take the net type specified in the table". Table 12-1, internal net
// "wire, tri", every external column: "ext".
//
// Merging is the tool's choice (§12.3.10: "It is permissible to merge"), so
// each value below is one both readings give:
//   u1: inside wire, outside tri0, nothing drives either. Merged: one tri0
//       net with no driver, 0 (§4.6.4). Unmerged: the outside tri0 reads 0
//       and the input port drives that 0 into the wire. y1 = 0.
//   u2: inside wire, outside tri1, likewise: y2 = 1.
//   u3: inside wire, outside supply0: y3 = 0.
//! inherited IEEE 1364-2005 12.3.10.1 12.3.10.2
`timescale 1ns/1ns
module b_12_3_10_2_in(a, y);
  input a;
  output y;
  wire a;
  assign y = a;
endmodule
module b_12_3_10_2_external_type_cells;
  tri0 n0;
  tri1 n1;
  supply0 s0;
  wire y1, y2, y3;
  b_12_3_10_2_in u1(n0, y1);
  b_12_3_10_2_in u2(n1, y2);
  b_12_3_10_2_in u3(s0, y3);
  initial #1 $display("y1=%b y2=%b y3=%b", y1, y2, y3);
endmodule
