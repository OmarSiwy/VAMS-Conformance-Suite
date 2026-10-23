// IEEE 1364-2005 §7.5, p. 84: "These four switches shall have one output, one
// data input, and one control input. The first terminal in the terminal list
// shall connect to the output, the second terminal shall connect to the data
// input, and the third terminal shall connect to the control input."
//
// An nmos with no control terminal. Legal neighbour: nmos (o_nmos, a, n) in
// every_primitive.v.
//! inherited IEEE 1364-2005 7.5
//! reject E0209
//! reject a mos switch (A.3.4 mos_switchtype) takes an output, an input and an enable terminal
//! neighbour every_primitive.v
module b_7_5_missing_control_rejected;
  reg a;
  wire o;
  nmos m(o, a);
  initial $finish(0);
endmodule
