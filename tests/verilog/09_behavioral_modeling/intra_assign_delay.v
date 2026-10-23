// Verilog-AMS LRM 2.4 annex A.6.2:
//   "blocking_assignment ::= variable_lvalue = [ delay_or_event_control ]
//    expression"
//   "nonblocking_assignment ::= variable_lvalue <= [ delay_or_event_control ]
//    expression"
// annex A.6.5: "delay_control ::= # delay_value | # ( mintypmax_expression )".
// The delay sits BETWEEN the `=` and the expression: an intra-assignment
// timing control.
//
// §8.5.3.3 Blocking assignment:
//   "A blocking assignment statement (see 9.2.1 of IEEE Std 1364 Verilog) with
//    a delay COMPUTES THE RIGHT-HAND SIDE VALUE USING THE CURRENT VALUES, then
//    causes the executing process to be suspended and scheduled as a future
//    event. ... When the process is returned ... the process performs the
//    assignment to the left-hand side".
// §8.5.3.4 Non blocking assignment:
//   "A nonblocking assignment statement ... always computes the updated value
//    and schedules the update as a nonblocking assign update event ... as a
//    future event if the delay is nonzero. THE VALUES IN EFFECT WHEN THE
//    UPDATE IS PLACED ON THE EVENT QUEUE are used to compute both the
//    right-hand value and the left-hand target."
//
// Two claims follow, and both are asserted below:
//   (a) the RHS of BOTH forms is sampled when the statement EXECUTES, not when
//       the assignment lands;
//   (b) only the blocking form suspends the process.
//
//! lrm annex A.6.2
//! lrm 8.5.3.3
//! lrm 8.5.3.4
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 9.2.1 9.2.2 9.7.7 11.3 11.6.3 11.6.4
//
// Hand derivation.  All of the following happens at t=0, in order:
//   r := 1, s := 0, b := 1
//   `s <= #7 b;`  RHS sampled NOW -> 1. Update queued for the NBA region of
//                 t=7. The process does NOT suspend (§8.5.3.4).
//   `b = 1'b0;`   b changes AFTER the sample above; by claim (a) it cannot
//                 change what s will receive.
//   `r = #5 b;`   RHS sampled NOW -> 0. The process suspends and is resumed
//                 at t=5, at which point r := 0 (§8.5.3.3).
// Observations:
//   t=4  (peer process; the main process is still suspended)
//        r = 1  -> the blocking assignment has NOT landed early
//        s = 0
//   t=5  r = 0  -> landed at exactly t=5
//        s = 0
//   t=6  r = 0, s = 0
//   t=7  read in the INACTIVE region, which §8.5.3.3 places before the
//        nonblocking-assign region of the same time, so the queued update has
//        not been applied yet -> s = 0
//   t=8  s = 1  -> the value delivered is 1, the b sampled at t=0, NOT the 0
//        b held from t=0 onward.  Together with the t=7 read this places the
//        update in the NBA region of t=7 (nothing at all is scheduled for
//        t=8), so the 7 in `<= #7` is pinned exactly.

`timescale 1ns/1ns
module intra_assign_delay;
  reg b, r, s;

  initial begin
    r = 1'b1; s = 1'b0; b = 1'b1;
    s <= #7 b;
    b = 1'b0;
    r = #5 b;
    #0 $display("t5 r=%b s=%b", r, s);
    #1 #0 $display("t6 r=%b s=%b", r, s);
    #1 #0 $display("t7-inactive r=%b s=%b", r, s);
    #1 #0 $display("t8 r=%b s=%b", r, s);
    $finish(0);
  end

  initial begin
    #4 #0 $display("t4 r=%b s=%b", r, s);
  end
endmodule
