// IEEE 1364-2005 §6.2.1, pp. 72-73: "Variable declaration assignments to an
// array are not allowed." ... "Example 2—The following example is not legal:
//   reg [3:0] array [3:0] = 0;"
//
// The clause's Example 2, verbatim. Legal neighbour: examples.v's
// `reg[3:0] a = 4'h4;`, the same declaration without the array dimension.
//! inherited IEEE 1364-2005 6.2.1
//! reject E1100
//! reject an unpacked array declaration takes no initializer
//! neighbour examples.v
module b_6_2_1_array_declaration_assignment_rejected;
  reg [3:0] array [3:0] = 0;
  initial #1 $display("%b", array[0]);
endmodule
