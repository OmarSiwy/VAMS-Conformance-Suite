// IEEE1364-2005 9.7.6: already-true condition continues immediately;
// false condition blocks until true. Constant1 never needs a wake list;
// constant0 never becomes true. A separate process ends the simulation.
//! lrm 8.5
//! inherited IEEE 1364-2005 9.7.6
`timescale 1ns/1ns
module audit_sched_wait_constant;
  initial begin
    wait (1) $display("ready");
    wait (0) $display("unreachable");
  end
  initial begin
    #1 $display("end");
    $finish(0);
  end
endmodule
