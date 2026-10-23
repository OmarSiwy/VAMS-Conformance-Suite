// IEEE 1364-2005 §7.7, p. 85: "The cmos and rcmos switches shall have a data
// input, a data output, and two control inputs. In the terminal list, the
// first terminal shall connect to the data output, the second terminal shall
// connect to the data input, the third terminal shall connect to the
// n-channel control input, and the last terminal shall connect to the
// p-channel control input."
//
// A cmos with only the n-channel control. Legal neighbour:
// cmos (o_cmos, a, n, p) in every_primitive.v.
//! inherited IEEE 1364-2005 7.7
//! reject E0209
//! reject a cmos switch (A.3.4 cmos_switchtype) takes an output, an input, an ncontrol and a pcontrol terminal
//! neighbour every_primitive.v
module b_7_7_missing_pcontrol_rejected;
  reg a, n;
  wire o;
  cmos c(o, a, n);
  initial $finish(0);
endmodule
