// IEEE 1364-2005 §7.6: "The delay specifications for tranif1, tranif0,
// rtranif1, and rtranif0 devices shall be zero, one, or two delays" — a
// turn-on and a turn-off delay. A pass switch has no third transition for a
// third delay to govern.
//! inherited IEEE 1364-2005 7.6
//! reject a pass switch takes at most two delays
`timescale 1ns/1ns
module audit_switch_three_delays_rejected;
  wire a, b;
  reg c;
  tranif1 #(1, 2, 3) g(a, b, c);
endmodule
