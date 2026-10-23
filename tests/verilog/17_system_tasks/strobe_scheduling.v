// §9.4.1, first rule: "$strobe provides the ability to display simulation data
// when the simulator has converged on a solution for all nodes." In the
// digital context the inherited IEEE 1364-2005 §17.1 wording for the same task
// is that the arguments are sampled and printed at the END of the current time
// step, after every other event in that step has been processed — which in the
// IEEE §11.3 region ordering means AFTER the nonblocking assign update region. That
// is what makes $strobe different from $display, whose §9.4.1 description
// ("The $display task provides the same capabilities as $strobe") is about
// FORMATTING, not about when it runs; $display prints where it stands.
//
// A #0 resumes in the inactive region, BEFORE NBA delivery; it is not a way
// to observe a settled NBA. This fixture instead observes the monitor region
// through $strobe, as required by IEEE 17.1.2. See the scheduling audit for
// the source review and the separate NBA delivery fixtures.
//
// HAND DERIVATION, time step t=0:
//   active region, in source order
//     a = 4'b0001            -> a is 0001
//     a <= 4'b0010           -> queues an NBA update of a to 0010
//     $display("display %b") -> prints the CURRENT a: "display 0001"
//     $strobe ("strobe %b")  -> queues a strobe; samples NOTHING yet
//     a = 4'b0100            -> a is 0100
//     $display("after %b")   -> prints the CURRENT a: "after 0100"
//   NBA update region
//     a <- 0010              (the blocking 0100 written after the <= is
//                             overwritten; §11.3 applies the queued update
//                             unconditionally)
//   monitor region
//     the queued strobe samples a NOW = 0010 -> "strobe 0010"
//
//   so the transcript order for t=0 is
//     display 0001 / after 0100 / strobe 0010
//   and the strobe line is printed LAST even though it was called SECOND.
//   A printer that evaluates $strobe eagerly prints "strobe 0001" in second
//   place; a printer that merely defers the OUTPUT without deferring the
//   SAMPLING prints "strobe 0001" in third place. Both fail here, and the two
//   failures are distinguishable, which is why the value 0001/0100/0010 are
//   three different patterns.
//
// HAND DERIVATION, time step t=1:
//   a = 4'b1000            -> a is 1000
//   $strobe("repeat %b", a) -> queues strobe #1
//   $strobe("repeat %b", a) -> queues strobe #2
//   a = 4'b1001            -> a is 1001
//   end of step: both queued strobes sample a = 1001
//     repeat 1001
//     repeat 1001
//   This is the "two $strobe calls in one time step" case: neither is dropped
//   (a single-slot strobe register would print only one line), and both see
//   the final settled value. Identical labels avoid requiring callback order:
//   IEEE 11.3/11.4 and 17.1.2 do not establish the former call-order claim.
//   That withdrawn claim is recorded as STROBE-ORDER-001 in the scheduling
//   audit, not counted as conformance evidence elsewhere.
//
// t=2 runs only $finish(0), which per docs/digital-source-execution.md is
// silent, so it contributes no line.
//
//! lrm 9.4.1
//! inherited IEEE 1364-2005 17.1 ($strobe end-of-time-step sampling)
//! expect stdout strobe_scheduling.expected.txt
`timescale 1ns/1ns
module d09_strobe_scheduling;
  reg [3:0] a;
  initial begin
    a = 4'b0001;
    a <= 4'b0010;
    $display("display %b", a);
    $strobe("strobe %b", a);
    a = 4'b0100;
    $display("after %b", a);
    #1;
    a = 4'b1000;
    $strobe("repeat %b", a);
    $strobe("repeat %b", a);
    a = 4'b1001;
    #1 $finish(0);
  end
endmodule
