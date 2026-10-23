//! inherited IEEE 1364-2005 9.2.2 11.4
// An event-controlled nonblocking update lands in the NBA region, after the
// triggering thread's next statements (nb_ec_multi_ev).
module triage_nba_event_control_region;
  integer x = 0;
  event e1, e2;

  initial begin
    x <= @(e1 or e2) x + 1;
    #1;
    if (x !== 0) $display("FAILED active-before, %0d", x);
    -> e1;
    if (x !== 0) $display("FAILED same-step, %0d", x);
    #1;
    if (x !== 1) $display("FAILED later, %0d", x);
    else $display("PASSED");
  end
endmodule
