// IEEE 1364-2005 A.7.5.1, p. 502:
//   $setup_timing_check ::= $setup ( data_event , reference_event , timing_check_limit [ , [ notifier ] ] ) ;
// The timing_check_limit is not optional: only the notifier after it is.
//
// `$setup(d, posedge clk);` stops after the two events. Legal neighbour:
// b_A_7_5_system_timing_checks.v (`$setup(d, posedge clk, 1, ntfr);`).
//! inherited IEEE 1364-2005 A.7.5.1
//! reject E0207
//! reject `$setup` takes 3 to 4 arguments
//! neighbour b_A_7_5_system_timing_checks.v
module b_A_7_5_1_setup_without_limit_rejected (clk, d, y);
  input clk, d;
  output y;
  reg ntfr;
  assign y = d;
  specify
    $setup(d, posedge clk);
  endspecify
endmodule
