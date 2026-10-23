// IEEE 1364-2005 17.1.3: "the entire argument list is displayed at the end
// of the time step". Multiple argument changes then produce only one display.
// At t0 install a list while a=0, then queue a=1 in the NBA region. The sole
// monitor line for t0 must report settled a=1, not an eager a=0 installation
// print followed by a second line. At t1 a marker separates the next step;
// at t2 a=0 gives one further line. No time-function or enable-state behavior
// participates in this oracle.
//! lrm 8.5.1
//! lrm 9.4
//! inherited IEEE 1364-2005 17.1.3
`timescale 1ns/1ns
module audit_monitor_install_settled;
  reg a;
  initial begin
    a = 1'b0;
    $monitor("a=%b", a);
    a <= 1'b1;
    #1 $display("next step");
    #1 a = 1'b0;
    #1 $finish(0);
  end
endmodule
