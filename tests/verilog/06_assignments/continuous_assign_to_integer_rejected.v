// IEEE 1364-2005 §6.1.2, p. 69: "The continuous assignment statement shall
// place a continuous assignment on a net data type." Table 6-1 (p. 68) lists
// only nets, their constant selects and concatenations of them as the
// left-hand side of a continuous assignment.
//
// i is an integer, a variable (§4.2.2), not a net, so `assign i = 5;` is
// illegal. Legal neighbour: select_bus.v's continuous assignments all
// drive nets.
//! inherited IEEE 1364-2005 6.1.2
//! reject E1100
//! reject a continuous assignment can only drive a net
//! neighbour select_bus.v
module b_6_1_2_continuous_assign_to_integer_rejected;
  integer i;
  assign i = 5;
  initial #1 $display("%0d", i);
endmodule
