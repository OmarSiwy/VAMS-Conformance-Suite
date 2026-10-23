// IEEE 1364-2005 §12.2.1, p. 168: "a defparam statement in a hierarchy in or
// under a generate block instance (see 12.4) or an array of instances (see 7.1
// and 12.1.2) shall not change a parameter value outside that hierarchy." A
// defparam inside a generate block that targets an instance in the same block
// instance stays inside it, so it is legal; Syntax 12-5 lists parameter_override
// among the module_or_generate_items.
//
// Each g[i] holds leaf l and a defparam l.p = i * 10; leaf prints p at
// t = p + 1: p=0 at 1, p=10 at 11, p=20 at 21.
//! inherited IEEE 1364-2005 12.2.1
`timescale 1ns/1ns
module leaf;
  parameter p = 99;
  initial #(p + 1) $display("p=%0d", p);
endmodule
module b_12_2_1_defparam_inside_generate_block;
  genvar i;
  for (i = 0; i < 3; i = i + 1) begin : g
    leaf l();
    defparam l.p = i * 10;
  end
endmodule
