// LRM 10.6: "Without this directive, the set of reserved keywords in effect
// for this module shall be the implementation's default set of reserved
// keywords." `vera --std=1364-2005` makes that default the IEEE 1364-2005
// keyword list, which has none of `analog`, `ddt`, `sin` or `above` (each is
// in Verilog-AMS annex B only), so all four are ordinary identifiers here.
// analog = 5 on 4 bits; ddt = analog + 1 = 6; sin = analog[0] = 1 (5 is
// 0101); above = ddt * 2 = 12.
//@ std 1364-2005
//! lrm 10.6
//! lrm 10.6:2
//! expect stdout std_1364_ams_keywords_are_identifiers.expected.txt
module std_1364_ams_keywords_are_identifiers;
  reg [3:0] analog;
  wire sin;
  integer ddt, above;
  assign sin = analog[0];
  initial begin
    analog = 4'd5;
    ddt = analog + 1;
    above = ddt * 2;
    #1 $display("analog=%0d ddt=%0d sin=%b above=%0d", analog, ddt, sin, above);
    $finish(0);
  end
endmodule
