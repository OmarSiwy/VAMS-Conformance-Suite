// IEEE 1364-2005 17.1.3: "each time a variable or an expression in the
// argument list changes value" causes an end-of-time-step display.
// This is the DIGITAL rule, not AMS 9.4.1's analog accepted-step comparison.
// At t2, a changes from 0 to 1 in active processing, then back to 0 after
// #0 (inactive, still before the monitor region). One line must report the
// settled value 0. Comparing only the rendered line with the preceding time
// step would incorrectly suppress that line. Markers at t1 and t3 distinguish
// it from the setup display, without depending on concurrent print ordering.
//! lrm 8.5.1
//! lrm 9.4
//! inherited IEEE 1364-2005 17.1.3
`timescale 1ns/1ns
module audit_monitor_return_to_previous;
  reg a;
  initial begin
    a = 1'b0;
    $monitor("a=%b", a);
    #1 $display("before change");
    #1 a = 1'b1;
    #0 a = 1'b0;
    #1 $display("after change");
    $finish(0);
  end
endmodule
