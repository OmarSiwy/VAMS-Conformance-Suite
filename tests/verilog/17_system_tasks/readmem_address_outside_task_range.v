// IEEE 1364-2005 §17.2.9: when the task call and the data file both give
// addresses, a file address outside the task's start..finish range is an
// error message and the end of the LOAD operation; nothing in the clause
// ends the simulation (#65: VerA ended the whole run).
// The task loads mem[0:3] from 0 up to 1. The file:
//   @1 aa  -> mem[1] = aa (1 is the finish address: the walk is exhausted)
//   @0 bb  -> mem[0] = bb (an address restarts the walk)
//   @3 cc  -> 3 is outside 0..1: error E1157, the load is terminated
//   @0 dd  -> never read, so mem[0] stays bb
// mem[2] and mem[3] were never loaded and keep §3.2's x. The run goes on:
//   "bb aa xx xx", then "after the failed load"; it exits 1 because an
//   error was issued.
//! inherited IEEE 1364-2005 17.2.9
//! reject E1157
//! reject is outside the load range
module b_17_2_9_readmem_address_outside_task_range;
  reg [7:0] mem[0:3];
  initial begin
    $readmemh("readmem_address_outside_task_range.hex", mem, 0, 1);
    $display("%h %h %h %h", mem[0], mem[1], mem[2], mem[3]);
    $display("after the failed load");
  end
endmodule
