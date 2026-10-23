// Verilog-AMS LRM 2.4 annex A.2.2.2, in full:
//
//   drive_strength ::= ( strength0 , strength1 )
//                    | ( strength1 , strength0 )
//                    | ( strength0 , highz1 )
//                    | ( strength1 , highz0 )
//                    | ( highz0 , strength1 )
//                    | ( highz1 , strength0 )
//   strength0 ::= supply0 | strong0 | pull0 | weak0
//   strength1 ::= supply1 | strong1 | pull1 | weak1
//
// EVERY alternative pairs one 0-side specification with one 1-side
// specification. `(strong0, pull0)` names the 0 side twice and the 1 side not
// at all, so it is not derivable from the grammar — and it is not merely a
// spelling slip: a driver has one strength PER VALUE, and a form that gives two
// strengths to the same value has no meaning under IEEE Std 1364 Verilog clause
// 7's model.
//
// This is the rule an implementation is most likely to lose by lexing a pair of
// strength keywords and taking the maximum, which would accept this line.
//
// The `//! reject` directive names a SUBSTRING, not a bare "something failed".
// A bare form is satisfied by today's incidental `E0209 expected an
// expression: found strong0` — i.e. by the strength tokens not existing at all
// — and would stay satisfied after the strength parser lands even if this line
// were refused for an unrelated reason. The substring below is the wording the
// diagnostic must carry; it follows the `expectRejected` convention for
// digital source (`src/sim/digital.zig:1392-1429`, e.g. "uwire net accepts a
// single driver"). No E-code is named: none is allocated for this rule, and
// inventing one would be worse than naming the reason.
//
// ROUTE. This is a digital rule, so the file runs under the digital runner
// (`vera --run`). On the legacy analog compile route `assign` is itself
// E0205, which says nothing about the rule above.
//! reject drive strength pairs one 0-side with one 1-side
//! lrm A.2.2.2
//! lrm A.6.1
//! lrm A.2.2.2:1000
//! inherited IEEE 1364-2005 6.1.4 A.2.2.2

module d03_reject_same_polarity_drive_strength;
  reg a;
  wire w;

  assign (strong0, pull0) w = a;

  initial begin
    $display("%b", w);
    $finish(0);
  end
endmodule
