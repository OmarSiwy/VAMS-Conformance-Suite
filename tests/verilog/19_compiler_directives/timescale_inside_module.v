//! inherited IEEE 1364-2005 19.8
// §19.8 places no outside-a-module restriction on `timescale: the directive
// inside the module is legal (no_timescale_in_module).
`timescale 1ns/1ps
module triage_timescale_inside_module;
`timescale 1us/1ns
  initial $display("PASSED");
endmodule
