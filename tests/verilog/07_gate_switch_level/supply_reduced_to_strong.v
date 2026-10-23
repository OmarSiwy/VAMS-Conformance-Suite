// IEEE 1364-2005 §7.11, p. 100: "The nmos, pmos, and cmos switches shall pass
// the strength from the data input to the output, except that a supply
// strength shall be reduced to a strong strength. The tran, tranif0, and
// tranif1 switches shall not affect signal strength across the bidirectional
// terminals, except that a supply strength shall be reduced to a strong
// strength."
//
// vdd is a supply1 net (Su1, §7.13.3). Each switch below passes it onto a net
// that also has a strong 0 driver:
//   w1 nmos (g=1), w2 tran, w3 cmos (n=1, p=0), w6 pmos (p=0), w7 tranif1
//   (g=1): the supply 1 arrives as St1 and meets St0 -> x. Unreduced, Su1(7)
//   would beat St0(6) and read 1.
// And strength other than supply passes unchanged:
//   w4: a Pu1 through nmos vs We0 -> 1 (Pu1 still beats weak);
//   w5: the same Pu1 through nmos vs Pu0 -> x (not raised to strong).
// Line: "xxx 1x xx".
//! inherited IEEE 1364-2005 7.11
// native-required
`timescale 1ns/1ns
module b_7_11_supply_reduced_to_strong;
  supply1 vdd;
  reg g, gn;
  wire w1, w2, w3, w4, w5, w6, w7, src;
  nmos n1(w1, vdd, g);       assign (strong1, strong0) w1 = 1'b0;
  tran t1(vdd, w2);          assign (strong1, strong0) w2 = 1'b0;
  cmos c1(w3, vdd, g, gn);   assign (strong1, strong0) w3 = 1'b0;
  assign (pull1, pull0) src = 1'b1;
  nmos n2(w4, src, g);       assign (weak1, weak0) w4 = 1'b0;
  nmos n3(w5, src, g);       assign (pull1, pull0) w5 = 1'b0;
  pmos p1(w6, vdd, gn);      assign (strong1, strong0) w6 = 1'b0;
  tranif1 t2(vdd, w7, g);    assign (strong1, strong0) w7 = 1'b0;
  initial begin
    g = 1; gn = 0;
    #1 $display("%b%b%b %b%b %b%b", w1, w2, w3, w4, w5, w6, w7);
    $finish(0);
  end
endmodule
