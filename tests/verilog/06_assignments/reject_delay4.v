// Verilog-AMS LRM 2.4 annex A.2.2.3:
//   "delay3 ::= # delay_value
//             | # ( mintypmax_expression [ , mintypmax_expression
//                 [ , mintypmax_expression ] ] )"
// The nesting of the optional brackets caps the parenthesised form at THREE
// mintypmax_expressions — rise, fall and turn-off. There is no fourth slot in
// the grammar, and annex A.6.1's
//   "continuous_assign ::= assign [ drive_strength ] [ delay3 ]
//    list_of_net_assignments ;"
// admits only `delay3` here, so a fourth value has no production to derive it.
//
// The rule broken is annex A.2.2.3: a `delay3` with four expressions is not
// derivable. Accepting it would silently pick three of the four and drop the
// remainder, turning a typo into a plausible-looking waveform.
//
// WHICH diagnostic, and why this one (corrected after review — the directive
// used to be a bare `//! reject`, which is satisfied by ANY diagnostic and so
// would keep passing once `delay3` lands even if the parser refused the line
// for an unrelated reason).
//
// Read the production as written. The innermost bracket pair closes after the
// third `mintypmax_expression`; from that point the only terminal A.2.2.3
// admits is the closing `)`. A parser that has consumed `#( 1 , 2 , 3` and
// then finds `,` is missing a `)`, and that is what it must say. VerA already
// has exactly that diagnostic — E0210, title "expected ')'", emitted at
// `lib/frontend/parser.zig:1911` — so no new code has to be invented to state
// the rule, and pinning it discriminates against both ways of getting this
// wrong: silently taking three of the four (no diagnostic at all), and the
// incidental E0209 "expected an expression: found `#`" that today's parser
// emits only because it has no `delay3` production whatsoever.
//
// NOTE for whoever implements `delay3`: an implementation that instead parses
// an unbounded comma list and then emits a dedicated "at most three delay
// values" diagnostic is equally conforming. If that is the route taken, change
// the directive below to that code — do not weaken it back to a bare `reject`.
// What must never happen is acceptance, or a complaint about the `#`.
//
// ROUTE. This is a digital rule, so the file runs under the digital runner
// (`vera --run`). On the legacy analog compile route `assign` is itself
// E0205, which says nothing about the rule above.
//! reject E0210
//! lrm A.2.2.3
//! lrm A.6.1
//! lrm A.2.2.3:1000
//! inherited IEEE 1364-2005 6.1.3 A.2.2.3

`timescale 1ns/1ns
module reject_delay4;
  reg a;
  wire y;

  assign #(1, 2, 3, 4) y = a;

  initial begin
    a = 1'b0;
    #10 $display("y=%b", y);
    $finish(0);
  end
endmodule
