// Verilog-AMS LRM 2.4 annex A.2.1.3, the trireg alternative of
// `net_declaration`:
//   "| trireg [ discipline_identifier ] [ charge_strength ] [ signed ]
//        [ delay3 ] list_of_net_identifiers ;"
// annex A.2.2.2:
//   "charge_strength ::= ( small ) | ( medium ) | ( large )"
// §1.1 makes the semantics IEEE Std 1364 Verilog's: a trireg whose drivers are
// all at z enters the CAPACITIVE state and holds its last driven value; the
// charge strength is the strength that stored value is presented at (small = 1,
// medium = 2, large = 4 in clause 7's order) and `medium` is the default.
// `delay3`'s third value is the charge decay time, and WITH NO `delay3` THERE
// IS NO DECAY: the value is held indefinitely.
//
// WHAT CAN FAIL HERE. The `ctl` column is a plain `wire` carrying the identical
// `assign` from the identical stimulus, so every line states the difference
// between a net that stores charge and one that does not. It fails, in kind:
//
//   * an implementation that parses `(large)`/`(small)` and then treats the
//     declaration as an ordinary net — the cheapest wrong way to make the new
//     syntax "work" — which prints z where the three triregs print 1/1/0;
//   * an implementation that lands fixture 08's decay and lets it fire on a
//     trireg with no `delay3`, or applies some default decay time: the `held`
//     line is 1000 ns after the release;
//   * an implementation whose stored value is the FIRST driven value rather
//     than the last (lines 5-6 re-drive 0 and release again).
//
// The charge STRENGTH itself is still not asserted, and cannot be from this
// file: a driven trireg takes its drivers' value and strength outright, so
// small-vs-large is observable only through `%v` (missing,
// specification/CLAUSE-AUDIT.md row 17.1-07) or through a switch primitive (D08).
// The three trireg columns therefore pin only that the strengths are LEGAL and
// change no stored value. See tests/fixtures/ieee1364/07_gate_switch_level/d03_SPEC.md at 8b1514d4, "Deliberately NOT covered".
//
//! lrm annex A.2.1.3
//! lrm annex A.2.2.2
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 4.4.1 4.6.3 4.6.3.2
//
// HAND DERIVATION — one stimulus `d` driving three triregs that differ only in
// their declared charge strength, and one plain wire.
//   t=0     `d` is an undriven reg, so it is x and every driver drives x.
//           A trireg with no charge yet shows that x          -> x x x
//           The wire is not sampled here: IEEE 1364-2005 4.2.1 starts a net
//           at z and 11.6.1 evaluates `assign ctl = d` "at time 0", so a
//           time-0 read races that evaluation (11.5) and may see z or x.
//           A trireg is x either way (4.2.1: it defaults to x).
//   t=1     d=1, driven                                       -> 1 1 1, wire 1
//   t=2     d=z since t=1: capacitive state, stored 1         -> 1 1 1, wire z
//   t=1002  1000 ns later, no decay time was declared         -> 1 1 1, wire z
//   t=1003  d=0, driven                                       -> 0 0 0, wire 0
//   t=1004  d=z again: the stored value is the NEW one        -> 0 0 0, wire z
//
// The three trireg columns are identical on every line; the fourth differs on
// three of the five that carry it.
//
// HISTORICAL TRANSCRIPT PROVENANCE: the initial capture used a build where
// `trireg (large)`/`trireg (small)` did not parse, with the two charge strengths
// deleted and nothing else changed. This is not a current limitation claim:
// the primitive audit records a matching run of this unmodified fixture.
//
//   $ vera --run /tmp/d03_09_strip.v
//   start x x x x
//   driven 1 1 1 1
//   stored 1 1 1 z
//   held 1 1 1 z
//   redriven 0 0 0 0
//   stored_zero 0 0 0 z
//
// The hand derivation above, not the historical capture alone, supplies the
// expected retention and wire contrast. Charge-strength competition is untested.

`timescale 1ns/1ns
module d03_trireg_capacitive_hold;
  reg d;
  trireg (large) big;
  trireg (small) tiny;
  trireg plain;
  wire   ctl;

  assign big = d, tiny = d, plain = d;
  assign ctl = d;

  initial begin
    $display("start %b %b %b", big, tiny, plain);
    d = 1'b1;
    #1 $display("driven %b %b %b %b", big, tiny, plain, ctl);
    d = 1'bz;
    #1 $display("stored %b %b %b %b", big, tiny, plain, ctl);
    #1000 $display("held %b %b %b %b", big, tiny, plain, ctl);
    d = 1'b0;
    #1 $display("redriven %b %b %b %b", big, tiny, plain, ctl);
    d = 1'bz;
    #1 $display("stored_zero %b %b %b %b", big, tiny, plain, ctl);
    $finish(0);
  end
endmodule
