// IEEE 1364-2005 §12.2.1, p. 168: "a defparam statement in a hierarchy in or
// under a generate block instance (see 12.4) or an array of instances (see 7.1
// and 12.1.2) shall not change a parameter value outside that hierarchy."
//
// Every u[i]'s defparam names u[1].x.p, which resolves upward (§12.6) to the
// sibling element u[1]: from u[0] that is outside its own element: refused.
// Legal neighbour: defparam_absolute_inside_array_element.v.
//! lrm 6.3.1:4
//! inherited IEEE 1364-2005 12.2.1
//! reject-only E1100
//! reject outside the generate block instance or array element
//! neighbour defparam_absolute_inside_array_element.v
`timescale 1ns/1ns
module leaf;
  parameter p = 99;
  initial #1 $display("p=%0d", p);
endmodule
module blk;
  leaf x();
  defparam u[1].x.p = 5;
endmodule
module top;
  blk u[0:1]();
endmodule
