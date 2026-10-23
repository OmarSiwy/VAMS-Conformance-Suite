// IEEE 1364-2005 §12.3.10, p. 180, Table 12-1: internal net "wand, triand",
// external net "wor, trior": "ext" and "warn". "KEY: ... warn = A warning
// shall be issued."
//
// net_type_warning.v connects the wand output to a whole wor net;
// here the external net is one bit of a wor vector, w[0]. The two nets the
// port joins are still a wand and a wor, so the warning is owed, merged or
// not. y has one driver, a, so w[0] = a = 1 either way.
//! inherited IEEE 1364-2005 12.3.10
`timescale 1ns/1ns
module b_12_3_10_sel_m(a, y);
  input a;
  output y;
  wand y;
  assign y = a;
endmodule
module b_12_3_10_select_warning;
  wor [1:0] w;
  reg r;
  b_12_3_10_sel_m u(r, w[0]);
  initial begin
    r = 1;
    #1 $display("%b", w[0]);
  end
endmodule
