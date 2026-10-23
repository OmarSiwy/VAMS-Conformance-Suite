// IEEE 1364-2005 §7.11, p. 100: "The tran, tranif0, and tranif1 switches shall
// not affect signal strength across the bidirectional terminals, except that
// a supply strength shall be reduced to a strong strength." §7.13.3: "The
// supply0 and supply1 net types shall have supply driving strengths."
// §17.1.1.5, pp. 283-284: %v prints a Table 17-5 mnemonic (St strong 6) and
// the logic value.
//
// vdd is a supply1 net: Su1 from time 0, with no driver that ever changes.
// t1 is an uncontrolled tran, so it conducts from time 0, and c has no
// driver of its own: c carries vdd's Su1 reduced to strong, St1, value 1.
// Printed at #1. Line: "St1 1".
//! inherited IEEE 1364-2005 7.11
//! inherited IEEE 1364-2005 17.1.1.5
`timescale 1ns/1ns
module b_7_11_tran_from_supply_undriven;
  supply1 vdd;
  wire c;
  tran t1(vdd, c);
  initial begin
    #1 $display("%v %b", c, c);
    $finish(0);
  end
endmodule
