// IEEE 1364-2005 A.7.5.2, p. 503:
//   notifier ::= variable_identifier
// A notifier names a variable (the reg the check toggles); it is not an
// expression.
//
// `$setup(d, posedge clk, 1, ntfr + 1);` gives an expression as the
// notifier. Legal neighbour: b_A_7_5_system_timing_checks.v
// (`$setup(d, posedge clk, 1, ntfr);`).
//! inherited IEEE 1364-2005 A.7.5.2
//! reject E0207
//! reject names a variable (A.7.5.2 notifier ::= variable_identifier)
//! neighbour b_A_7_5_system_timing_checks.v
module b_A_7_5_2_expression_notifier_rejected (clk, d, y);
  input clk, d;
  output y;
  reg ntfr;
  assign y = d;
  specify
    $setup(d, posedge clk, 1, ntfr + 1);
  endspecify
endmodule
