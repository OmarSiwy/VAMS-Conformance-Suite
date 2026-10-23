// IEEE 1364-2005 §12.3.6, p. 177: "The port name shall be the name specified in
// the module declaration."
//
// m has ports a and y; u connects zz. Legal neighbour:
// explicit_port_names.v (.en, .e, .a all name ports of m).
//! lrm 6.5.5
//! lrm 6.5.5:1
//! inherited IEEE 1364-2005 12.3.6
//! reject E1100
//! reject the instantiated module has no such port
//! neighbour explicit_port_names.v
module m(a, y);
  input a;
  output y;
  assign y = a;
endmodule
module b_12_3_6_unknown_port_name_rejected;
  reg r;
  wire w;
  m u(.a(r), .zz(w));
endmodule
