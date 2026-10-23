// IEEE 1364-2005 §10.2.1, p. 147: "Tasks without the optional keyword
// automatic are static tasks, with all declared items being statically
// allocated. These items shall be shared across all uses of the task
// executing concurrently. Task with the optional keyword automatic are
// automatic tasks. All items declared inside automatic tasks are allocated
// dynamically for each invocation. Automatic task items cannot be accessed by
// hierarchical references."
//
// A static task's item is statically allocated, and the prohibition names
// only automatic task items, so `t.v` (a task defines a hierarchical level,
// §12.5) reads the static item after t returns: t sets v = 5, the task keeps
// it -> "t.v = 5".
// The rejected automatic counterpart is
// automatic_task_item_hierarchical_rejected.v.
//! inherited IEEE 1364-2005 10.2.1
module b_10_2_1_static_task_item_hierarchical;
  task t;
    reg [7:0] v;
    v = 5;
  endtask
  initial begin
    t;
    $display("t.v = %0d", t.v);
    $finish(0);
  end
endmodule
