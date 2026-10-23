// IEEE 1364-2005 8.1.4: "It is illegal to have the same combination of
// inputs, including edges, specified for different outputs." `0 ?` covers
// 0 0, 0 1 and 0 x; `0 0` names 0 0 again with output 0 against 1. The
// definition is not instantiated: the table itself is illegal.
// overlapping_entries_agree.v is the legal neighbour, where the
// overlapping entries agree.
//! lrm A.5.3
//! inherited IEEE 1364-2005 8.1.4
//! reject E0248
//! reject entries 1 and 2 share an input combination and give it 1 and 0
//! neighbour overlapping_entries_agree.v
primitive conflict_udp(q, a, b);
  output q;
  input a, b;
  table
    0 ? : 1;
    0 0 : 0;
  endtable
endprimitive
module b_8_1_4_conflicting_entries_rejected;
  initial begin $display("definition accepted"); $finish(0); end
endmodule
