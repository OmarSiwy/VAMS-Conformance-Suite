// IEEE 1364-2005 A.2.8, p. 493: a block_item_declaration is a reg, integer,
// time, real, realtime, event, local_parameter or parameter declaration.
// A net_declaration (A.2.1.3) is not among them: nets belong to modules
// (A.1.4's module_or_generate_item_declaration), never to a task, function
// or block.
//
// `wire w;` among a task's block items derives no block_item_declaration.
// Legal neighbour: b_A_2_8_block_item_declarations.v (`reg [3:0] ra [0:1];`
// in the same place).
//! inherited IEEE 1364-2005 A.2.8
//! reject E0209
//! reject found `wire`
//! neighbour b_A_2_8_block_item_declarations.v
module b_A_2_8_net_block_item_rejected;
  task run ();
    wire w;
    ;
  endtask
  initial run;
endmodule
