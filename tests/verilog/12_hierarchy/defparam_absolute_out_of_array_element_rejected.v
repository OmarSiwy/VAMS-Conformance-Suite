// IEEE 1364-2005 §12.2.1, p. 168: "a defparam statement in a hierarchy in or
// under a generate block instance (see 12.4) or an array of instances (see 7.1
// and 12.1.2) shall not change a parameter value outside that hierarchy."
// The rule bounds where the defparam sits, not how its path is spelled: an
// absolute path out of the element is as illegal as a relative one.
//
// Every u[i]'s defparam names top.u[1].x.p. From u[1] that is its own
// element (legal); from u[0] it is outside it: refused.
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
  defparam top.u[1].x.p = 5;
endmodule
module top;
  blk u[0:1]();
endmodule
