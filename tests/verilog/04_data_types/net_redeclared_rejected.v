// IEEE 1364-2005 §4.2.1, p. 21: "It is illegal to redeclare a name already
// declared by a net, parameter, or variable declaration (see 4.11)."
//
// w is declared twice as a wire. Legal neighbour: net_takes_driver_value.v
// declares each net once.
//! inherited IEEE 1364-2005 4.2.1
//! reject E1100
//! reject duplicate digital variable
//! neighbour net_takes_driver_value.v
module b_4_2_1_net_redeclared_rejected;
  wire w;
  wire w;
  initial $display("%b", w);
endmodule
