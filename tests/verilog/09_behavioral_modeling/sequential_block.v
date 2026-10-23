// IEEE 1364-2005 §9.8, p. 139: "The sequential block shall be delimited by the
// keywords begin and end. The procedural statements in sequential block shall
// be executed sequentially in the given order."
// §9.8.1, p. 140: "A sequential block shall have the following
// characteristics: — Statements shall be executed in sequence, one after
// another. — Delay values for each statement shall be treated relative to the
// simulation time of the execution of the previous statement. — Control shall
// pass out of the block after the last statement executes."
// Example 1: "areg = breg; creg = areg; // creg stores the value of breg"
// Example 3: the waveform "#d r = 'h35; #d r = 'hE2; #d r = 'h00; #d r =
// 'hF7; #d -> end_wave;" with "parameter d = 50;".
//
//   Example 1, breg = 7: areg = 7, then creg = areg = 7        -> "7 7"
//   Example 3, entered at t=0: each #50 counts from the previous statement,
//   so r = 35 at 50, e2 at 100, 00 at 150, f7 at 200, end_wave at 250; the
//   watcher prints each change (not the time-0 initialisation, which races
//   its first wait). Control leaves the block after its last statement, at
//   250; the next statement is #1, so "out 251" (the 1 keeps it from racing
//   the end_wave watcher at 250).
//! inherited IEEE 1364-2005 9.8 9.8.1
`timescale 1ns/1ns
module b_9_8_1_sequential_block;
  parameter d = 50;
  reg [7:0] r;
  integer areg, breg, creg;
  event end_wave;

  always @(r) if ($time > 0) $display("%0d %h", $time, r);
  always @end_wave $display("end_wave %0d", $time);

  initial begin
    breg = 7;
    begin
      areg = breg;
      creg = areg;
    end
    $display("%0d %0d", areg, creg);
    r = 8'h00;
    begin
      #d r = 'h35;
      #d r = 'hE2;
      #d r = 'h00;
      #d r = 'hF7;
      #d -> end_wave;
    end
    #1 $display("out %0d", $time);
    $finish(0);
  end
endmodule
