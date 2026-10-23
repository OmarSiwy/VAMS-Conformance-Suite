// Verilog-AMS LRM 2.4 §6.5.3 Real valued ports, last sentence, verbatim:
//
//   "There can be a maximum of one driver of a real-valued net."
//
// and §3.7, which says the same thing from the other side:
//
//   "A wreal net can be used for real-valued nets which are driven by a single
//    driver, such as a continuous assignment."
//
// This is a REAL restriction and not a stylistic one, because there is no
// resolution function for it to fall back on. IEEE Std 1364 Verilog resolves
// multiple drivers of a `wire` by the four-state conflict table, and §3.7
// extends that resolution "for wreal" only as far as the wire/tri/wreal MERGE
// (which net type the single resulting net has) — it defines no rule for
// combining two disagreeing REAL values, because there is none: 1.5 and 2.5
// have no meaningful resolved value, no 'x' to collapse to, and no strength
// ordering to break the tie.
//
// So a second driver is an error at elaboration, not a value at run time. The
// failure mode this guards is the natural one for a compiler that already has a
// driver-grouping path for `wire`: it groups the two drivers, finds no wired
// function for the net type, and silently takes the last one.
//
// EXACTLY ONE RULE IS BROKEN HERE. Everything else in the file is legal: the
// declaration, the net type, both right-hand sides and both source variables.
//
// CORRECTED AFTER REVIEW — THE REJECT DIRECTIVE NOW NAMES ITS DIAGNOSTIC. This
// file carried a bare `//! reject`, which `tests/suite.zig:223` satisfies
// with ANY diagnostic: today's `E0205 unsupported module item: found wreal` — a
// refusal of the net type itself, not of the second driver — passes it, and so
// would any unrelated parse error after `wreal` lands. The substring below is
// matched against each diagnostic's message, point and catalogue title
// (`failureContains`, tests/suite.zig:210-245), so it demands that whatever
// refuses this file refuses it for §6.5.3's reason and says so in the LRM's own
// words.
//
// CODE ASSIGNED. The rule is now E0918 ("a wreal net has more than one
// driver", LRM 6.5.3), so the directive pins the code as the paragraph above
// asked. It runs under the digital runner (`vera --run`), not the legacy
// analog compile route, which could only ever answer with the Annex C.4
// refusal of `wreal` itself. `wreal` is still E1100 there too; E0918 is
// reported beside it, at the second `assign`.
//
//! reject E0918
//! lrm 6.5.3
//! lrm 3.7

`timescale 1ns/1ns
module m04_reject_wreal_two_drivers;
  real a;
  real b;
  wreal w;

  assign w = a;
  assign w = b;   // §6.5.3: a real-valued net has at most ONE driver

  initial begin
    a = 1.5; b = 2.5;
    #1 $display("%g", w);
    $finish(0);
  end
endmodule
