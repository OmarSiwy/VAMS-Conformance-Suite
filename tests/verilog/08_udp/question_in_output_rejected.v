// IEEE 1364-2005 §8.1.6, p. 108, Table 8-1: "? Iteration of 0, 1, and x ...
// Not permitted in output field."
//
// The first row's output field is ?. Legal neighbour:
// table_symbols.v, which uses ? only in input fields.
//! inherited IEEE 1364-2005 8.1.6
//! reject E0233
//! reject `?` is not a UDP output symbol
//! neighbour table_symbols.v
primitive query_out(q, a);
  output q;
  input a;
  table
    0 : ?;
    1 : 0;
  endtable
endprimitive

module b_8_1_6_question_in_output_rejected;
  initial $finish(0);
endmodule
