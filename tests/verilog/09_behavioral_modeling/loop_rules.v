// IEEE 1364-2005 §9.6, p. 130: "repeat  Executes a statement a fixed number of
// times. If the expression evaluates to unknown or high impedance, it shall be
// treated as zero, and no statement shall be executed. while  Executes a
// statement until an expression becomes false. If the expression starts out
// false, the statement shall not be executed at all. for  Controls execution
// of its associated statement(s) by a three-step process, as follows: a)
// Executes an assignment normally used to initialize a variable that controls
// the number of loops executed. b) Evaluates an expression. If the result is
// zero, the for loop shall exit. If it is not zero, the for loop shall execute
// its associated statement(s) and then perform step c). If the expression
// evaluates to an unknown or high-impedance value, it shall be treated as
// zero. c) Executes an assignment normally used to modify the value of the
// loop-control variable, then repeats step b)."
// "forever  Continuously executes a statement."
//
//   repeat (4'b01x0) and repeat (1'bz): no iteration -> n = 0
//   repeat (3): n = 3
//   while (n > 5): false at the start -> n stays 3
//   for (i = 0; i < 4; i = i + 2) trace = trace*10 + i + 1:
//     a) i = 0; b) 0 < 4 body (trace 1); c) i = 2; b) body (trace 13);
//     c) i = 4; b) 4 < 4 false, exit -> trace 13, i = 4 (the step ran twice)
//   for (i = 7; 1'bx; i = i + 1): step b) is x, taken as zero; step a) still
//     ran -> i = 7 and no iteration
//   forever: body runs until disable; k counts to 5
//! inherited IEEE 1364-2005 9.6
module b_9_6_loop_rules;
  integer n, i, trace, k;

  initial begin
    n = 0;
    repeat (4'b01x0) n = n + 1;
    repeat (1'bz) n = n + 1;
    $display("%0d", n);
    repeat (3) n = n + 1;
    $display("%0d", n);
    while (n > 5) n = n + 1;
    $display("%0d", n);
    trace = 0;
    for (i = 0; i < 4; i = i + 2) trace = trace * 10 + i + 1;
    $display("%0d %0d", trace, i);
    for (i = 7; 1'bx; i = i + 1) trace = 0;
    $display("%0d %0d", trace, i);
    k = 0;
    begin : spin
      forever begin
        k = k + 1;
        if (k == 5) disable spin;
      end
    end
    $display("%0d", k);
    $finish(0);
  end
endmodule
