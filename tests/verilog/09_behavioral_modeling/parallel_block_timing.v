// IEEE 1364-2005 §9.8.2, p. 141: "A parallel block shall have the following
// characteristics: — Statements shall execute concurrently. — Delay values for
// each statement shall be considered relative to the simulation time of
// entering the block. — Delay control can be used to provide time-ordering for
// assignments. — Control shall pass out of the block when the last
// time-ordered statement executes." ... "The timing controls in a fork-join
// block do not have to be ordered sequentially in time."
// §9.8.4, p. 142: "For parallel blocks, the start time is the same for all the
// statements, and the finish time is when the last time-ordered statement has
// been executed." ... "Execution shall not continue to the statement following
// a block until the finish time for the block has been reached, that is, until
// the block has completely finished executing."
// Example 1 (p. 142): the 9.8.2 waveform written in reverse order "and still
// producing the same waveform". Example 2: "The two events can occur in any
// order (or even at the same simulation time), the fork-join block will
// complete, and the assignment will be made."
//
//   Waveform: fork entered at t=10; #250 -> end_wave, #200 r = 'hF7, #150 r =
//   'h00, #100 r = 'hE2, #50 r = 'h35, each relative to entry: r = 35 at 60,
//   e2 at 110, 00 at 160, f7 at 210, end_wave at 260 — the order of 9.8.1's
//   waveform, though written backwards. The join passes at 260 (its last
//   statement); "after-wave 261" (#1 so it does not race the watcher).
//   Joining events: at t=300 fork @Aevent; @Bevent; join; areg = breg. Bevent
//   fires at 305, Aevent at 310: the fork finishes at 310 -> "joined 310 4"
//   (breg = 4). A begin-end block would still wait for a later Bevent.
//! inherited IEEE 1364-2005 9.8.2 9.8.4
`timescale 1ns/1ns
module b_9_8_4_parallel_block_timing;
  reg [7:0] r;
  integer areg, breg;
  event end_wave, Aevent, Bevent;

  always @(r) if ($time > 0) $display("%0d %h", $time, r);
  always @end_wave $display("end_wave %0d", $time);

  initial begin
    r = 8'h00;
    #10 fork
      #250 -> end_wave;
      #200 r = 'hF7;
      #150 r = 'h00;
      #100 r = 'hE2;
      #50 r = 'h35;
    join
    #1 $display("after-wave %0d", $time);
    #39 breg = 4;
    areg = 0;
    fork
      @Aevent;
      @Bevent;
    join
    areg = breg;
    $display("joined %0d %0d", $time, areg);
    $finish(0);
  end

  initial begin
    #305 -> Bevent;
    #5 -> Aevent;
  end
endmodule
