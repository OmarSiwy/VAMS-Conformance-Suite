// D08 — tri-state enable gates: bufif0, bufif1, notif0, notif1.
//
// Verilog-AMS 2.4 Annex A.3.4:
//     enable_gatetype ::= bufif0 | bufif1 | notif0 | notif1
// Annex A.3.1:
//     enable_gate_instance ::= [ name_of_gate_instance ]
//         ( output_terminal , input_terminal , enable_terminal )
// §1.1 makes IEEE Std 1364-2005 clause 7 the normative value tables.
//
// HAND DERIVATION. The enable_terminal is the LAST terminal; bufif1/notif1
// conduct when it is 1, bufif0/notif0 when it is 0. The buf- forms pass the
// data value, the not- forms pass its complement. Three regimes, and the whole
// 16-row table falls out of them:
//
//   enable is the OFF value  -> output is z, whatever the data is.
//   enable is the ON value   -> output is the gate function of the data input,
//                               with z on that input coerced to x because a
//                               gate transmits a logic value, not a connection.
//                               So bufif1(z data, 1) = x, NOT z.
//   enable is x or z         -> the gate may or may not be conducting, so the
//                               output is "the driven value or z". IEEE 1364
//                               writes those two cases as the symbols L (0-or-z)
//                               and H (1-or-z). Neither is a member of the
//                               four-state value set {0,1,x,z}: L is not 0
//                               (it might be z) and not z (it might be 0). The
//                               only sound projection onto a $display("%b")
//                               column is x, so every ambiguous-enable cell
//                               below reads x. (A fixture that distinguished L
//                               from H would need the %v strength format; see
//                               tests/fixtures/ieee1364/07_gate_switch_level/d08_SPEC.md at 8b1514d4, "not covered".)
//
// The two fully-known enable columns are what discriminate the four gate types
// from each other: at d=1,c=0 the four outputs are 1, z, 0, z — no two alike.
//
//! lrm A.3.1
//! lrm A.3.4
//! lrm 1.1
//! lrm A.3.1:1000
//! lrm A.3.4:1000
//! inherited IEEE 1364-2005 7.4
`timescale 1ns/1ns
module d08_gates_enable;
  reg d, c;
  wire w_bufif0, w_bufif1, w_notif0, w_notif1;

  bufif0 g0 (w_bufif0, d, c);
  bufif1 g1 (w_bufif1, d, c);
  notif0 g2 (w_notif0, d, c);
  notif1 g3 (w_notif1, d, c);

  initial begin
    d = 1'b0; c = 1'b0; #1
      $display("d=0 c=0 got bufif0=%b bufif1=%b notif0=%b notif1=%b want 0 z 1 z",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'b0; c = 1'b1; #1
      $display("d=0 c=1 got bufif0=%b bufif1=%b notif0=%b notif1=%b want z 0 z 1",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'b0; c = 1'bx; #1
      $display("d=0 c=x got bufif0=%b bufif1=%b notif0=%b notif1=%b want x x x x",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'b0; c = 1'bz; #1
      $display("d=0 c=z got bufif0=%b bufif1=%b notif0=%b notif1=%b want x x x x",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'b1; c = 1'b0; #1
      $display("d=1 c=0 got bufif0=%b bufif1=%b notif0=%b notif1=%b want 1 z 0 z",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'b1; c = 1'b1; #1
      $display("d=1 c=1 got bufif0=%b bufif1=%b notif0=%b notif1=%b want z 1 z 0",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'b1; c = 1'bx; #1
      $display("d=1 c=x got bufif0=%b bufif1=%b notif0=%b notif1=%b want x x x x",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'b1; c = 1'bz; #1
      $display("d=1 c=z got bufif0=%b bufif1=%b notif0=%b notif1=%b want x x x x",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'bx; c = 1'b0; #1
      $display("d=x c=0 got bufif0=%b bufif1=%b notif0=%b notif1=%b want x z x z",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'bx; c = 1'b1; #1
      $display("d=x c=1 got bufif0=%b bufif1=%b notif0=%b notif1=%b want z x z x",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'bx; c = 1'bx; #1
      $display("d=x c=x got bufif0=%b bufif1=%b notif0=%b notif1=%b want x x x x",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'bx; c = 1'bz; #1
      $display("d=x c=z got bufif0=%b bufif1=%b notif0=%b notif1=%b want x x x x",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'bz; c = 1'b0; #1
      $display("d=z c=0 got bufif0=%b bufif1=%b notif0=%b notif1=%b want x z x z",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'bz; c = 1'b1; #1
      $display("d=z c=1 got bufif0=%b bufif1=%b notif0=%b notif1=%b want z x z x",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'bz; c = 1'bx; #1
      $display("d=z c=x got bufif0=%b bufif1=%b notif0=%b notif1=%b want x x x x",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
    d = 1'bz; c = 1'bz; #1
      $display("d=z c=z got bufif0=%b bufif1=%b notif0=%b notif1=%b want x x x x",
               w_bufif0, w_bufif1, w_notif0, w_notif1);
  end
endmodule
