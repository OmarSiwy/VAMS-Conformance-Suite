// IEEE 1364-2005 §14.3, p. 222: "There may be one, two, three, six, or
// twelve delay values assigned to a module path, as described in 14.3.1."
// §14.3.1's Table 14-2 (p. 223) has a column for each of those five counts
// and no other; Syntax 14-6 (p. 222) lists the same five arms of
// list_of_path_delay_expressions.
//
// (C => Q) = (1, 2, 3, 4) gives four. Legal neighbour:
// path_delay_values.v, one path for each of the five counts.
//! inherited IEEE 1364-2005 14.3 14.3.1
//! reject E0207
//! reject 1, 2, 3, 6 or 12
//! neighbour path_delay_values.v
`timescale 1ns/1ns
module b_14_3_1_four_delay_values_rejected(C, Q);
  input C;
  output Q;
  assign Q = C;
  specify
    (C => Q) = (1, 2, 3, 4);
  endspecify
endmodule
