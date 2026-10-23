// IEEE 1364-2005 §18.2.1, p. 331: "The VCD format does not support a mechanism
// to dump part of a vector. For example, bits 8 to 15 ([8:15]) of a 16-bit
// vector cannot be dumped in VCD file; instead, the entire vector ([0:15]) has
// to be dumped. In addition, expressions, such as a + b, cannot be dumped in
// the VCD file." Syntax 18-3 (p. 326) admits only `module_identifier |
// variable_identifier` as a $dumpvars argument after the level count.
//
// v[7:4] is part of a vector, which the format cannot carry and the syntax
// does not admit. Legal neighbour: the whole vector, as in
// vcd_dumpvars_levels.v's `$dumpvars(1, d09_vcd_scope, d09_vcd_scope.u.q)`.
//! inherited IEEE 1364-2005 18.2.1
//! reject E1100
//! reject $dumpvars names a module instance or a variable
//! neighbour vcd_dumpvars_levels.v
`timescale 1ns/1ns
module b_18_2_1_part_select_rejected;
  reg a;
  reg [7:0] v;
  initial begin
    $dumpvars(0, v[7:4]);
    a = 1'b0;
    v = 8'h00;
    #1 a = 1'b1;
  end
endmodule
