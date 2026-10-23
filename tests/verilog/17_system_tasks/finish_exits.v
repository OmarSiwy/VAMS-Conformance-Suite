// IEEE 1364-2005 §17.4, p. 302: "There are two simulation control system
// tasks: a) $finish b) $stop". §17.4.1, p. 302: "The $finish system task
// simply makes the simulator exit and pass control back to the host operating
// system. If an expression is supplied to this task, then its value (0, 1, or
// 2) determines the diagnostic messages that are printed before the prompt is
// issued (see Table 17-12)." Table 17-12: argument value 0, "Prints nothing".
//
// Timeline, 1 ns / 1 ns:
//   t=1  "t=1"
//   t=2  "t=2", then $finish(0): the simulator exits, printing nothing.
//   The statement after $finish in the same block never runs, and the
//   second block's t=5 never comes.
// Nothing else acts at t=1 or t=2, so no §11 ordering choice reaches the
// transcript.
//! inherited IEEE 1364-2005 17.4 17.4.1
`timescale 1 ns / 1 ns
module b_17_4_1_finish_exits;
  initial begin
    #1 $display("t=1");
    #1 $display("t=2");
    $finish(0);
    $display("after finish");
  end
  initial #5 $display("t=5");
endmodule
