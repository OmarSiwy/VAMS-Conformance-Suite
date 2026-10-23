// Legal controls for the task-port rejection cases: one completion, matching
// ranges, and a type supplied only when the input declaration has none.
//@ std 1364-2005
//! inherited IEEE 1364-2005 10.2.1 12.3.3
module nonansi_task_port_completion;
  task scalar;
    input x;
    reg x;
    $display("scalar=%b", x);
  endtask
  task vector;
    input [3:0] x;
    reg [3:0] x;
    $display("vector=%h", x);
  endtask
  task real_input;
    input x;
    real x;
    $display("real=%0.2f", x);
  endtask
  initial begin
    scalar(1);
    vector(4'ha);
    real_input(1.25);
  end
endmodule
