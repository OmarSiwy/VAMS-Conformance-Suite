// IEEE 1364-2005 §12.3.5, p. 176: "One method of making the connection between
// the port expressions listed in a module instantiation and the ports declared
// within the instantiated module is the ordered list; that is, the port
// expressions listed for the module instance shall be in the same order as the
// ports listed in the module declaration."
//
// m lists two ports; u lists three expressions, and the third has no port to
// be in order with. Legal neighbour: ffnand_instances.v (four
// expressions for ffnand's four ports).
//! inherited IEEE 1364-2005 12.3.5
//! reject E1100
//! reject more port connections than the module has ports
//! neighbour ffnand_instances.v
module m(a, y);
  input a;
  output y;
  assign y = a;
endmodule
module b_12_3_5_extra_ordered_connection_rejected;
  reg r;
  wire w, x;
  m u(r, w, x);
endmodule
