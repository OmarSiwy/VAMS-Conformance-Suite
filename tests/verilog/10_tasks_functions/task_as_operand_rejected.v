// IEEE 1364-2005 §10.1, p. 145: "A function shall return a single value; a
// task shall not return a value." §10.2, p. 145: "A task shall be enabled from
// a statement that defines the argument values to be passed to the task and
// the variables that receive the results."
//
// `x = t(8'd3)` uses the task t as an operand, as though it returned a value,
// instead of enabling it from a statement; the one argument matches t's one
// input, so the use as an operand is the only defect. Legal neighbour:
// task_function_distinctions.v enables the same kind of task as a
// statement and receives its result through an output argument.
//! inherited IEEE 1364-2005 10.1 10.2
//! reject E1100
//! reject a task is enabled as a statement, not called in an expression
//! neighbour task_function_distinctions.v
module b_10_1_task_as_operand_rejected;
  reg [7:0] x;
  task t;
    input [7:0] a;
    $display("%0d", a);
  endtask
  initial x = t(8'd3);
endmodule
