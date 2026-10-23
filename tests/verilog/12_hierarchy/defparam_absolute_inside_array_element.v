// IEEE 1364-2005 §12.2.1, p. 168: "a defparam statement in a hierarchy in or
// under a generate block instance (see 12.4) or an array of instances (see 7.1
// and 12.1.2) shall not change a parameter value outside that hierarchy."
// A defparam inside an element that targets its own element stays inside it,
// however the path is spelled: absolute through the top, or relative.
//
// u[1:1] is a one-element array whose element holds defparam
// top.u[1].x.p = 5 (absolute, its own element) and x.q = 7 (relative).
// Each g[i] holds defparam top.g[i].l.p = i + 20 (absolute, its own block).
// Expected at t=1: u[1] p=5 q=7, g[0] p=20, g[1] p=21.
//! lrm 6.3.1
//! inherited IEEE 1364-2005 12.2.1
//! neighbour defparam_absolute_out_of_array_element_rejected.v
`timescale 1ns/1ns
module leaf;
  parameter p = 99;
  parameter q = 1;
  initial #1 $display("%m p=%0d q=%0d", p, q);
endmodule
module blk;
  leaf x();
  defparam top.u[1].x.p = 5;
  defparam x.q = 7;
endmodule
module top;
  genvar i;
  for (i = 0; i < 2; i = i + 1) begin : g
    leaf l();
    defparam top.g[i].l.p = i + 20;
  end
  blk u[1:1]();
endmodule
