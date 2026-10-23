//! inherited IEEE 1364-2005 17.1.3 17.4.1
// A $monitor change in the time step where $finish executes is not printed by
// VerA: it stops before the end-of-step monitor print (monitor4/pr243).
module triage_monitor_change_at_finish_not_printed;
  integer a;

  initial begin
    a = 0;
    $monitor("m %0d", a);
    #1 a = 1;
    $finish(0);
  end
endmodule
