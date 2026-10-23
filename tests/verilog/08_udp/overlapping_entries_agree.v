// IEEE 1364-2005 8.1.4: "It is illegal to have the same combination of
// inputs, including edges, specified for different outputs." The rule is
// about DIFFERENT outputs, so entries that overlap and agree are legal.
// Here `0 ?` and `? 0` both cover 0 0, and both give 1: a NAND table.
// By hand, from the entries (8.1.4: an unlisted combination is x):
//   00 -> 1 (both overlapping entries)   01 -> 1   10 -> 1   11 -> 0
//   x0 -> 1 (`? 0`; `?` covers x, 8.1.6)  x1 -> x (no entry covers it)
// A checker that refuses any overlap, rather than an overlap with two
// outputs, refuses this. conflicting_entries_rejected.v changes the
// second entry's output to 0 and is refused.
//! lrm A.5.3
//! inherited IEEE 1364-2005 8.1.4 8.1.6
`timescale 1ns/1ns
primitive nand_overlap(q, a, b);
  output q;
  input a, b;
  table
    0 ? : 1;
    ? 0 : 1;
    1 1 : 0;
  endtable
endprimitive
module b_8_1_4_overlapping_entries_agree;
  reg a, b;
  wire q;
  nand_overlap u(q, a, b);
  initial begin
    a = 0; b = 0; #1 $display("00 %b", q);
    b = 1;        #1 $display("01 %b", q);
    a = 1; b = 0; #1 $display("10 %b", q);
    b = 1;        #1 $display("11 %b", q);
    a = 1'bx; b = 0; #1 $display("x0 %b", q);
    b = 1;        #1 $display("x1 %b", q);
    $finish(0);
  end
endmodule
