// IEEE 1364-2005 8.1.4, sequential: the current state is part of the
// combination, and `-` (8.1.6, "no change") means the next state equals the
// current one. Entry 2, `? 0 : ? : -`, holds: at current state 0 its next
// state is 0. Entry 3, `1 0 : 0 : 1`, names d = 1, en = 0, state 0 again
// with next state 1. Same combination, different outputs.
// The legal neighbour is sequential_hold_agrees.v, whose `1 0`
// entry asks for state 1 instead, where the hold also gives 1.
//! lrm A.5.3
//! inherited IEEE 1364-2005 8.1.4 8.1.6
//! reject E0248
//! reject entries 2 and 3 share an input combination and give it 0 and 1
//! neighbour sequential_hold_agrees.v
primitive latch_conflict(q, d, en);
  output q; reg q;
  input d, en;
  table
  // d en : q : q+
     1  1 : ? : 1;
     ?  0 : ? : -;
     1  0 : 0 : 1;
  endtable
endprimitive
module b_8_1_4_sequential_hold_conflict_rejected;
  initial begin $display("definition accepted"); $finish(0); end
endmodule
