// A.6.2 `blocking_assignment ::= variable_lvalue = [ delay_or_event_control ]
// expression` and A.6.5 `delay_or_event_control ::= delay_control |
// event_control | repeat ( expression ) event_control`.
//
// §8.5.3.3 Blocking assignment: "A blocking assignment statement (see 9.2.1 of
// IEEE Std 1364 Verilog) with a delay computes the right-hand side value using
// the current values, then causes the executing process to be suspended and
// scheduled as a future event. ... When the process is returned ... the process
// performs the assignment to the left-hand side ... The values at the time the
// process resumes are used to determine the target(s)."
//
// Two separable claims, and this fixture separates them:
//   (a) the RHS is sampled at the moment the statement is REACHED, and
//   (b) the process is genuinely suspended for the delay, so the statement
//       AFTER it sees the world as it is when the process resumes.
//
// HAND DERIVATION.
//   t=0   a<-0001
//         `b = #5 a;` samples a = 0001 NOW, then suspends until t=5
//   t=2   the second process writes a<-1111
//   t=5   the first process resumes: b<-0001 (the sampled value, not 1111),
//         then `c = a;` runs at t=5 where a is 1111, so c<-1111
//         display -> "intra 0001 1111"
//
// The statement-prefix form `#5 b = a;` would give "intra 1111 1111" — the
// difference between the two forms is the entire content of this fixture.
// A form that sampled the RHS on resumption gives "intra 1111 1111" too.
// A form that did not suspend gives "intra 0001 0001" (c read at t=0).
//
//! lrm A.6.2
//! lrm A.6.5
//! lrm 8.5.3.3
//! lrm A.6.2:1000
//! timescale 1ns/1ps
//! inherited IEEE 1364-2005 9.2.1 9.7.7 11.6.3
`timescale 1ns/1ps
module d04_intra_assignment_delay_blocking;
  reg [3:0] a, b, c;

  initial begin
    a = 4'b0001;
    b = #5 a;
    c = a;
    $display("intra %b %b", b, c);
    $finish(0);
  end

  initial begin
    #2 a = 4'b1111;
  end
endmodule
