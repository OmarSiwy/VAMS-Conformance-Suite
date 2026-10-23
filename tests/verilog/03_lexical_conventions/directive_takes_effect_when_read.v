// IEEE 1364-2005 §3.7.4, p. 15: "The compiler behavior dictated by a compiler
// directive shall take effect as soon as the compiler reads the directive.
// The directive shall remain in effect for the rest of the compilation
// unless a different compiler directive specifies otherwise. A compiler
// directive in one description file can, therefore, control compilation
// behavior in multiple description files."
//
// `W is 8 where the first $display is read; the `undef and the second
// `define are read before the second $display, which therefore sees 16.
// `K, defined before module b_3_7_4_directive_takes_effect_when_read, stays in
// effect in the later module b_3_7_4_leaf -> 5.
// Printed: "8", "16", "5" (the leaf's initial runs in the same time step as
// the parent's; the parent's two lines are one process, the leaf's line is
// printed after #1).
//! inherited IEEE 1364-2005 3.7.4
`define W 8
`define K 5
module b_3_7_4_directive_takes_effect_when_read;
  b_3_7_4_leaf leaf();
  initial begin
    $display("%0d", `W);
`undef W
`define W 16
    $display("%0d", `W);
  end
endmodule
module b_3_7_4_leaf;
  initial begin
    #1 $display("%0d", `K);
    $finish(0);
  end
endmodule
