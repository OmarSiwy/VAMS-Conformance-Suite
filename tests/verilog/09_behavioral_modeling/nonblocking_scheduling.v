// IEEE 1364-2005 §9.2.2, p. 119: "If variable_lvalue requires an evaluation, it
// shall be evaluated at the same time as the expression on the right-hand
// side." ... "When <= is used in an expression, it shall be interpreted as a
// relational operator; and when it is used in a nonblocking procedural
// assignment, it shall be interpreted as an assignment operator."
// p. 120: "The nonblocking assignment evaluates and schedules the assignment,
// but it does not block the execution of subsequent statements in a begin-end
// block."
// p. 121: "The order of the execution of distinct nonblocking assignments to a
// given variable shall be preserved." (Examples 3, 4 and 6 of the clause.)
//
//   t=0  a = 0, b = 0, c = 1; a <= b <= c is a <= (b <= c) = (0 <= 1) = 1,
//        scheduled; the next $display is not blocked and still sees a = 0
//   t=1  a = 1
//   t=1  p = 0, q = 1; p <= q; q <= p: both right-hand sides are read before
//        either update -> at t=2 p = 1, q = 0 (Example 3's swap)
//   t=0  e = 1; e <= #4 0; e <= #4 1: both updates land at t=4 in execution
//        order, the last is 1 -> printed at t=5 (Example 4)
//   t=2  i = 0; m[i] <= #5 4'd9: the index is evaluated now with the RHS, so
//        the update at t=7 goes to m[0] even though i = 1 from t=3
//        -> printed at t=8: m[0] = 9, m[1] = 0
//   f: #8 f <= #8 1 executes at t=8 for t=16; #12 f <= #4 0 executes at t=12
//        for t=16; the update scheduled first is applied first, so f = 0 after
//        t=16 -> printed at t=17 (Example 6)
//   prints "0" (t0), "1" (t1), "1 0" (t2), "1" (t5), "9 0" (t8), "0" (t17)
//! inherited IEEE 1364-2005 9.2.2
`timescale 1ns/1ns
module b_9_2_2_nonblocking_scheduling;
  reg a, b, c, p, q, e, f;
  reg [3:0] m [0:1];
  integer i;

  initial begin
    a = 1'b0;
    b = 1'b0;
    c = 1'b1;
    a <= b <= c;
    $display("%b", a);
    #1 $display("%b", a);
    p = 1'b0;
    q = 1'b1;
    p <= q;
    q <= p;
    #1 $display("%b %b", p, q);
    m[0] = 0;
    m[1] = 0;
    i = 0;
    m[i] <= #5 4'd9;
    #1 i = 1;
    #5 $display("%0d %0d", m[0], m[1]);
    #9 $display("%b", f);
    $finish(0);
  end

  initial begin
    e = 1'b1;
    e <= #4 1'b0;
    e <= #4 1'b1;
    #5 $display("%b", e);
  end

  initial #8 f <= #8 1'b1;
  initial #12 f <= #4 1'b0;
endmodule
