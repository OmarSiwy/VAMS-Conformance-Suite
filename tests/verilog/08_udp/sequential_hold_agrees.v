// IEEE 1364-2005 8.1.4 with 8.1.6's `-`: entry 4, `1 0 : 1 : 1`, overlaps
// the hold entry `? 0 : ? : -` only at state 1, where the hold's next state
// is also 1, so the two agree and the table is legal. It is the legal
// neighbour of sequential_hold_conflict_rejected.v, which differs
// in that entry's current state (0) and has no `0 1` entry.
// By hand, a latch with entries 1 1 : ? : 1, 0 1 : ? : 0 and the hold:
//   d=1 en=1 -> 1; en=0 then d=0 -> holds 1; d=0 en=1 -> 0; en=0, d=1 -> 0.
//! lrm A.5.3
//! inherited IEEE 1364-2005 8.1.4 8.1.6
`timescale 1ns/1ns
primitive latch_agree(q, d, en);
  output q; reg q;
  input d, en;
  table
  // d en : q : q+
     1  1 : ? : 1;
     0  1 : ? : 0;
     ?  0 : ? : -;
     1  0 : 1 : 1;
  endtable
endprimitive
module b_8_1_4_sequential_hold_agrees;
  reg d, en;
  wire q;
  latch_agree u(q, d, en);
  initial begin
    d = 1; en = 1; #1 $display("load1 %b", q);
    en = 0; #1 d = 0; #1 $display("hold1 %b", q);
    en = 1; #1 $display("load0 %b", q);
    en = 0; #1 d = 1; #1 $display("hold0 %b", q);
    $finish(0);
  end
endmodule
