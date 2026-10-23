// IEEE 1364-2005 §12.3.10, pp. 179-180: "When different net types are connected
// through a module port, the nets on both sides of the port can take on the
// same type. The resulting net type can be determined as shown in Table 12-1."
// Table 12-1 (p. 180), internal net "wand, triand", external net "wor,
// trior": "ext" and "warn". "KEY: ... warn = A warning shall be issued."
//
// m's output y is a wand; the parent's net w is a wor. The cell is a warn cell,
// so a warning is owed whether or not the nets are merged. The value is chosen
// not to depend on merging: y has one driver, a, so wand or wor, merged or
// not, w = a = 1.
//! inherited IEEE 1364-2005 12.3.10
`timescale 1ns/1ns
module m(a, y);
  input a;
  output y;
  wand y;
  assign y = a;
endmodule
module b_12_3_10_net_type_warning;
  wor w;
  reg r;
  m u(r, w);
  initial begin
    r = 1;
    #1 $display("%b", w);
  end
endmodule
