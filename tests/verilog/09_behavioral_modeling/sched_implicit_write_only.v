// IEEE1364-2005 9.7.5 excludes an identifier used only as an assignment LHS.
// After copying source1, an independent procedural writer pokes destination0.
// That poke must not awaken @*: destination stays0 until source changes.
// Delayed stimulus avoids time-zero waiter-registration races.
//! lrm 8.5
//! inherited IEEE 1364-2005 9.7.5
`timescale 1ns/1ns
module audit_sched_implicit_write_only;
  reg source_bit, destination;
  always @* destination = source_bit;
  initial begin
    #1 source_bit = 1;
    #1 $display("copied=%b", destination);
    destination = 0;
    #1 $display("poked=%b", destination);
    source_bit = 0;
    #1 $display("changed=%b", destination);
    $finish(0);
  end
endmodule
