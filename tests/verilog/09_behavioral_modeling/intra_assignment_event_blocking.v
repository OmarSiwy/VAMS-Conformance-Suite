// A.6.2 `blocking_assignment ::= variable_lvalue = [ delay_or_event_control ]
// expression`, taking A.6.5's `event_control` branch of `delay_or_event_control`
// rather than fixture 05's `delay_control` branch:
//
//     delay_or_event_control ::= delay_control | event_control
//                              | repeat ( expression ) event_control
//     event_control ::= @ hierarchical_event_identifier | @ ( event_expression )
//                     | @* | @ (*)
//
// §8.5.3.3's rule is written for "a delay", and the event form is the same rule
// with the resumption condition changed from a time to an edge: the right-hand
// side is computed with the values current when the statement is reached, the
// process suspends, and the assignment happens when it resumes.
//
// This is the sampling register of every synchronous model, and the reason it
// needs its own fixture is that explicit `@(posedge)` already works in VerA as a
// STATEMENT prefix — only the intra-assignment position is missing, and the two
// positions differ in exactly which value lands.
//
// HAND DERIVATION.
//   t=0   d<-0101; `q = @(posedge clk) d;` samples d = 0101 and suspends.
//         clk<-0 — x to 0 is a negedge, not a posedge, so nothing resumes.
//         (Both orderings of the two time-zero processes give this; the sample
//         of d is 0101 either way, since only this process writes d at t=0.)
//   t=5   d<-1110
//   t=10  clk 0->1 is a posedge: q<-0101, the value sampled at t=0.
//         display reads d at t=10, which is 1110.
//         -> "intra_event 0101 1110"
//
// The prefix form `@(posedge clk) q = d;` would give "intra_event 1110 1110".
// Not suspending at all gives "intra_event 0101 0101".
//
//! lrm A.6.2
//! lrm A.6.5
//! lrm 8.5.3.3
//! lrm A.6.2:1000
//! lrm A.6.5:1000
//! timescale 1ns/1ps
//! inherited IEEE 1364-2005 9.7.2 9.7.7
`timescale 1ns/1ps
module d04_intra_assignment_event_blocking;
  reg clk;
  reg [3:0] d, q;

  initial begin
    d = 4'b0101;
    q = @(posedge clk) d;
    $display("intra_event %b %b", q, d);
    $finish(0);
  end

  initial begin
    clk = 1'b0;
    #10 clk = 1'b1;
  end

  initial begin
    #5 d = 4'b1110;
  end
endmodule
