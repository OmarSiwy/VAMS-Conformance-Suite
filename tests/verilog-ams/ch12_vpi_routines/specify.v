// The design the b7 delay and timing-check applications run (VAMS-2023 11.6.15,
// 12.11, 12.22, 12.29, 12.31.4): path_delays.c, pulse_limits.c,
// pulse_retain.c, intermod_path.c and tchk_violation.c. No `//!`
// directive, so the suite does not collect it (tests/suite.zig
// `fixtureExt`); every number about it is asserted from C.
//
// THE CELL, b7_cell, as written:
//   (a => y) = (2, 3);              path 1: two delays, rise 2, fall 3
//   (c => z) = (2, 3, 4);           path 2: three delays, rise 2, fall 3, z 4
//   $setup(d, posedge clk, 5, notif);   one limit, 5
//
// THE TOP, b7_specify: two cells. u1's output y drives net n, and n is u2's
// input a, so (u1 port y, u2 port a) is an output port and an input port of
// the same size (one bit) joined by a net: the pair 12.22 makes an
// inter-module path from. u2's clk is clk2, which never rises.
//
// THE TIMELINE (t in ns): at 0 every reg takes 0 (b = 1); d rises at 3;
// clk rises at 5. IEEE 1364-2005 §15.2.1 $setup(data, reference, limit):
// "(timecheck time) - (timestamp time) < limit" is a violation, the data
// event the timestamp and the reference the timecheck. The last data event
// before the posedge at 5 is the one at 3, and 5 - 3 = 2 < 5: ONE violation,
// in u1, at t=5. clk's 0 at t=0 is x->0, a negedge, so no earlier reference
// event exists; u2's clk2 never rises, so u2 checks nothing. $finish at 10.
`timescale 1ns/1ns

module b7_cell(a, b, c, d, clk, y, z);
  input a, b, c, d, clk;
  output y, z;
  reg notif;
  and (y, a, b);
  buf (z, c);
  specify
    (a => y) = (2, 3);
    (c => z) = (2, 3, 4);
    $setup(d, posedge clk, 5, notif);
  endspecify
endmodule

module b7_specify;
  reg a, b, c, d, clk, clk2;
  wire n, z1, y2, z2;
  b7_cell u1 (a, b, c, d, clk, n, z1);
  b7_cell u2 (n, b, c, d, clk2, y2, z2);
  initial begin
    a = 0; b = 1; c = 0; d = 0; clk = 0; clk2 = 0;
    #3 d = 1;
    #2 clk = 1;
    #5 $finish(0);
  end
endmodule
