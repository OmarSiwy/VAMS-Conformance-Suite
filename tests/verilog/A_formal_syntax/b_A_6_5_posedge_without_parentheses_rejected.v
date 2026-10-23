// IEEE 1364-2005 A.6.5, p. 498:
//   event_control ::= @ hierarchical_event_identifier | @ ( event_expression ) | @* | @ (*)
//   event_expression ::= expression | posedge expression | negedge expression | ...
// Only a bare identifier follows `@` without parentheses; an edge
// (posedge, negedge) is an event_expression and so sits inside them.
//
// `@ posedge clk` derives no event_control. Legal neighbour:
// b_A_6_5_timing_controls.v (`@(posedge a)`, `@e`).
//! inherited IEEE 1364-2005 A.6.5
//! reject E0208
//! reject found `posedge`
//! neighbour b_A_6_5_timing_controls.v
module b_A_6_5_posedge_without_parentheses_rejected;
  reg clk;
  initial @ posedge clk $display("unreachable");
endmodule
