// IEEE 1364-2005 A.7.4, p. 501:
//   list_of_path_delay_expressions ::= t_path_delay_expression
//     | trise_path_delay_expression , tfall_path_delay_expression
//     | trise_path_delay_expression , tfall_path_delay_expression , tz_path_delay_expression
//     | ...
// The two alternatives elided here list six and twelve expressions (spelled
// out in b_A_7_4_path_delays.v's header): a path delay list has 1, 2, 3, 6
// or 12 of them.
//
// `(a => y) = (1, 2, 3, 4);` has four. Legal neighbour:
// b_A_7_4_path_delays.v.
//! inherited IEEE 1364-2005 A.7.4
//! reject E0207
//! reject a path delay lists 1, 2, 3, 6 or 12 values
//! neighbour b_A_7_4_path_delays.v
module b_A_7_4_four_path_delays_rejected (a, y);
  input a;
  output y;
  assign y = a;
  specify
    (a => y) = (1, 2, 3, 4);
  endspecify
endmodule
