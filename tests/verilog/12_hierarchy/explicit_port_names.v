// IEEE 1364-2005 §12.3.2, p. 174: "The first type of module port, with only a
// port_expression, is an implicit port. The second type is the explicit port.
// This explicitly specifies the port_identifier used for connecting module
// instance ports by name (see 12.3.6) and the port_expression that contains
// identifiers declared inside the module as described in 12.3.3." §12.3.6,
// p. 177: "If the module port declaration was explicit, the explicit name is
// used as the name of port."
//
// m has explicit ports .a(i) and .e(f) and one implicit port en: outside, the
// ports are named a, e and en; inside, i, f and en. f = ~i & en.
//   u by name, in another order: .en(1), .e(nf), .a(1) -> nf = ~1 & 1 = 0
//   v by order (a, e, en): (0, nv, 1)                  -> nv = ~0 & 1 = 1
//! inherited IEEE 1364-2005 12.3.2 12.3.6
`timescale 1ns/1ns
module m(.a(i), .e(f), en);
  input i, en;
  output f;
  assign f = ~i & en;
endmodule
module b_12_3_2_explicit_port_names;
  wire nf, nv;
  m u(.en(1'b1), .e(nf), .a(1'b1));
  m v(1'b0, nv, 1'b1);
  initial #1 $display("%b %b", nf, nv);
endmodule
