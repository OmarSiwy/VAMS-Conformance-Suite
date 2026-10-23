// IEEE1364-2005 §11.4.2: "active events can be taken off the queue and
// processed in any order", so the LRM would also accept an early end with
// neither line printed. VerA documents one order (specification/Vague_Decisions.md)
// and this pins it; the §11.4.2 cite below records that the fixture shows one
// outcome the clause permits: a native executable's levelized logic never
// updates a net some process waits on ahead of the order `vera --run` updates
// it in.
// Time 1: a = 1111 schedules s = a ^ b (§6.1). The fork (§9.8.2) then
// starts its arms. s runs: 1111 ^ 1111 = 0000, which schedules q = |s after
// the arms. Arm 1 suspends at @(negedge q); q then falls 1 -> 0 and wakes
// it: "negedge q at 1". Arm 2 ends at 3, and so does the join.
//! inherited IEEE 1364-2005 11.4.2
module audit_sched_fork_arm_chain_order;
  reg [3:0] a, b;
  wire [3:0] s = a ^ b;
  wire q = |s;
  initial begin
    a = 0; b = 4'b1111;
    #1 a = 4'b1111;
    fork
      @(negedge q) $display("negedge q at %0d", $time);
      #2 a = 0;
    join
    $display("joined at %0d", $time);
    $finish(0);
  end
endmodule
