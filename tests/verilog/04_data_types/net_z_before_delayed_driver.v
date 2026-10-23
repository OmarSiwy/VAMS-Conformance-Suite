// IEEE 1364-2005 §4.2.1, p. 23: "The default initialization value for a net
// shall be the value z. Nets with drivers shall assume the output value of
// their drivers." With a delayed driver the two sentences are apart in time:
// until the driver's first scheduled update lands, the net has assumed
// nothing, so it reads its initialization value z.
//
// `assign #5 w = r;` (§6.1.3: the delay is "the time ... until the value of
// the left-hand side changes") evaluates r = 1 at t = 0 and schedules w = 1
// for t = 5. `wire #5 v = r;` is the net-declaration-assignment form (§6.1.2)
// of the same driver. At t = 1 neither update has landed: both read z. At
// t = 6 both read 1. A net initialized to x (the variable rule of §4.2.2)
// would print x at t = 1, and an undelayed net 1.
//
// Neighbour: net_takes_driver_value.v, an undelayed driver, and the
// no-driver net that stays z throughout.
//! inherited IEEE 1364-2005 4.2.1 6.1.3
`timescale 1ns/1ns
module b_4_2_1_net_z_before_delayed_driver;
  reg r;
  wire w;
  assign #5 w = r;
  wire #5 v = r;
  initial begin
    r = 1'b1;
    #1 $display("t=1 w=%b v=%b", w, v);
    #5 $display("t=6 w=%b v=%b", w, v);
    $finish(0);
  end
endmodule
