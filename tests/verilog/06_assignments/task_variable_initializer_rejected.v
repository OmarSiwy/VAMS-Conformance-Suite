// IEEE 1364-2005 §6.2.1, p. 72: "Variable declaration assignments are only
// allowed at the module level." The task's declarations are
// block_item_declarations (Syntax 3-7, p. 19: "reg [ signed ] [ range ]
// list_of_block_variable_identifiers"), which carry no "= constant_expression".
//
// a is declared with an initializer inside a task, not at the module level.
// Legal neighbour: examples.v's module-level `reg[3:0] a = 4'h4;`.
//! inherited IEEE 1364-2005 6.2.1
//! reject E1100
//! reject initialized task or function variable
//! neighbour examples.v
module b_6_2_1_task_variable_initializer_rejected;
  task show;
    reg [3:0] a = 4'h4;
    $display("%h", a);
  endtask
  initial show;
endmodule
