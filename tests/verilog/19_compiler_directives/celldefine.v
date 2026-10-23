// IEEE 1364-2005 §19.1, p. 349: "The directives `celldefine and
// `endcelldefine tag modules as cell modules. Cells are used by certain PLI
// routines for applications, such as delay calculations. It is advisable to
// pair each `celldefine with an `endcelldefine, but it is not required. The
// latest occurrence of either directive in the source controls whether
// modules are tagged as cell modules. More than one of these pairs may
// appear in a single source description. These directives may appear
// anywhere in the source description, but it is recommended that the
// directives be specified outside the module definition."
//
// The tag is for PLI routines only; nothing in the language reads it, so the
// design computes what it would without the directives. Every placement the
// clause allows is used: a pair around b_19_1_cell_and, a second pair
// written inside b_19_1_cell_or's definition, and an unpaired `celldefine
// before the top module. a = 1, b = 0 at time 0:
//   and -> 0, or -> 1, printed at time 1 as "and=0 or=1".
//! inherited IEEE 1364-2005 19.1
`timescale 1ns/1ns
`celldefine
module b_19_1_cell_and(output o, input x, input y);
  assign o = x & y;
endmodule
`endcelldefine
module b_19_1_cell_or(output o, input x, input y);
`celldefine
  assign o = x | y;
`endcelldefine
endmodule
`celldefine
module b_19_1_celldefine;
  reg a, b;
  wire n, r;
  b_19_1_cell_and g1(n, a, b);
  b_19_1_cell_or g2(r, a, b);
  initial begin
    a = 1'b1;
    b = 1'b0;
    #1 $display("and=%b or=%b", n, r);
    $finish(0);
  end
endmodule
