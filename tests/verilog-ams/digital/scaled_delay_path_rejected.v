// AMS §2.6.2 forbids scaled digital delays even without a # token: A.7.4's
// path_delay_expression supplies a module path's delay. Legal neighbours:
// ieee1364/14_specify_blocks/path_delay_values.v and
// mintypmax_path_delays.v run with legal path values and pin W0251,
// which explicitly names the current absence of module-path execution.
//! lrm 2.6.2
//! lrm 2.6.2:3
//! reject E0247
//! neighbour ../../verilog/14_specify_blocks/path_delay_values.v
module scaled_delay_path_rejected(input a, output y);
  buf g(y, a);
  specify
    (a => y) = 1u;
  endspecify
endmodule
