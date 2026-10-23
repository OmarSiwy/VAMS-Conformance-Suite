// Verilog-AMS LRM 2.4 §3.7 makes a wreal a NET, and §1.1 — "Verilog-AMS HDL
// consists of the complete IEEE Std 1364 Verilog specification" — supplies the
// event semantics of a net: an event control `@(net)` is sensitive to a CHANGE
// in the net's value, and an update that leaves the value the same is not a
// change and produces no event.
//
// For a four-state net that rule is settled and already implemented here. For a
// wreal it is not, and the difference is not cosmetic: "the same value" is now
// an IEEE-754 comparison rather than a four-state bit compare, so the
// implementation has to decide what it compares. This fixture pins that the
// comparison is on the REAL VALUE:
//
//   - assigning the same double twice produces ONE event, not two;
//   - assigning a different double that would compare equal after any
//     truncation to integer (1.5 -> 1.25) produces an event, because they are
//     different reals;
//   - -0.0 and +0.0 compare EQUAL under IEEE-754 `==`, so moving from 0.0 to
//     -0.0 is not a change and produces no event — even though the two have
//     different bit patterns. This is the line that separates "compare the
//     value" (correct) from "compare the 64 bits" (wrong, and the natural
//     implementation if wreal is bolted onto the four-state vector path).
//
// It also pins that the event DELIVERS the new value: `latched` is sampled
// inside the triggered block, so a tool that fires the event before updating
// the net reads the previous number.
//
//! lrm 3.7
//! lrm 1.1
//! timescale 1ns/1ns
//
// HAND DERIVATION. `src` is a real variable; IEEE Std 1364 Verilog initializes
// a real variable to 0.0, and `assign w = src;` makes `w` read 0.0 at time 0.
// `count` and `latched` start at 0 / 0.0 by the same rule.
//
//   t=0  src = 0.0     w: 0.0 -> 0.0   no change   count 0   latched 0.0
//   t=1  src = 1.5     w: 0.0 -> 1.5   change      count 1   latched 1.5
//   t=2  src = 1.5     w: 1.5 -> 1.5   no change   count 1   latched 1.5
//   t=3  src = 1.25    w: 1.5 -> 1.25  change      count 2   latched 1.25
//   t=4  src = 0.0     w: 1.25 -> 0.0  change      count 3   latched 0.0
//   t=5  src = -0.0    w: 0.0 -> -0.0  (-0.0 == 0.0 is TRUE in IEEE-754)
//                                      no change   count 3   latched 0.0
//
// Each sample is taken one tick AFTER the assignment that could move it, so no
// intra-timestep ordering between the `initial` and the `always` is asserted.
//
// THE WIDTH OF THE `count=` COLUMN. `count` is an `integer` and is printed with
// %b, the only integer conversion `src/sim/digital.zig` implements. §9.4.3
// Table 9-22 gives %b no width modifier, and IEEE Std 1364 — reached through
// §1.1 — makes the printed field width of %b the SIZE OF THE EXPRESSION, not
// the number of significant digits. §3.2 gives an `integer` the range
// -2**31 .. 2**31-1, so `count` is 32 bits wide and each decimal count above
// prints as exactly 32 binary digits, zero-padded on the left:
//
//   decimal 0 -> 00000000000000000000000000000000
//   decimal 1 -> 00000000000000000000000000000001
//   decimal 2 -> 00000000000000000000000000000010
//   decimal 3 -> 00000000000000000000000000000011
//
// so the column reads 0, 1, 1, 2, 3, 3 in that 32-digit spelling.
//
// CORRECTED AFTER REVIEW. This file previously expected the minimum-width
// strings "0", "1", "1", "10", "11", "11". Those are what a tool whose %b is
// minimum-width prints; VerA's is width-exact, and its own passing regression
// in `src/sim/digital.zig` prints `integer 11111111111111111111111111111111`
// for a 32-bit integer. The old transcript failed a conforming implementation,
// and the cheapest way to make it pass was to make %b non-conformant.
//
// `latched` at t=6 is 0.0 and %g prints "0" — NOT "-0": the last event fired at
// t=4 and latched +0.0, and no event fired for the -0.0 assignment, which is
// exactly what line 6 is claiming.

`timescale 1ns/1ns
module m04_wreal_event_on_change;
  real src;
  wreal w;
  integer count;
  real latched;

  assign w = src;

  always @(w) begin
    count = count + 1;
    latched = w;
  end

  initial begin
    count = 0;
    latched = 0.0;
    src = 0.0;
    #1 $display("same_value_at_time_zero_is_no_event count=%b latched=%g", count, latched);
    src = 1.5;
    #1 $display("first_change_fires_once count=%b latched=%g", count, latched);
    src = 1.5;
    #1 $display("rewriting_the_same_real_is_no_event count=%b latched=%g", count, latched);
    src = 1.25;
    #1 $display("different_real_same_integer_part_fires count=%b latched=%g", count, latched);
    src = 0.0;
    #1 $display("return_to_zero_fires count=%b latched=%g", count, latched);
    src = -0.0;
    #1 $display("negative_zero_equals_zero_so_no_event count=%b latched=%g", count, latched);
    $finish(0);
  end
endmodule
