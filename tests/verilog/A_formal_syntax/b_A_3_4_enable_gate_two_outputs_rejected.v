// IEEE 1364-2005 A.3.4, p. 494:
//   enable_gatetype ::= bufif0 | bufif1 | notif0 | notif1
//   n_output_gatetype ::= buf | not
// A.3.1, p. 494: enable_gate_instance ::= [ name_of_gate_instance ]
//   ( output_terminal , input_terminal , enable_terminal )
// A.3.4 files bufif0 with the enable gates, not with buf, so it takes an
// enable_gate_instance's exactly three terminals and never buf's list of
// several outputs.
//
// `bufif0 (y1, y2, a, en);` gives bufif0 four terminals. Legal neighbours:
// b_A_3_4_gate_and_switch_types.v (`bufif0 (e1, a, dis);`) and
// b_A_3_1_gate_instantiations.v (`buf (o1, o2, a);`).
//! inherited IEEE 1364-2005 A.3.4
//! reject E0209
//! reject an enable gate takes an output, a data input and an enable
//! neighbour b_A_3_1_gate_instantiations.v
//! neighbour b_A_3_4_gate_and_switch_types.v
module b_A_3_4_enable_gate_two_outputs_rejected;
  reg a, en;
  wire y1, y2;
  bufif0 (y1, y2, a, en);
  initial $display("unreachable");
endmodule
