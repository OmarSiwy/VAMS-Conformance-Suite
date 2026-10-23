// IEEE1364-2005 9.7.5 includes the index expression on an assignment LHS,
// while excluding its write-only base. Change only index after first copy:
// both distinct memory words must eventually contain7.
//! lrm 8.5
//! inherited IEEE 1364-2005 9.7.5
`timescale 1ns/1ns
module audit_sched_implicit_lhs_index;
  integer memory [0:1];
  integer index, payload;
  always @* memory[index] = payload;
  initial begin
    memory[0] = 0;
    memory[1] = 0;
    #1 index = 0;
    payload = 7;
    #1 $display("first=%0d/%0d", memory[0], memory[1]);
    index = 1;
    #1 $display("second=%0d/%0d", memory[0], memory[1]);
    $finish(0);
  end
endmodule
