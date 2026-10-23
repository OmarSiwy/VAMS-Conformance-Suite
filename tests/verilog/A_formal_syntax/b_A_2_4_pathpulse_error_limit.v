// IEEE 1364-2005 A.2.4, p. 491:
//   pulse_control_specparam ::= PATHPULSE$ = ( reject_limit_value [ , error_limit_value ] )
//     | PATHPULSE$specify_input_terminal_descriptor$specify_output_terminal_descriptor
//         = ( reject_limit_value [ , error_limit_value ] )
//
// Both forms with both limits: PATHPULSE$ = (1, 2) and PATHPULSE$a$y =
// (1, 2). W0251: VerA reads the specify block and models nothing in it, so
// b_A_2_4_pp runs as a plain buffer of the top's 1'b1: y = 1 at t=1 ->
// "y=1".
//! inherited IEEE 1364-2005 A.2.4 14.6 14.6.1
`timescale 1ns/1ns
module b_A_2_4_pp (a, y);
  input a;
  output y;
  assign y = a;
  specify
    specparam PATHPULSE$ = (1, 2);
    specparam PATHPULSE$a$y = (1, 2);
    (a => y) = 1;
  endspecify
endmodule
module b_A_2_4_pathpulse_error_limit;
  wire y;
  b_A_2_4_pp u (1'b1, y);
  initial #1 begin
    $display("y=%b", y);
    $finish(0);
  end
endmodule
