// IEEE 1364-2005 §18.3.1, p. 339: "The $dumpports task can be invoked
// multiple times throughout the model, but the execution of all $dumpports
// tasks shall be at the same simulation time. Specifying the same
// file_pathname multiple times is not allowed."
//
// Two calls at the same time, with different scopes (u and v, so the
// scope_list rule is kept), name one file. Legal neighbour: one call per
// file, dumpports_control_tasks.v.
//! inherited IEEE 1364-2005 18.3.1
//! reject E1100
//! reject file
//! neighbour dumpports_control_tasks.v
`timescale 1ns/1ns
module b_18_3_1_dumpports_same_file_rejected_dev(a, y);
  input a;
  output y;
  assign y = ~a;
endmodule

module b_18_3_1_dumpports_same_file_rejected;
  reg a;
  wire y, w;
  b_18_3_1_dumpports_same_file_rejected_dev u(a, y);
  b_18_3_1_dumpports_same_file_rejected_dev v(a, w);
  initial begin
    a = 1'b0;
    $dumpports(u, "b_18_3_1_same.evcd");
    $dumpports(v, "b_18_3_1_same.evcd");
    #1 a = 1'b1;
  end
endmodule
