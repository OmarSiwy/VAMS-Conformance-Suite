// IEEE 1364-2005 §4.6.3, p. 28: "Capacitive state When all the drivers of a
// trireg net are at the high-impedance value (z), the trireg net retains its
// last driven value; the high-impedance value does not propagate from the
// driver to the trireg." §4.6.3.1, p. 28: "In a capacitive network whose
// trireg nets are in the capacitive state, logic and strength values can
// propagate between trireg nets."
//
// Figure 4-2's network (p. 29): nmos_1 (gate a) drives trireg_la from c,
// nmos_2 (gate a) drives trireg_me1 from d, tranif1_1 (gate b) joins
// trireg_la to trireg_sm and tranif1_2 (gate b) joins trireg_me1 to
// trireg_me2. trireg_la is large, trireg_sm small, the other two medium.
// Its table, one row per 10 time units, read 1 unit after each change:
//   t=0  a b c d = 1 1 1 1: c and d drive every trireg     -> 1 1 1 1
//   t=10 b = 0: sm and me2 are cut off and hold 1           -> 1 1 1 1
//   t=20 c = 0: c drives 0 into la; sm still holds 1        -> 0 1 1 1
//   t=30 d = 0: d drives 0 into me1; me2 still holds 1      -> 0 1 0 1
//   t=40 a = 0: la and me1 are cut off and hold 0           -> 0 1 0 1
//   t=50 b = 1: la (large 0) joins sm (small 1): "the smaller trireg net
//        [stores] the value of the larger", so sm = 0; me1 (medium 0) joins
//        me2 (medium 1), same size, "both ... change value to x"
//                                                           -> 0 0 x x
//! inherited IEEE 1364-2005 4.6.3 4.6.3.1
// native-required
module b_4_6_3_1_capacitive_network_figure_4_2;
  reg a, b, c, d;
  trireg (large) trireg_la;
  trireg (small) trireg_sm;
  trireg trireg_me1, trireg_me2;
  nmos nmos_1(trireg_la, c, a);
  nmos nmos_2(trireg_me1, d, a);
  tranif1 tranif1_1(trireg_la, trireg_sm, b);
  tranif1 tranif1_2(trireg_me1, trireg_me2, b);
  initial begin
    a = 1; b = 1; c = 1; d = 1;
    #1 $display("%b %b %b %b", trireg_la, trireg_sm, trireg_me1, trireg_me2);
    #9 b = 0;
    #1 $display("%b %b %b %b", trireg_la, trireg_sm, trireg_me1, trireg_me2);
    #9 c = 0;
    #1 $display("%b %b %b %b", trireg_la, trireg_sm, trireg_me1, trireg_me2);
    #9 d = 0;
    #1 $display("%b %b %b %b", trireg_la, trireg_sm, trireg_me1, trireg_me2);
    #9 a = 0;
    #1 $display("%b %b %b %b", trireg_la, trireg_sm, trireg_me1, trireg_me2);
    #9 b = 1;
    #1 $display("%b %b %b %b", trireg_la, trireg_sm, trireg_me1, trireg_me2);
    $finish(0);
  end
endmodule
