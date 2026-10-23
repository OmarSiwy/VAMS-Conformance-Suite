// Verilog-AMS LRM 2.4 annex A.6.1:
//   "continuous_assign ::= assign [ drive_strength ] [ delay3 ]
//    list_of_net_assignments ;
//    list_of_net_assignments ::= net_assignment { , net_assignment }
//    net_assignment ::= net_lvalue = expression"
//
// `net_assignment` is `net_lvalue = expression` with NOTHING between the `=`
// and the expression. Compare annex A.6.2, which deliberately does carry one:
//   "blocking_assignment ::= variable_lvalue = [ delay_or_event_control ]
//    expression"
// An intra-assignment timing control is a property of a PROCEDURAL assignment
// executed by a suspendable process (§8.5.3.3 "causes the executing process to
// be suspended"). A continuous assignment has no executing process to suspend
// — §8.5.3.1 gives it a permanently sensitive process — so the only delay it
// can carry is the `delay3` that sits before the lvalue list.
//
// The rule broken is annex A.6.1: `net_assignment` has no
// `delay_or_event_control`. Writing the delay on the right of the `=` is the
// natural mistake when porting a procedural assignment, and it must not be
// quietly re-read as `assign #5 y = a;` — the two would only coincide for a
// single-value delay, and not at all once a rise/fall pair is written.
//
// WHICH diagnostic, and why this one (corrected after review — the directive
// used to be a bare `//! reject`, which is satisfied by ANY diagnostic).
//
// After the `=`, `net_assignment` admits an `expression` and nothing else, and
// `#` cannot begin one. The diagnostic is therefore E0209, title "expected an
// expression" (`lib/diag_code.zig:1196`), pointed at the `#`.
//
// This is the one place in the row where today's error is already the RIGHT
// error. `#` after `=` is unparseable now and stays unparseable after `delay3`
// lands, because `delay3` sits before the lvalue list and never after the `=`.
// Pinning E0209 therefore does not merely record current behaviour: it forbids
// the tempting future "fix" of re-reading `assign y = #5 a;` as
// `assign #5 y = a;`, which would make the file compile and this directive fail.
//
// ROUTE. This is a digital rule, so the file runs under the digital runner
// (`vera --run`). On the legacy analog compile route `assign` is itself
// E0205, which says nothing about the rule above.
//! reject E0209
//! lrm A.6.1
//! lrm A.6.2
//! lrm 8.5.3.1
//! lrm 8.5.3.3
//! lrm A.6.1:1000
//! inherited IEEE 1364-2005 A.6.1

`timescale 1ns/1ns
module reject_intra_assign_on_net;
  reg a;
  wire y;

  assign y = #5 a;

  initial begin
    a = 1'b0;
    #10 $display("y=%b", y);
    $finish(0);
  end
endmodule
