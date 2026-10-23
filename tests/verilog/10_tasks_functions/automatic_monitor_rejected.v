// IEEE 1364-2005 §10.2.3, pp. 149-150: "Because variables declared in
// automatic tasks are deallocated at the end of the task invocation, they
// shall not be used in certain constructs that might refer to them after that
// point:" ... "— They shall not be traced with system tasks such as $monitor
// and $dumpvars."
//
// $monitor(v) traces v, a variable of the automatic task t. Legal neighbour:
// task_storage_per_instance.v reads the variables of an automatic
// task with an ordinary expression while the task runs.
//! inherited IEEE 1364-2005 10.2.3
//! reject E1100
//! reject automatic
//! neighbour task_storage_per_instance.v
module b_10_2_3_automatic_monitor_rejected;
  task automatic t;
    reg [7:0] v;
    begin
      v = 1;
      $monitor("%d", v);
    end
  endtask
  initial t;
endmodule
