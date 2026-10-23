// IEEE 1364-2005 §§4.8, 9.2.2, 9.7.2: a queued assignment to a real
// changes its numeric value on arrival. -0.0 equals the initial +0.0, so
// the first immediate NBA produces no event. The changes to 1.0 at t=3
// and back to zero by the delayed NBA at t=4 produce two events. A second
// delayed -0.0 at t=7 adds none. This scalar neighbor isolates the queue
// semantics from the array storage tested by native_real_events.v.
//! inherited IEEE 1364-2005 4.8 9.2.2 9.7.2
// native-required
`timescale 1ns/1ns
module native_real_scalar_nba;
  real r;
  integer changes;
  always @(r) changes = changes + 1;
  initial begin
    changes = 0;
    #1 r <= -0.0;
    #1 $display("zero %0d", changes);
    r <= #2 -0.0;
    #1 r = 1.0;
    #2 r <= #2 -0.0;
    #3 $display("final %0d zero=%b", changes, r == 0.0);
    $finish(0);
  end
endmodule
