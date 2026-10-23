// IEEE 1364-2005 §4.11, p. 39: "Once a name is defined within the block,
// module, port, generate block, or specify block name space, it shall not be
// defined again in that space (with the same or a different type)." p. 40:
// the module name space "unifies the definition of functions, tasks, named
// blocks, module instances, generate blocks, parameters, named events,
// genvars, net type of declaration, and variable type of declaration."
// §12.7, p. 195: "it is illegal to declare two or more variables that have
// the same name, or to name a task the same as a variable within the same
// module".
//
// t is a reg and a task of one module. Legal neighbour:
// 10_tasks_functions/task_function_distinctions.v (tasks with names
// of their own).
//! lrm 6.8
//! lrm 6.8:2
//! inherited IEEE 1364-2005 4.11
//! reject duplicate
module b_4_11_task_named_like_variable_rejected;
  reg t;
  task t;
    begin
    end
  endtask
  initial $display("unreachable");
endmodule
