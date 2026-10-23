// Verilog-AMS LRM 2.4 §3.7, the connectivity paragraph, verbatim:
//
//   "Compatible interconnect are nets of type wire, tri, and wreal where the
//    IEEE Std 1364 Verilog net resolution is extended for wreal. When the two
//    nets connected by a port are of net type wreal and wire/tri, the resulting
//    single net will be assigned as wreal. Connection to other net types will
//    result in an error."
//
// The compatible list is CLOSED and has three members: wire, tri, wreal.
// `wand` is not one of them, and the last sentence makes that an error rather
// than a warning or a silent promotion.
//
// It has to be an error, and the reason is in the sentence before it: the merge
// rule is "the resulting single net will be assigned as wreal". A `wand` is not
// merely a differently spelled `wire` — its identity is its RESOLUTION
// FUNCTION, the wired-AND of all its drivers. Promoting it to wreal would
// silently delete that function; refusing to promote it would leave a net that
// is a wand on one side of the port and a wreal on the other, which is not one
// net. There is no third option, which is why the clause closes the list
// instead of extending the merge.
//
// 05_wreal_wire_port_resolves_wreal.v is this file's positive twin: it pins the
// wire and tri cases being ACCEPTED and promoted, so the two together state the
// membership of the list from both sides rather than just refusing things.
//
// THE FAILURE THIS GUARDS is a merge implemented as "if either side is wreal,
// the net is wreal", which accepts this file and throws the wired-AND away.
//
// CORRECTED AFTER REVIEW — THE REJECT DIRECTIVE NOW NAMES ITS DIAGNOSTIC. This
// file carried a bare `//! reject`, which `tests/suite.zig:223` satisfies
// with ANY diagnostic, including today's `E0205 unsupported module item: found
// wreal` — a refusal of the net type in the CHILD module, which says nothing
// about the `wand` in the parent. The substring below is matched against each
// diagnostic's message, point and catalogue title (`failureContains`,
// tests/suite.zig:210-245) and demands that the refusal be about the net type
// on the other side of the port, i.e. §3.7's closed compatible-interconnect
// list.
//
// CODE ASSIGNED. The rule is now E0919 ("a wreal net is connected to an
// incompatible net type", LRM 3.7), so the directive pins the code as the
// paragraph above asked. It runs under the digital runner (`vera --run`), not
// the legacy analog compile route, which could only ever answer with the
// Annex C.4 refusal of `wreal` itself. `wreal` is still E1100 there too; E0919
// is reported beside it, at the port connection.
//
//! reject E0919
//! lrm 3.7

`timescale 1ns/1ns

module m04_wand_wreal_child(o);
  output o;
  wreal o;
  assign o = 2.5;
endmodule

module m04_reject_wreal_connected_to_wand;
  wand n;   // NOT in §3.7's compatible-interconnect list

  m04_wand_wreal_child u(.o(n));

  initial begin
    #1 $display("%g", n);
    $finish(0);
  end
endmodule
