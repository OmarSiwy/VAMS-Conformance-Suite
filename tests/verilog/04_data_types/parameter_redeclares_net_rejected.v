// IEEE 1364-2005 §4.10, p. 35: "It is illegal to redeclare a name already
// declared by a net, parameter, or variable declaration."
//
// w is declared as a net, then as a parameter. Legal neighbour:
// parameter_widths.v (parameters with names of their own).
//! inherited IEEE 1364-2005 4.10
//! reject E1100
//! reject duplicate
//! neighbour parameter_widths.v
module b_4_10_parameter_redeclares_net_rejected;
  wire w;
  parameter w = 1;
endmodule
