//! inherited IEEE 1364-2005 9.9.2
// An always with no timing control is a zero-delay loop, a run-time deadlock,
// not a compile error: VerA compiles it, and the loop's first iteration ends
// the run here, so the fixture stays finite (always3.1.1A).
module triage_always_without_timing_control;
  reg x;

  always begin
    x = ~x;
    $display("PASSED");
    $finish(0);
  end
endmodule
