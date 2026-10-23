// IEEE 1364-2005 9.7.3: "An event-controlled statement (for example,
// @trig rega = regb;) shall cause simulation of its containing procedure to
// wait until some other procedure executes the appropriate event-triggering
// statement (for example, -> trig)." And: "An event shall not hold any data."
//
// So `always @(e) n = n + 1;` runs its body once per `-> e`, however quiet
// the body is. A named event has no value to change, so an implementation
// that treats `@(e)` as "re-run when e's value changes" (the reading that is
// right for `@(a)` over a variable) never runs this body at all. The body
// prints nothing on purpose: a body that prints is a different process shape.
//
// HAND DERIVATION:
//   t=0  n <- 0; the always block waits on e
//   t=1  -> e: n <- 1
//   t=2  -> e: n <- 2
//   t=3  prints "n=2"
//
//! inherited IEEE 1364-2005 9.7.3
`timescale 1ns/1ns
module audit_named_event_silent_always;
  integer n;
  event e;
  always @(e) n = n + 1;
  initial begin #1 -> e; #1 -> e; end
  initial begin n = 0; #3 $display("n=%0d", n); $finish(0); end
endmodule
