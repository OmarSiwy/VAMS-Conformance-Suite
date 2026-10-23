// The completion must preserve the port's declared vector range.
//@ std 1364-2005
//! inherited IEEE 1364-2005 10.2.1 12.3.3
//! reject-only differs from its port declaration's
//! neighbour nonansi_task_port_completion.v
module nonansi_task_port_range_mismatch_rejected;
  task t;
    input [3:0] x;
    reg [7:0] x;
    $display("invalid task accepted");
  endtask
  initial t(1);
endmodule
