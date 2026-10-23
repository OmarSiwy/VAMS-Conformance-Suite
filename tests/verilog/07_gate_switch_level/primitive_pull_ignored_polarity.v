// IEEE1364-2005 §7.8 ignores strength0 on pullup. The first pullup drives
// strong1 against pull0=>1; the second drives weak1 against pull0=>0.
// Opposite-polarity annotations must not affect either result.
//! lrm A.3.2
//! lrm A.3.2:1000
//! inherited IEEE 1364-2005 7.8 7.10.1
`timescale 1ns/1ns
module audit_primitive_pull_ignored_polarity;
  wire a, b;
  pullup (weak0, strong1) pa(a);
  pullup (strong0, weak1) pb(b);
  pulldown da(a), db(b);
  initial begin
    #1 $display("resolved=%b,%b", a, b);
    $finish(0);
  end
endmodule
