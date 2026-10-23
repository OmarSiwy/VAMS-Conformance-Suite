// IEEE 1364-2005 §12.2.1, p. 168: "Using the defparam statement, parameter
// values can be changed in any module instance throughout the design using the
// hierarchical name of the parameter." ... "a defparam statement in a
// hierarchy in or under a generate block instance ... shall not change a
// parameter value outside that hierarchy." §12.6, p. 193: a hierarchical
// name's first identifier is looked for in the current scope, then in each
// enclosing one (the upward search), and §12.5 lets the name of a top-level
// module start one anywhere. §12.4.1: inside a loop generate block the genvar
// is a local parameter, so `g[i]` is a constant select of the block's own
// instance.
//
// Legal neighbours of defparam_across_generate_instances_rejected.v
// and defparam_early_resolution_rejected.v:
//   mid's defparam names b_12_2_1_defparam_upward_and_indexed_paths.u.l.p:
//     the first identifier is the top module, so the path runs down again to
//     u.l, whose p becomes 7
//   g[i]'s defparam names g[i].l.p: g[i] is the block instance it is in, so
//     it stays inside that hierarchy: p = 20 + i, 20 and 21
// Each leaf prints %m and p at t = p, so the lines come out in that order:
// "<top>.u.l p=7", "<top>.g[0].l p=20", "<top>.g[1].l p=21".
//! inherited IEEE 1364-2005 12.2.1 12.6
`timescale 1ns/1ns
module leaf;
  parameter p = 1;
  initial #p $display("%m p=%0d", p);
endmodule
module mid;
  leaf l();
  defparam b_12_2_1_defparam_upward_and_indexed_paths.u.l.p = 7;
endmodule
module b_12_2_1_defparam_upward_and_indexed_paths;
  mid u();
  genvar i;
  for (i = 0; i < 2; i = i + 1) begin : g
    leaf l();
    defparam g[i].l.p = 20 + i;
  end
endmodule
