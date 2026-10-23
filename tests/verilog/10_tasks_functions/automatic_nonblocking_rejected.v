// IEEE 1364-2005 §10.2.3, p. 149: "Because variables declared in
// automatic tasks are deallocated at the end of the task invocation, they
// shall not be used in certain constructs that might refer to them after that
// point: — They shall not be assigned values using nonblocking assignments or
// procedural continuous assignments."
//
// v is a variable of the automatic task t, and `v <= 1` assigns it with a
// nonblocking assignment. Legal neighbour: task_storage_per_instance.v
// assigns the variables of an automatic task with blocking assignments.
//! inherited IEEE 1364-2005 10.2.3
//! reject E1100
//! reject automatic
//! neighbour task_storage_per_instance.v
module b_10_2_3_automatic_nonblocking_rejected;
  task automatic t;
    reg [7:0] v;
    v <= 1;
  endtask
  initial t;
endmodule
