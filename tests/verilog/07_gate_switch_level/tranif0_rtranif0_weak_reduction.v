// IEEE 1364-2005 §7.6, p. 85: "When tranif0, tranif1, rtranif0, or rtranif1
// devices are turned off, they shall block signals; and when they are turned
// on, they shall pass signals." The prose never says which control level
// turns the `if0` pair on; the reading taken here is the one their names
// share with bufif0/notif0 (Table 7-5: enabled by a 0 control), i.e. on at 0,
// off at 1. §7.11, p. 100: "The tran, tranif0, and tranif1 switches shall not
// affect signal strength across the bidirectional terminals, except that a supply strength shall
// be reduced to a strong strength." §7.12, Table 7-8: "Strong drive -> Pull
// drive" and "Weak drive -> Medium capacitor" for rtran/rtranif0/rtranif1/
// rnmos/rpmos/rcmos. Strength levels (Table 7-7): supply 7, strong 6, pull
// 5, weak 3, medium 2. Equal strengths of opposite value give x (§7.10.1).
//
// resistive_reduction_table.v covers the supply, strong and pull rows
// through rnmos/rcmos/rpmos/rtranif1/rtran; this file covers the two enable
// switches no fixture ran (tranif0, rtranif0) and the weak -> medium row.
//
//   w1: vdd (Su1) through tranif0, enable 0: on, Su1 -> St1 (§7.11), beats
//       w1's own Pu0                                        -> 1
//   w2: vdd through tranif0, enable 1: off; w2's own We0 alone -> 0
//   w3: St1 through rtranif0, enable 0: on, St1 -> Pu1, meets Pu0 -> x
//   w4: St1 through rtranif0, enable 1: off; We0 alone       -> 0
//   w5: We1 through rnmos (gate 1): We1 -> Me1, meets We0: the medium
//       charge is weaker                                     -> 0
//       (unreduced, We1 against We0 would be x)
//   w6: We1 through rtranif1 (enable 1), the bidirectional case: We1 -> Me1
//       meets w6's We0 -> 0; and w6's We0 -> Me0 reaches the source net ws2,
//       whose own We1 beats it, so ws2                       -> 1
// Line: "1 0 x 0 0 0 1".
//! inherited IEEE 1364-2005 7.6 7.11 7.12
// native-required
`timescale 1ns/1ns
module b_7_6_tranif0_rtranif0_weak_reduction;
  supply1 vdd;
  reg zero, one;
  wire st, w1, w2, w3, w4, w5, w6, ws, ws2;
  assign st = one;
  tranif0 t1(vdd, w1, zero);    assign (pull1, pull0) w1 = 1'b0;
  tranif0 t2(vdd, w2, one);     assign (weak1, weak0) w2 = 1'b0;
  rtranif0 t3(st, w3, zero);    assign (pull1, pull0) w3 = 1'b0;
  rtranif0 t4(st, w4, one);     assign (weak1, weak0) w4 = 1'b0;
  assign (weak1, weak0) ws = 1'b1;
  rnmos r5(w5, ws, one);        assign (weak1, weak0) w5 = 1'b0;
  assign (weak1, weak0) ws2 = 1'b1;
  rtranif1 t6(ws2, w6, one);    assign (weak1, weak0) w6 = 1'b0;
  initial begin
    zero = 0; one = 1;
    #1 $display("%b %b %b %b %b %b %b", w1, w2, w3, w4, w5, w6, ws2);
    $finish(0);
  end
endmodule
