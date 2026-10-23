// Verilog-AMS LRM 2.4 §3.7 Real net declarations, verbatim:
//
//   "The wreal, or real net data type, represents a real-valued physical
//    connection between structural entities. A wreal net shall not store its
//    value. A wreal net can be used for real-valued nets which are driven by a
//    single driver, such as a continuous assignment. If no driver is connected
//    to a wreal net, its value shall be zero (0.0). Unlike other digital nets
//    which have an initial value of 'z', wreal nets shall have an initial value
//    of zero."
//
// Two sentences, two separate obligations, and this fixture pins both against
// the contrast case in the same file:
//
//   (a) NO DRIVER AT ALL  -> 0.0 forever, not 'z' and not 'x'.
//   (b) INITIAL VALUE     -> 0.0 at time 0 before any process has run,
//                            where an ordinary `wire` reads 'z'.
//
// Syntax 3-8 also gives the declaration-with-assignment alternative
//
//   net_declaration ::= ... | wreal [ discipline_identifier ] [ range ]
//                             list_of_net_decl_assignments ;
//
// and a net_decl_assignment IS a continuous assignment (IEEE Std 1364 Verilog
// 6.1.2), i.e. a driver — so `wreal seeded = 2.5;` is case (a)'s exact
// complement: it has a driver, so 0.0 is the WRONG answer for it at every time
// including time 0.
//
// THE SHARP EDGE. An implementation that reaches for the existing four-state
// net machinery gets undriven = 'z' and then converts 'z' to a real somehow;
// an implementation that reaches for the existing `real` VARIABLE machinery
// gets 0.0 by accident and passes line 1 while failing every other wreal
// fixture. Only line 2, the plain `wire`, distinguishes "wreal is zero because
// the standard says so" from "everything in this engine starts at zero".
//
//! lrm 3.7
//! lrm 3.7:1
//! lrm 3.7:2
//! lrm 3.7:3
//! lrm annex A.2.1.3
//! timescale 1ns/1ns
//
// HAND DERIVATION
//   floating : declared `wreal`, never assigned, never a target of any
//              continuous assignment. §3.7 sentence 3 -> 0.0. %g of 0.0 is "0".
//   plain    : declared `wire`, never assigned. IEEE Std 1364 Verilog: a net
//              with no driver is 'z'. %b of a 1-bit z is "z". This is the line
//              §3.7's "Unlike other digital nets" sentence is contrasting with.
//   seeded   : `wreal seeded = 2.5;` — one continuous-assignment driver whose
//              right-hand side is the constant 2.5, so the net reads 2.5 at
//              time 0 and at every later time. %g of 2.5 is "2.5".
//              RACE (specification/Vague_Decisions.md VD-033): the assignment's first
//              evaluation and this `initial` are both active events at time 0,
//              which IEEE 1364-2005 11.3 lets run in any order, so a
//              conforming tool may print 0 for an undelayed read. The `#0`
//              moves the read to the inactive region, after every active
//              continuous-assignment update. The two lines before it read
//              nets with no driver and have no race.
//   The second sampling at t=10 asserts the value is STABLE, which is the
//   "shall not store its value" sentence read the only way it is observable
//   from source: the net is a window onto its driver, so with no driver and no
//   driver change nothing can move it off 0.0.

`timescale 1ns/1ns
module m04_wreal_undriven_zero;
  wreal floating;
  wire  plain;
  wreal seeded = 2.5;

  initial begin
    $display("undriven_wreal_at_time_zero %g", floating);
    $display("undriven_wire_at_time_zero %b", plain);
    #0;
    $display("decl_assigned_wreal_at_time_zero %g", seeded);
    #10;
    $display("undriven_wreal_stays_zero %g", floating);
    $display("decl_assigned_wreal_stays %g", seeded);
    $finish(0);
  end
endmodule
