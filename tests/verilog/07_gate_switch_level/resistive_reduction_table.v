// IEEE 1364-2005 §7.12, p. 100: "The rnmos, rpmos, rcmos, rtran, rtranif1, and
// rtranif0 devices shall reduce the strength of signals that pass through them
// according to Table 7-8." Table 7-8: Supply drive -> Pull drive; Strong
// drive -> Pull drive; Pull drive -> Weak drive; Large capacitor -> Medium
// capacitor; Weak drive -> Medium capacitor; Medium capacitor -> Small
// capacitor; Small capacitor -> Small capacitor; High impedance -> High
// impedance.
//
// Each reduced signal meets a 0 of known strength on its output net
// (levels, Table 7-7: supply 7, strong 6, pull 5, weak 3, medium 2):
//   w1: vdd (Su1) through rnmos -> Pu1, vs Pu0 -> x
//   w2: vdd through rnmos -> Pu1, vs We0 -> 1
//   w3: Pu1 through rnmos -> We1, vs We0 -> x
//   w4: Pu1 through two rnmos in series -> We1 -> Me1, vs We0 -> 0
//   w5: vdd through rcmos (n=1) -> Pu1, vs Pu0 -> x
//   w6: vdd through rpmos (p=0) -> Pu1, vs Pu0 -> x
//   w7: vdd through rtranif1 (g=1) -> Pu1, vs Pu0 -> x
//   w8: St1 through rtran -> Pu1, vs Pu0 -> x
//   w9: rnmos off (g2=0): high impedance stays high impedance; alone with
//       We0 -> 0
// The rows below medium (medium -> small, small -> small, large -> medium)
// need a trireg charge on both sides and are not exercised here.
// Line: "x1x0 xxxx 0".
//! inherited IEEE 1364-2005 7.12
// native-required
`timescale 1ns/1ns
module b_7_12_resistive_reduction_table;
  supply1 vdd;
  reg g, gn, g2, one;
  wire w1, w2, w3, w4, w5, w6, w7, w8, w9, src, mid, st;
  rnmos r1(w1, vdd, g);      assign (pull1, pull0) w1 = 1'b0;
  rnmos r2(w2, vdd, g);      assign (weak1, weak0) w2 = 1'b0;
  assign (pull1, pull0) src = 1'b1;
  rnmos r3(w3, src, g);      assign (weak1, weak0) w3 = 1'b0;
  rnmos r4(mid, src, g);
  rnmos r5(w4, mid, g);      assign (weak1, weak0) w4 = 1'b0;
  rcmos c1(w5, vdd, g, gn);  assign (pull1, pull0) w5 = 1'b0;
  rpmos p1(w6, vdd, gn);     assign (pull1, pull0) w6 = 1'b0;
  rtranif1 t1(vdd, w7, g);   assign (pull1, pull0) w7 = 1'b0;
  assign st = one;
  rtran t2(st, w8);          assign (pull1, pull0) w8 = 1'b0;
  rnmos r6(w9, vdd, g2);     assign (weak1, weak0) w9 = 1'b0;
  initial begin
    g = 1; gn = 0; g2 = 0; one = 1;
    #1 $display("%b%b%b%b %b%b%b%b %b", w1, w2, w3, w4, w5, w6, w7, w8, w9);
    $finish(0);
  end
endmodule
