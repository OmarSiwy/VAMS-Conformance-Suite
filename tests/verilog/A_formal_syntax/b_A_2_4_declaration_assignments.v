// IEEE 1364-2005 A.2.4, p. 491:
//   defparam_assignment ::= hierarchical_parameter_identifier = constant_mintypmax_expression
//   net_decl_assignment ::= net_identifier = expression
//   param_assignment ::= parameter_identifier = constant_mintypmax_expression
//   specparam_assignment ::= specparam_identifier = constant_mintypmax_expression
//     | pulse_control_specparam
//   pulse_control_specparam ::= PATHPULSE$ = ( reject_limit_value [ , error_limit_value ] )
//     | PATHPULSE$specify_input_terminal_descriptor$specify_output_terminal_descriptor
//         = ( reject_limit_value [ , error_limit_value ] )
//   error_limit_value ::= limit_value
//   reject_limit_value ::= limit_value
//   limit_value ::= constant_mintypmax_expression
//
// defparam c.K = 3 + 4 (a hierarchical_parameter_identifier)   -> c.k = 7
// wire n = r ^ 1'b1, r = 0, a net_decl_assignment of an expression -> n = 1
// parameter P = 2 * 3                                          -> P = 6
// specparam SP = 9                                             -> SP = 9
// In the specify block, the two pulse_control_specparam forms, each with a
// reject limit only (both limits: b_A_2_4_pathpulse_error_limit.v). W0251:
// VerA reads the specify block and models nothing in it, so the PATHPULSE$
// limits change nothing printed.
// Output: "k=7 n=1 P=6 SP=9".
//! inherited IEEE 1364-2005 A.2.4 14.6 14.6.1
`timescale 1ns/1ns
module b_A_2_4_child (a, y);
  input a;
  output y;
  parameter K = 0;
  wire [3:0] k = K;
  assign y = a;
  specify
    specparam PATHPULSE$ = (1);
    specparam PATHPULSE$a$y = (2);
    (a => y) = 1;
  endspecify
endmodule
module b_A_2_4_declaration_assignments;
  reg r;
  wire y;
  wire n = r ^ 1'b1;
  parameter P = 2 * 3;
  specparam SP = 9;
  defparam c.K = 3 + 4;
  b_A_2_4_child c (r, y);
  initial begin
    r = 0;
    #1 $display("k=%0d n=%b P=%0d SP=%0d", c.k, n, P, SP);
    $finish(0);
  end
endmodule
