// A.6.5 `event_control ::= @ hierarchical_event_identifier | @ ( event_expression )
//                        | @* | @ (*)`
//
// d04_01 pins `@*`. This pins the other spelling, `@ (*)`, which names the same
// implicit list. Written without a space, `(*` is also how §2.9 opens an
// attribute instance, so the two characters must still be read as a
// parenthesis and a star here; with spaces, `( *)` ends in the attribute
// closer `*)` and must be read the same way.
//
// HAND DERIVATION: `c` and `d` are each `a | b`, one block per spelling, so
// the lines are d04_01's with both columns equal:
//   t=0   nothing is written (the time-zero race d04_01 explains)
//   t=1   a<-0000, b<-0000                            c = d = 0000
//   t=2   "zeros 0000 0000",   a<-0011                c = d = 0011
//   t=3   "a_set 0011 0011",   b<-0100                c = d = 0111
//   t=4   "b_set 0111 0111",   a<-0000, b<-0000       c = d = 0000
//   t=5   "cleared 0000 0000"
//
//! lrm A.6.5
//! lrm A.6.5:1000
//! timescale 1ns/1ps
//! inherited IEEE 1364-2005 9.7.5
`timescale 1ns/1ps
module d04_implicit_sensitivity_paren_star;
  reg [3:0] a, b, c, d;

  always @(*) c = a | b;
  always @( *) d = a | b;

  initial begin
    #1 a = 4'b0000;
    b = 4'b0000;
    #1 $display("zeros %b %b", c, d);
    a = 4'b0011;
    #1 $display("a_set %b %b", c, d);
    b = 4'b0100;
    #1 $display("b_set %b %b", c, d);
    a = 4'b0000;
    b = 4'b0000;
    #1 $display("cleared %b %b", c, d);
    $finish(0);
  end
endmodule
