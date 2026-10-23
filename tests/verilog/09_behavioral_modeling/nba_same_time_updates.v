// IEEE 1364-2005 9.2.2 and 11.4.1; VAMS-2023 8.5.3.4.
// Ordered NBAs must both execute, even when the last restores the old value.
// At t2, q=0 receives q<=1 then q<=0. Final q=0 alone would also accept an
// implementation that drops the first update. A posedge waiter, armed at t1,
// records that the intermediate 0->1 update happened. It does not read q:
// that read could see either value depending on active-event interleaving.
// At t3, q=0 and seen=1 are therefore deterministic observations.
//
// A separate variable checks ordered queueing from different processes:
// at t1 queue r=1 for t5; at t2 queue r=0 for t5. The scheduling order is
// established by distinct execution times, not by source order of initials.
// At t6, r=0 and crossed=1. Waiters are armed before delivery, and flags are
// initialized before arming, avoiding time-zero registration races.
//! lrm 8.5.3.4
//! lrm 8.5.3.4:1000
//! inherited IEEE 1364-2005 9.2.2 11.4.1
`timescale 1ns/1ns
module audit_nba_same_time_updates;
  reg q, r, seen, crossed;
  initial begin
    q = 1'b0;
    r = 1'b0;
    seen = 1'b0;
    crossed = 1'b0;
    #2;
    q <= 1'b1;
    q <= 1'b0;
    #1 $display("same q=%b seen=%b", q, seen);
    #3 $display("cross r=%b seen=%b", r, crossed);
    $finish(0);
  end
  initial begin #1; @(posedge q) seen = 1'b1; end
  initial begin #1; @(posedge r) crossed = 1'b1; end
  initial begin #1 r <= #4 1'b1; end
  initial begin #2 r <= #3 1'b0; end
endmodule
