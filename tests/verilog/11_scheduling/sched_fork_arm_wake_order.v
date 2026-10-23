// IEEE1364-2005 §11.4.2: "active events can be taken off the queue and
// processed in any order", so the LRM would also accept "timeout" here. VerA
// documents one order (specification/Vague_Decisions.md) and this pins it; the
// §11.4.2 cite below records that the fixture shows one outcome the clause
// permits: every engine wakes the event controls a change satisfies in the
// order they suspended, as `vera --run` does, so a native executable never
// misses an edge the interpreter sees.
// Time 1: the fork (§9.8.2) starts its arms. Arm 1 suspends at
// @(posedge clk). Arm 2 sets kick, which wakes the always block; it flips
// go to 1 while nobody waits on go and suspends again, after arm 1. Time 2:
// clk rises. Arm 1 suspended first, so it resumes first and suspends at
// @(go); the always block then flips go back to 0, which wakes arm 1:
// "arm saw go=0 at 2". Arm 3 is done, so the join completes at 2.
//! inherited IEEE 1364-2005 11.4.2
module audit_sched_fork_arm_wake_order;
  reg clk, go, kick;
  always @(posedge clk or posedge kick) go = ~go;
  initial begin
    clk = 0; go = 0; kick = 0;
    #1 fork
      begin @(posedge clk) @(go) $display("arm saw go=%b at %0d", go, $time); end
      kick = 1;
      #1 clk = 1;
    join
    $display("joined at %0d", $time);
    $finish(0);
  end
  initial #5 begin $display("timeout"); $finish(0); end
endmodule
