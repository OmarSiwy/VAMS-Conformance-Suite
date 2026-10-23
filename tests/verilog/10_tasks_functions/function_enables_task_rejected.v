// IEEE 1364-2005 §10.1, p. 145: "A function cannot enable a task; a task can
// enable other tasks and functions." §10.4.4, p. 155: "b) Functions shall not
// enable tasks."
//
// f enables the task t. Legal neighbour: task_function_distinctions.v,
// where a task (pair) enables a task and a function.
//! inherited IEEE 1364-2005 10.1 10.4.4
//! reject E1100
//! reject a function cannot enable a task
//! neighbour task_function_distinctions.v
module b_10_4_4_function_enables_task_rejected;
  reg [7:0] x;
  task t;
    input [7:0] a;
    output [7:0] b;
    b = a;
  endtask
  function [7:0] f;
    input [7:0] a;
    t(a, f);
  endfunction
  initial x = f(8'd3);
endmodule
