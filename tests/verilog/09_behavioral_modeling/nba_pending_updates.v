// IEEE 1364-2005 9.2.2, examples 6 and 7; VAMS-2023 8.5.3.4.
// Queuing another NBA does not cancel an earlier assignment to the same reg.
// Independently derived timeline: at t0 queue q=1 for t2 and q=0 for t4;
// at t1 queue q=1 for t6. Observe strictly between update times, avoiding
// active/NBA races: t3 -> 1, t5 -> 0, t7 -> 1. The initial t0 observation
// must remain 0 because queuing an NBA neither writes now nor suspends.
// A last-pending-write-only implementation misses the t3 value. An immediate
// or process-blocking implementation changes the transcript/timing sequence.
// This tests ordinary digital NBAs, not the disputed AMS glitch example's
// driver look-ahead or transition filtering.
//! lrm 8.5.3.4
//! lrm 8.5.3.4:1000
//! inherited IEEE 1364-2005 9.2.2
`timescale 1ns/1ns
module audit_nba_pending_updates;
  reg q;
  initial begin
    q = 1'b0;
    q <= #2 1'b1;
    q <= #4 1'b0;
    $display("queued q=%b", q);
    #1 q <= #5 1'b1;
    #2 $display("t3 q=%b", q);
    #2 $display("t5 q=%b", q);
    #2 $display("t7 q=%b", q);
    $finish(0);
  end
endmodule
