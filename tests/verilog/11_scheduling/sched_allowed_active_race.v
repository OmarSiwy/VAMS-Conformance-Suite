// IEEE1364-2005 §11.5 permits either old1 or new0 immediately after q=0;
// never require a specific active-event order. Print membership in the
// permitted set, then independently observe settled0 in the inactive region.
//! inherited IEEE 1364-2005 11.4.2 11.5
`timescale 1ns/1ns
module audit_sched_allowed_active_race;
  reg q;
  wire p;
  assign p = q;
  initial begin
    q = 1;
    #1 q = 0;
    $display("permitted=%b", (p === 1'b0) || (p === 1'b1));
    #0 $display("settled=%b", p);
    #1 $finish(0);
  end
endmodule
