// IEEE 1364-2005 §7.6: "The bidirectional terminals of all six devices shall
// be connected only to scalar nets or bit-selects of vector nets." "The
// rtran, rtranif0, and rtranif1 devices shall reduce the strength of the
// signals passing through them according to rules discussed in 7.12", Table
// 7-8 "Strong drive -> Pull drive"; §7.11 "The tran, tranif0, and tranif1
// switches shall not affect signal strength ... except that a supply
// strength shall be reduced to a strong strength." "The delay specifications
// for tranif1, tranif0, rtranif1, and rtranif0 devices shall be zero, one, or
// two delays. If the specification contains two delays, the first delay shall
// determine the turn-on delay, the second delay shall determine the turn-off
// delay".
//
// HAND DERIVATION. s is driven strong 1; n and m each carry their own pull 0.
// s, n, m and bus[1] are one switch-connected net (§7.6's "all the devices in
// a bidirectional switch-connected net").
//   n: s's St1 arrives through rtran r as Pu1 (Table 7-8) and meets n's own
//      Pu0: equal strengths, opposite values, so x (§7.10.1). m's Pu0 reaches
//      n through t and r and is weaker still.
//   m: s's St1 arrives through tran t unreduced and beats m's Pu0: 1.
//   bus: bit 1 is joined to s through v and reads 1; bit 0 is on no switch
//      and undriven: z. So bus = 1z.
//   b: en starts at x (§3.2) and becomes 0 at t=0; that change turns the
//      tranif1 g off only after the turn-off delay, 3. Until t=3 its
//      conduction is unknown, so what a's 1 asserts on b is 1-or-z (§7.10.2's
//      H), which reads x at t=1. After t=3 g is off and b is undriven, z.
//      en rises at t=10; the turn-on delay is 2, so b is still z at 11 and is
//      a's 1 at 12. en falls at t=20; the turn-off delay is 3, so b still
//      reads 1 at 22 and is z again at 23.
//! inherited IEEE 1364-2005 7.6 (bit-select terminals, pass switch delays)
//! inherited IEEE 1364-2005 7.11 7.12 (strength across tran and rtran)
// native-required
`timescale 1ns/1ns
module audit_switch_bits_strength_delay;
  reg d, en;
  wire s, n, m, a, b;
  wire [1:0] bus;
  assign s = d;
  assign (pull0, pull1) n = 1'b0;
  assign (pull0, pull1) m = 1'b0;
  rtran r(s, n);
  tran t(s, m);
  tran v(s, bus[1]);
  assign a = d;
  tranif1 #(2, 3) g(a, b, en);
  initial begin
    d = 1; en = 0;
    #1 $display("n=%b m=%b bus=%b b=%b", n, m, bus, b);
    #9 en = 1;
    #1 $display("%0d b=%b", $time, b);
    #1 $display("%0d b=%b", $time, b);
    #8 en = 0;
    #2 $display("%0d b=%b", $time, b);
    #1 $display("%0d b=%b", $time, b);
  end
endmodule
