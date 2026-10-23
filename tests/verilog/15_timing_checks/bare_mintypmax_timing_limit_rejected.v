//! inherited IEEE 1364-2005 A.7.5.2
//! reject unexpected token: found `:`
// timing_check_limit is an expression; 0:0:0 is a mintypmax_expression and is
// legal only parenthesised (timing_check_syntax).
module triage_bare_mintypmax_timing_limit_rejected(clk, d);
  input clk, d;

  specify
    $setup(d, posedge clk, 0:0:0);
  endspecify
endmodule
