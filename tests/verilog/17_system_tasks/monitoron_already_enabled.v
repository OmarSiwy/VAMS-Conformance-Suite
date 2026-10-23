// IEEE 1364-2005 17.1.3: "$monitoron shall produce a display immediately
// after it is invoked, regardless of whether a value change has taken place".
// There is no prerequisite that monitoring was previously disabled.
// The standing list contains constant a=0. Initial installation reports it;
// calls at t2 and t4 each require another display despite the already-enabled
// flag and unchanged value. Markers at t1/t3/t5 delimit the three observations
// without imposing order among events in a single time slot. No time function
// is monitored, so this case is independent of the time-trigger exception.
//! lrm 9.1
//! lrm 9.1:1000
//! inherited IEEE 1364-2005 17.1.3
`timescale 1ns/1ns
module audit_monitoron_already_enabled;
  reg a;
  initial begin
    a = 1'b0;
    $monitor("a=%b", a);
    #1 $display("before first");
    #1 $monitoron;
    #1 $display("between");
    #1 $monitoron;
    #1 $display("after second");
    $finish(0);
  end
endmodule
