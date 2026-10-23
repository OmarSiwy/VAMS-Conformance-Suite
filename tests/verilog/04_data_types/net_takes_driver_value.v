// IEEE 1364-2005 §4.2.1, p. 21: "A net shall not store a value (except for
// the trireg net). Instead, its value shall be determined by the values of
// its drivers, such as a continuous assignment or a gate." ... "If no driver
// is connected to a net, its value shall be high-impedance (z) unless the
// net is a trireg, in which case it shall hold the previously driven value."
// p. 23: "The default initialization value for a net shall be the value z.
// Nets with drivers shall assume the output value of their drivers."
//
//   wire [3:0] floating (no driver)            -> zzzz
//   wire [3:0] follows = r (continuous assign) -> r's value, 1010, then 0101
//   wire g_out driven by not(g_out, r[0])      -> ~0 = 1, then ~1 = 0
//! inherited IEEE 1364-2005 4.2.1
module b_4_2_1_net_takes_driver_value;
  reg [3:0] r;
  wire [3:0] floating;
  wire [3:0] follows;
  wire g_out;
  assign follows = r;
  not g(g_out, r[0]);
  initial begin
    r = 4'b1010;
    #1 $display("%b %b %b", floating, follows, g_out);
    r = 4'b0101;
    #1 $display("%b %b %b", floating, follows, g_out);
    $finish(0);
  end
endmodule
