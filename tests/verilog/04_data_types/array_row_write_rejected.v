// IEEE 1364-2005 §4.9.3.1.2, p. 35: "arrayb[1] = 0;   // Illegal Syntax -
// Attempt to write to elements [1][0]..[1][255]".
//
// arrayb is the clause's reg arrayb[7:0][0:255]; arrayb[1] selects one of
// its two dimensions only. Legal neighbour:
// array_declarations.v (arrayb[1][0] = 0).
//! inherited IEEE 1364-2005 4.9.3.1.2
//! reject E1100
//! reject requires an element index
//! neighbour array_declarations.v
module b_4_9_3_1_2_array_row_write_rejected;
  reg arrayb[7:0][0:255];
  initial arrayb[1] = 0;
endmodule
