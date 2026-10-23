// IEEE 1364-2005 §9.7.2: "An implicit event shall be detected on any change
// in the value of the expression." §4.1.7 compares reals with IEEE 754
// `==`/`!=`, under which -0.0 == 0.0. VerA's reading (specification/Vague_Decisions.md
// VD-032): a real changes when `old != new`, and "no change" governs only
// the event. The variable still holds what was assigned (§9.2.1: the
// blocking assignment stores its value), so after r = -0.0, 1.0/r is
// -infinity, not +infinity.
//
// HAND DERIVATION. `always @(r)` counts events; each step is one tick apart,
// so the waiter is waiting again before the next write; the displays sit
// half a tick after the writes (1ns/100ps).
//   t=1  r = 0.5   0.0 -> 0.5     change      events 1
//   t=2  r = 0.0   0.5 -> 0.0     change      events 2
//   t=3  r = -0.0  0.0 != -0.0 is false: no event, events 2
//        1.0 / r = 1.0 / -0.0 = -inf (IEEE 754 division by a signed zero)
//   t=4  r = 0.0   -0.0 != 0.0 is false: no event, events 2
//        1.0 / r = +inf
// %f prints an infinity as C's printf does, "-inf" and "inf".
//
// No rejection fixture: a real in an event expression is legal (only an edge
// of a real is refused, §4.8.1), so §9.7.2 has no invalid form here.
//! inherited IEEE 1364-2005 9.7.2
`timescale 1ns/100ps
module b_9_7_2_real_negative_zero;
  real r;
  integer events;
  initial events = 0;
  always @(r) events = events + 1;
  initial begin
    #1 r = 0.5;
    #1 r = 0.0;
    #1 r = -0.0;
    #0.5 $display("events=%0d inv=%f", events, 1.0 / r);
    #0.5 r = 0.0;
    #0.5 $display("events=%0d inv=%f", events, 1.0 / r);
    #1 $finish(0);
  end
endmodule
