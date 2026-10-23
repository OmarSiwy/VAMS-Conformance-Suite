// IEEE 1364-2005 §10.2.3, p. 149: "Because variables declared in
// automatic tasks are deallocated at the end of the task invocation, they
// shall not be used in certain constructs that might refer to them after that
// point: — They shall not be assigned values using nonblocking assignments or
// procedural continuous assignments."
//
// `assign v = 2` is a procedural continuous assignment to v, a variable of the
// automatic task t. Legal neighbour: task_storage_per_instance.v
// assigns the variables of an automatic task with blocking assignments.
//! inherited IEEE 1364-2005 10.2.3
//! reject E1100
//! reject automatic
//! neighbour task_storage_per_instance.v
module b_10_2_3_automatic_procedural_assign_rejected;
  task automatic t;
    reg [7:0] v;
    begin
      v = 1;
      assign v = 2;
    end
  endtask
  initial t;
endmodule
