// Two modules with two different `timescale units and one shared precision, so
// LRM 12.15's "using the time scale of the object" is a question with three
// different right answers at one instant.
//
// p02_scales_top is compiled under `timescale 1ns/1ps and p02_scales_sub under
// `timescale 1us/1ps, because a directive applies to the module DEFINITIONS
// that follow it. The finest precision anywhere is 1 ps, so that is the global
// simulation time unit and every vpiSimTime reading below is in picoseconds.
//
// The one event that matters is at #3 of the top module's own unit, i.e.
// 3 ns = 3000 ps. 13_get_time_scaling.c reads the clock there three ways.

`timescale 1ns/1ps

module p02_scales_top;
  reg [7:0] tick;

  p02_scales_sub u();

  initial begin
    tick = 8'h00;
    #3 tick = 8'h01;    // t = 3 ns = 3000 ps
    #7 $finish(0);      // t = 10 ns, the backstop
  end
endmodule

`timescale 1us/1ps

module p02_scales_sub;
  reg [7:0] idle;
  initial idle = 8'h00;
endmodule
