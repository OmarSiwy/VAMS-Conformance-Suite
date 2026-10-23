// The design time_scaling.c runs (VAMS-2023 12.31.2): two modules, two time
// units, one precision. No `//!` directive, so the suite does not collect it
// (tests/suite.zig `fixtureExt`).
//
// b7_scales is compiled under `timescale 1ns/1ns and b7_scales_sub under
// `timescale 1us/1ns (a directive applies to the definitions after it). The
// finest precision anywhere is 1 ns, so the simulation time unit is 1 ns and
// one vpiSimTime tick is 1 ns. In b7_scales_sub's unit, 3.0 is 3 us = 3000
// ticks and 0.5 is 0.5 us = 500 ticks; in b7_scales's, 3.0 is 3 ticks. All
// three are exact in binary64, so no rounding question arises.
//
// THE TIMELINE: tick = 0 at t=0, tick = 1 at t=3000 (3 us), $finish at 5000.
`timescale 1ns/1ns

module b7_scales;
  reg [7:0] tick;

  b7_scales_sub u();

  initial begin
    tick = 8'h00;
    #3000 tick = 8'h01;
    #2000 $finish(0);
  end
endmodule

`timescale 1us/1ns

module b7_scales_sub;
  reg idle;
  initial idle = 1'b0;
endmodule
