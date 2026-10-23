// IEEE 1364-2005 17.1.3 excludes "$time, $stime, or $realtime system functions"
// from changes that trigger a monitor display. This case isolates $time;
// it does not claim evidence for the other two functions or nested uses.
// At t0 the initial monitor reports a=0/time=0. At t1 only an UNMONITORED
// variable changes, so the advancing time must not print a line. At t2 a
// changes to 1: one line must include the CURRENT time 2. At t3 the unrelated
// variable changes again and at t4 simulation finishes, neither adding output.
// Comparing rendered lines instead of monitored non-time arguments incorrectly
// makes the changing time field trigger extra lines.
//! lrm 9.4
//! inherited IEEE 1364-2005 17.1.3
`timescale 1ns/1ns
module audit_monitor_time_exception;
  reg a, unrelated;
  initial begin
    a = 1'b0;
    unrelated = 1'b0;
    $monitor("a=%b t=%0d", a, $time);
    #1 unrelated = 1'b1;
    #1 a = 1'b1;
    #1 unrelated = 1'b0;
    #1 $finish(0);
  end
endmodule
