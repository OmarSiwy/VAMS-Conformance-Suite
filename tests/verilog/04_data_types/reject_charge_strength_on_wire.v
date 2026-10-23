// Verilog-AMS LRM 2.4 annex A.2.2.1:
//
//   net_type ::= supply0 | supply1 | tri | triand | trior | tri0 | tri1
//              | uwire | wire | wand | wor
//
// `trireg` is NOT in that list. Annex A.2.1.3's `net_declaration` spells the
// two families separately, and `charge_strength` appears ONLY in the `trireg`
// alternatives:
//
//   net_declaration ::= net_type [ discipline_identifier ] [ drive_strength ] ...
//                     | trireg [ discipline_identifier ] [ charge_strength ] ...
//
// A `wire` has no charge to store, so `(small)` on one is meaningless rather
// than merely unusual. The parenthesised form after a net type is a
// `drive_strength`, and annex A.2.2.2's `strength0`/`strength1` do not include
// `small`, `medium` or `large`.
//
// The failure this guards against is a strength implementation that parses "a
// parenthesised strength keyword" uniformly after any net type and silently
// gives a wire a capacitance it can never exhibit.
//
// The `//! reject` directive names a SUBSTRING. A bare form is satisfied by
// today's incidental `E0208 expected an identifier: found '('` — i.e. by `(`
// after a net type being unparseable at all — and would stay satisfied after
// the strength parser lands even if `wire (small)` were refused for an
// unrelated reason. The substring below is the wording the diagnostic must
// carry, and E0257 is the code allocated for the rule (until 2026-10 the
// refusal was the generic E0207 "unexpected token", so only the wording could
// pin it).
//
// ROUTE. This is a digital rule, so the file runs under the digital runner
// (`vera --run`). On the legacy analog compile route `assign` is itself
// E0205, which says nothing about the rule above.
//! reject E0257
//! reject charge strength is only legal on a trireg
//! lrm A.2.2.1
//! lrm A.2.1.3
//! lrm A.2.2.2
//! lrm A.2.1.3:1000
//! lrm A.2.2.2:1000
//! inherited IEEE 1364-2005 4.4 4.4.1

module d03_reject_charge_strength_on_wire;
  reg a;
  wire (small) w;

  assign w = a;

  initial begin
    $display("%b", w);
    $finish(0);
  end
endmodule
