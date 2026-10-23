// IEEE 1364-2005 §7.14, p. 101: "Net delays refer to the time it takes from
// any driver on the net changing value to the time when the net value is
// updated and propagated further. Up to three delay values per net can be
// specified." Syntax 4-1: net_type ... [ delay3 ] list_of_net_identifiers.
//
// A net declaration with four delay values. Legal neighbour: the three-delay
// trireg #(0, 0, 50) in trireg_charge_decay.v.
//! inherited IEEE 1364-2005 7.14
//! reject E0210
//! reject expected ')'
//! neighbour trireg_charge_decay.v
module b_7_14_four_net_delays_rejected;
  wire #(1,2,3,4) w;
  initial $finish(0);
endmodule
