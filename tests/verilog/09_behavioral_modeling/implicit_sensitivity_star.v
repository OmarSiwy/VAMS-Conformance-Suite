// A.6.5 `event_control ::= @ hierarchical_event_identifier | @ ( event_expression )
//                        | @* | @ (*)`
//
// VAMS §1.1: "Verilog-AMS HDL consists of the complete IEEE Std 1364 Verilog
// specification", and §1.2: "the semantics of the initial and always blocks
// remain the same as in IEEE Std 1364 Verilog". So `@*` is the implicit
// event_expression list of IEEE Std 1364-2005 Clause 9: the sensitivity list is
// EVERY net/variable the following statement READS, and nothing it only writes.
//
// The whole point of this fixture is the word "every". A one-operand
// implementation (or one that only rescans after the first trigger) gets the
// third line wrong.
//
// HAND DERIVATION — `c` is `a | b`, recomputed whenever a or b changes.
//   t=0   nothing is written: an `always` and an `initial` both start at t=0
//         in either order (IEEE 1364-2005 11.4.2), and @* does not fire at
//         time zero (9.7.5), so a write at t=0 could land before the block
//         waits on it and leave the result at x.
//   t=1   a<-0000, b<-0000 (both leave x)                  c = 0000
//   t=2   display                                          "zeros 0000"
//         a<-0011                                          c = 0011|0000 = 0011
//   t=3   display                                          "a_set 0011"
//         b<-0100                                          c = 0011|0100 = 0111
//   t=4   display                                          "b_set 0111"
//         a<-0000, b<-0000                                 c = 0000
//   t=5   display                                          "cleared 0000"
//
// Every value is read one full nanosecond after the write that causes it, so no
// line depends on the order simultaneous processes are entered in.
//
// Sensitive to only `a`:  "b_set 0011" (wrong).
// Sensitive to only `b`:  "a_set 0000" (wrong).
// `@*` read as "run once, never again": "a_set 0000" (wrong).
//
//! lrm A.6.5
//! lrm 1.1
//! lrm 1.2
//! lrm A.6.5:1000
//! timescale 1ns/1ps
//! inherited IEEE 1364-2005 9.7.5
`timescale 1ns/1ps
module d04_implicit_sensitivity_star;
  reg [3:0] a, b, c;

  always @* c = a | b;

  initial begin
    #1 a = 4'b0000;
    b = 4'b0000;
    #1 $display("zeros %b", c);
    a = 4'b0011;
    #1 $display("a_set %b", c);
    b = 4'b0100;
    #1 $display("b_set %b", c);
    a = 4'b0000;
    b = 4'b0000;
    #1 $display("cleared %b", c);
    $finish(0);
  end
endmodule
