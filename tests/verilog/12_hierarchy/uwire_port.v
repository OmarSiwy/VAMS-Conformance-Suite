// IEEE 1364-2005 §12.3.9.3, p. 179: "If the net on either side of a port has
// the net type uwire, a warning shall be issued if the nets are not merged into
// a single net, as described in 12.3.10." §12.3.10, p. 180: "It is permissible
// to merge the dominating and dominated nets into a single net". Table 12-1:
// internal uwire, external wire -> "int", no warn.
//
// m's input a is a uwire; the external net w is a wire driven 1 by its
// declaration assignment, the only driver on either side. Whether or not the
// two nets are merged, a reads 1 and y = a = 1.
//! inherited IEEE 1364-2005 12.3.9.3
`timescale 1ns/1ns
module m(input uwire a, output y);
  assign y = a;
endmodule
module b_12_3_9_3_uwire_port;
  wire w = 1'b1;
  wire y;
  m u(w, y);
  initial #1 $display("%b", y);
endmodule
