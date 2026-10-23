// IEEE 1364-2005 §9.2.1, p. 117: "A blocking procedural assignment statement
// shall be executed before the execution of the statements that follow it in a
// sequential block (see 9.8.1). A blocking procedural assignment statement
// shall not prevent the execution of statements that follow it in a parallel
// block (see 9.8.2)."
// p. 118: "If variable_lvalue requires an evaluation, it shall be evaluated at
// the time specified by the intra-assignment timing control."
//
//   t=0  a = 1; b = a;       sequential: b reads the updated a -> b = 1
//   t=0  fork x = #5 1; y = 2; join
//        the blocking x = #5 1 does not hold back y = 2 in the parallel
//        block; the first initial prints at t=1 (x still 0, y = 2) and the
//        join completes at t=5 -> x = 1
//   t=5  m[i] = #10 4'd9 with i = 0; the second initial sets i = 1 at t=7;
//        the index is evaluated when the delay expires (t=15) -> m[1] = 9,
//        m[0] keeps 0
//   prints "1 1" (t=0), "0 2" (t=1), "1 2" (t=5), "0 9" (t=15)
//! inherited IEEE 1364-2005 9.2.1
`timescale 1ns/1ns
module b_9_2_1_blocking_order_and_target;
  reg a, b;
  reg [1:0] x, y;
  reg [3:0] m [0:1];
  integer i;

  initial begin
    a = 1'b0;
    b = 1'b0;
    a = 1'b1;
    b = a;
    $display("%b %b", a, b);
    x = 0;
    y = 0;
    fork
      x = #5 2'd1;
      y = 2'd2;
    join
    $display("%0d %0d", x, y);
    m[0] = 0;
    m[1] = 0;
    i = 0;
    m[i] = #10 4'd9;
    $display("%0d %0d", m[0], m[1]);
    $finish(0);
  end

  initial begin
    #1 $display("%0d %0d", x, y);
    #6 i = 1;
  end
endmodule
