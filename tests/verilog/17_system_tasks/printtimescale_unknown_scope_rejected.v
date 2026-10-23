// IEEE 1364-2005 §17.3.1, Syntax 17-9, p. 299:
//   printtimescale_task ::= $printtimescale [ ( hierarchical_identifier ) ] ;
// "When an argument is specified, $printtimescale displays the time unit and
// precision of the module passed to it."
//
// nosuch.c1 names no instance of this design: the hierarchical identifier
// does not resolve (§12.5), so there is no module whose time unit could be
// displayed. Legal neighbour: printtimescale_named_module.v names an
// instance that exists.
//! inherited IEEE 1364-2005 17.3.1
//! reject E1100
//! reject undeclared instance in a hierarchical reference
//! neighbour printtimescale_named_module.v
`timescale 1 ns / 1 ns
module b_17_3_1_printtimescale_unknown_scope_rejected;
  initial $printtimescale(nosuch.c1);
endmodule
