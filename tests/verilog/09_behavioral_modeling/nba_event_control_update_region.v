//! inherited IEEE 1364-2005 9.2.2 11.4
// An event-controlled nonblocking update lands in the NBA region: the thread
// that triggers the event continues first and still reads the old value
// (nb_ec_multi_ev under the standard, not Icarus's immediate update).
module triage_nba_event_control_update_region;
  integer x;
  event e;
  reg failed;

  initial begin
    failed = 0;
    x = 0;
    x <= @(e) x + 1;
    #1;
    if (x !== 0) failed = 1;
    -> e;
    if (x !== 0) failed = 1;
    #1;
    if (x !== 1) failed = 1;
    if (failed) $display("FAILED"); else $display("PASSED");
  end
endmodule
