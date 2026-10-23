// IEEE1364-2005 §§7.10.2/7.10.3: strong H is1-or-z, not strong X.
// Combining it with definite pull1 always gives1, at a strength in5..6.
// Symmetrically strong L plus pull0 gives0. Flattening H/L to ordinary
// strong X before resolution incorrectly loses those known values.
//! inherited IEEE 1364-2005 7.10.2 7.10.3
`timescale 1ns/1ns
module audit_primitive_ambiguous_same_polarity;
  reg uncertain;
  wire high, low;
  bufif1 gh(high, 1'b1, uncertain);
  bufif1 gl(low, 1'b0, uncertain);
  // Continuous pull-strength drivers isolate resolution from pull primitives.
  assign (pull1, pull0) high = 1'b1;
  assign (pull1, pull0) low = 1'b0;
  initial begin
    uncertain = 1'bx;
    #1 $display("unknown_enable=%b,%b", high, low);
    uncertain = 1'bz;
    #1 $display("z_enable=%b,%b", high, low);
    $finish(0);
  end
endmodule
