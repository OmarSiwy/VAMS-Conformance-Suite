// IEEE 1364-2005 §8.1.6, p. 108, Table 8-1: "- No change Permitted only in
// the output field of a sequential UDP."
//
// comb_dash is combinational (no reg, no current-state field) and its first
// row's output is -. Legal neighbour: table_symbols.v's rf, where -
// is the output of a sequential UDP.
//! inherited IEEE 1364-2005 8.1.6
//! reject E0233
//! reject `-` is not a UDP output symbol
//! neighbour table_symbols.v
primitive comb_dash(q, a);
  output q;
  input a;
  table
    0 : -;
    1 : 0;
  endtable
endprimitive

module b_8_1_6_no_change_in_combinational_rejected;
  initial $finish(0);
endmodule
