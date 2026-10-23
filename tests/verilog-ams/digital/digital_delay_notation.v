// AMS §2.6.2 permits decimal/scientific real notation but forbids scale
// factors in digital delays. IEEE 1364 §19.8 measures each delay in the
// module's time units and rounds to its precision. Here the unit is 1ns,
// precision 1ps; every delay is an exact whole number of precision ticks.
//
// Cumulative times in ns, derived from the delays below:
//   2.5; +0.25=2.75; +D(0.25)=3; blocking +0.125=3.125;
//   the NBA scheduled at 3.125 arrives at 3.25; +0.25 observes it at 3.375;
//   +D/2=3.5; +runtime_delay(0.125)=3.625;
//   +5e3=5003.625. Thus #5e3 waits five microseconds under this timescale.
//
// A scale factor is still legal in an ordinary expression and in a module
// parameter overrides: conductance=1m=0.001, u.g=2m=0.002, v.g=3m=0.003.
// The # introducing a named or positional parameter override does not
// introduce a digital delay. Invalid
// neighbours: scaled_delay_rejected.v and scaled_delay_nonblocking_rejected.v.
//! lrm 2.6.2
//! expect stdout digital_delay_notation.expected.txt
`timescale 1ns/1ps
module digital_delay_units;
  parameter real g = 1m;
endmodule
module digital_delay_notation;
  parameter real D = 0.25;
  real runtime_delay, conductance;
  reg q;
  digital_delay_units #(.g(2m)) u();
  digital_delay_units #(3m) v();
  initial begin
    q = 0;
    runtime_delay = 0.125;
    conductance = 1m;
    #2.5 $display("decimal %0.3f", $realtime);
    #2.5e-1 $display("scientific %0.3f", $realtime);
    #D $display("parameter %0.3f", $realtime);
    q = #0.125 1;
    $display("blocking %0.3f %b", $realtime, q);
    q <= #1.25e-1 0;
    #0.25 $display("nonblocking %0.3f %b", $realtime, q);
    #(D / 2.0) $display("expression %0.3f", $realtime);
    #runtime_delay $display("variable %0.3f", $realtime);
    #5e3 $display("microseconds %0.3f", $realtime);
    $display("scales %0.3f %0.3f %0.3f", conductance, u.g, v.g);
    $finish(0);
  end
endmodule
