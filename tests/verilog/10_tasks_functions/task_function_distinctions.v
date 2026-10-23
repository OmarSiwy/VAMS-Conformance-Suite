// IEEE 1364-2005 §10.1, p. 145: "The following rules distinguish tasks from
// functions: — A function shall execute in one simulation time unit; a task
// can contain time-controlling statements. — A function cannot enable a task;
// a task can enable other tasks and functions. — A function shall have at
// least one input type argument and shall not have an output or inout type
// argument; a task can have zero or more arguments of any type. — A function
// shall return a single value; a task shall not return a value." ... "However,
// only the output or inout type arguments pass result values back from the
// invocation of a task. A function is used as an operand in an expression;
// the value of that operand is the value returned by the function."
//
// The clause's switch_bytes, once as a task and once as a function.
//   old_word = 16'hA1B2 -> bytes reversed = 16'hB2A1.
//   Task: `#3` inside it, so control returns at t = 3 and new_word (its
//     output argument) = b2a1 -> "3 b2a1".
//   Function: an operand of ^, evaluated at t = 3 with no time passing:
//     16'hB2A1 ^ 16'h00FF = B2 5E -> "3 b25e".
//   pair: a task with zero arguments that enables the task and the function
//     (a task can enable both): at t = 3 it runs switch_task (+3 -> t = 6)
//     writing pair_t = b2a1, then pair_f = switch_fn(16'h0102) = 0201.
//     -> "6 b2a1 0201".
//! inherited IEEE 1364-2005 10.1
`timescale 1ns/1ns
module b_10_1_task_function_distinctions;
  reg [15:0] old_word, new_word, via_f, pair_t, pair_f;

  task switch_task;
    input [15:0] w;
    output [15:0] s;
    begin
      #3 s = {w[7:0], w[15:8]};
    end
  endtask

  function [15:0] switch_fn;
    input [15:0] w;
    switch_fn = {w[7:0], w[15:8]};
  endfunction

  task pair;
    begin
      switch_task(old_word, pair_t);
      pair_f = switch_fn(16'h0102);
    end
  endtask

  initial begin
    old_word = 16'hA1B2;
    switch_task(old_word, new_word);
    $display("%0d %h", $time, new_word);
    via_f = switch_fn(old_word) ^ 16'h00FF;
    $display("%0d %h", $time, via_f);
    pair;
    $display("%0d %h %h", $time, pair_t, pair_f);
    $finish(0);
  end
endmodule
