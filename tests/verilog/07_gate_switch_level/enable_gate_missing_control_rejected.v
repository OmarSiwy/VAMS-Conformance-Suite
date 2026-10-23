// IEEE 1364-2005 §7.4, p. 82: "These four logic gates shall have one output,
// one data input, and one control input. The first terminal in the terminal
// list shall connect to the output, the second terminal shall connect to the
// data input, and the third terminal shall connect to the control input."
//
// A bufif1 with no control terminal. Legal neighbour: bufif1 (o_bif1, a, c)
// in every_primitive.v.
//! inherited IEEE 1364-2005 7.4
//! reject E0209
//! reject an enable gate takes an output, a data input and an enable
//! neighbour every_primitive.v
module b_7_4_missing_control_rejected;
  reg a;
  wire o;
  bufif1 g(o, a);
  initial $finish(0);
endmodule
