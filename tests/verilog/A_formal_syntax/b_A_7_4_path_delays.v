// IEEE 1364-2005 A.7.4, p. 500-501:
//   path_delay_value ::= list_of_path_delay_expressions | ( list_of_path_delay_expressions )
//   list_of_path_delay_expressions ::= t_path_delay_expression
//     | trise_path_delay_expression , tfall_path_delay_expression
//     | trise_path_delay_expression , tfall_path_delay_expression , tz_path_delay_expression
//     | t01_path_delay_expression , t10_path_delay_expression , t0z_path_delay_expression ,
//       tz1_path_delay_expression , t1z_path_delay_expression , tz0_path_delay_expression
//     | t01_path_delay_expression , t10_path_delay_expression , t0z_path_delay_expression ,
//       tz1_path_delay_expression , t1z_path_delay_expression , tz0_path_delay_expression ,
//       t0x_path_delay_expression , tx1_path_delay_expression , t1x_path_delay_expression ,
//       tx0_path_delay_expression , txz_path_delay_expression , tzx_path_delay_expression
//   path_delay_expression ::= constant_mintypmax_expression
//
// One path per form: a bare single delay and a parenthesized one, then two,
// three, six and twelve delays, the last with a specparam in it. Every source
// transitions at time 0; y's x -> 1 then takes the smallest of the active
// paths' Table 14-2/14-3 delays (§14.3.3), at most 12, so at t=20 y = a = 1.
// (A min:typ:max path_delay_expression is b_A_7_4_mintypmax_path_delay.v.)
// Output: "y=1".
//! inherited IEEE 1364-2005 A.7.4
`timescale 1ns/1ns
module b_A_7_4_cell (a, b, c, d, e, f, y);
  input a, b, c, d, e, f;
  output y;
  assign y = a;
  specify
    specparam T = 2;
    (a => y) = 1;
    (b => y) = (1);
    (c => y) = (1, 2);
    (d => y) = (1, 2, 3);
    (e => y) = (1, 2, 3, 4, 5, 6);
    (f => y) = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, T);
  endspecify
endmodule
module b_A_7_4_path_delays;
  wire y;
  b_A_7_4_cell c (1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, y);
  initial #20 begin
    $display("y=%b", y);
    $finish(0);
  end
endmodule
