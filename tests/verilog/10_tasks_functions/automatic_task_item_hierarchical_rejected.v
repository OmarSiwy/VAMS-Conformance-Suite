// IEEE 1364-2005 §10.2.1, p. 147: "All items declared inside automatic tasks
// are allocated dynamically for each invocation. Automatic task items cannot
// be accessed by hierarchical references."
//
// `t.v` names an item of the automatic task t. Legal neighbour:
// static_task_item_hierarchical.v, the same reference into a static
// task.
//! inherited IEEE 1364-2005 10.2.1
//! reject E1100
//! reject automatic
//! neighbour static_task_item_hierarchical.v
module b_10_2_1_automatic_task_item_hierarchical_rejected;
  task automatic t;
    reg [7:0] v;
    v = 5;
  endtask
  initial begin
    t;
    $display("%0d", t.v);
  end
endmodule
