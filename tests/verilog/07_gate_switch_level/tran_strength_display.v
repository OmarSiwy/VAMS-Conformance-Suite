// IEEE 1364-2005 §7.11, p. 100: "The tran, tranif0, and tranif1 switches shall
// not affect signal strength across the bidirectional terminals, except that
// a supply strength shall be reduced to a strong strength." §17.1.1.5,
// pp. 283-284: "%v format specification is used to display the strength of
// scalar nets", three characters: a Table 17-5 mnemonic (Su supply 7, St
// strong 6, Pu pull 5, ...) then the logic value.
//
// Each displayed net has one strength, so every value is a mnemonic:
//   a  `assign (pull1, pull0) a = 1'b1`, its own driver; t1 joins it to b,
//      which carries nothing back but a's own value -> Pu1
//   b  no driver of its own: t1 passes a's Pu1 unreduced -> Pu1
// A net whose only source is a pass switch is not undriven: HiZ for b would
// drop what the switch carries. (A supply net through a switch onto an
// undriven net is tran_from_supply_undriven.v.)
// Printed at #1, after every continuous assignment and switch has settled.
// Line: "Pu1 Pu1".
//! inherited IEEE 1364-2005 7.11
//! inherited IEEE 1364-2005 17.1.1.5
`timescale 1ns/1ns
module b_7_11_tran_strength_display;
  wire a, b;
  assign (pull1, pull0) a = 1'b1;
  tran t1(a, b);
  initial begin
    #1 $display("%v %v", a, b);
    $finish(0);
  end
endmodule
