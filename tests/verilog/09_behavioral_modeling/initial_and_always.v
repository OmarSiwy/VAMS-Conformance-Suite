// IEEE 1364-2005 §9.9, p. 143: "The initial and always constructs are enabled
// at the beginning of a simulation. The initial construct shall execute only
// once, and its activity shall cease when the statement has finished. In
// contrast, the always construct shall execute repeatedly. Its activity shall
// cease only when the simulation is terminated." ... "There shall be no limit
// to the number of initial and always constructs that can be defined in a
// module."
// §9.1, p. 116, the model `behave`: "the reg variables a and b initialize to 1
// and 0, respectively, at simulation time zero." ... "reg a inverts after 50
// time units and reg b inverts after 100 time units. Because the always
// constructs repeat, this model will produce two square waves. The reg a
// toggles with a period of 100 time units, and reg b toggles with a period of
// 200 time units."
//
// behave's body, reg [1:0] a = 'b1 = 01 and b = 'b0 = 00 at t=0:
//   a = ~a at 50, 100, 150, 200: 10, 01, 10, 01
//   b = ~b at 100, 200: 11, 00
// Sampled between the edges (so no sample races an update):
//   t=25 01 00; t=75 10 00; t=125 01 11; t=175 10 11; t=225 01 00
// runs: the initial that adds 1 executes once -> 1 at every sample.
// ticks: always #50 ticks = ticks + 1 repeats -> 0, 1, 2, 3, 4 at the samples.
//! inherited IEEE 1364-2005 9.1 9.9 9.9.1 9.9.2
`timescale 1ns/1ns
module b_9_9_initial_and_always;
  reg [1:0] a, b;
  integer runs, ticks;

  initial begin
    a = 'b1;
    b = 'b0;
  end
  always begin
    #50 a = ~a;
  end
  always begin
    #100 b = ~b;
  end

  initial begin
    runs = 0;
    runs = runs + 1;
  end
  initial ticks = 0;
  always #50 ticks = ticks + 1;

  initial begin
    #25 repeat (5) begin
      $display("%0d %b %b %0d %0d", $time, a, b, runs, ticks);
      #50;
    end
    $finish(0);
  end
endmodule
