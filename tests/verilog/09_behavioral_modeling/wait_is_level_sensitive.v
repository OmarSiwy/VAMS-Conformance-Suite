// A.6.5 `wait_statement ::= wait ( expression ) statement_or_null`, an
// alternative of the digital A.6.4 `statement` (and of nothing in
// `analog_statement`).
//
// `wait` is the LEVEL-sensitive control; `@` is the edge-sensitive one. The
// whole difference between them is what happens when the condition is ALREADY
// true at the moment the statement is reached: `wait` falls straight through
// without consuming any simulation time, `@` would sit there until the next
// transition. VerA has `@`; `wait` is unparsed today, and the cheapest way to
// implement it wrongly is as `@(g)` plus a test, which this fixture catches.
//
// HAND DERIVATION — `g` starts 1, is cleared, and comes back at t=4.
//   t=0   main:   g<-1
//                 `wait (g) r = 4'b0001;` — g is 1 already, so the guarded
//                 statement runs AT t=0 with no suspension: r<-0001
//                 display -> "nowait 0001"
//                 g<-0
//                 `wait (g) r = 4'b0010;` — g is 0, so the process suspends
//         clock:  delays to t=2
//   t=2   clock:  stamp<-0001, then delays to t=4
//   t=4   clock:  g<-1, which makes the waited expression true
//         main resumes: r<-0010, and stamp is 0001 because t=4 > t=2
//         display -> "waited 0010 0001"
//
// `stamp` is the proof of WHEN: it is x before t=2 and 0001 after, so a `wait`
// that fell through immediately would print "waited 0010 xxxx". A `wait`
// implemented as an edge wait hangs on the FIRST one and prints nothing.
//
// `stamp` is deliberately never written at t=0, so its x is meaningful.
//
//! lrm A.6.4
//! lrm A.6.5
//! lrm 1.2
//! lrm A.6.5:1000
//! timescale 1ns/1ps
//! inherited IEEE 1364-2005 9.7.6
`timescale 1ns/1ps
module d04_wait_is_level_sensitive;
  reg g;
  reg [3:0] r, stamp;

  initial begin
    g = 1'b1;
    wait (g) r = 4'b0001;
    $display("nowait %b", r);
    g = 1'b0;
    wait (g) r = 4'b0010;
    $display("waited %b %b", r, stamp);
    $finish(0);
  end

  initial begin
    #2 stamp = 4'b0001;
    #2 g = 1'b1;
  end
endmodule
