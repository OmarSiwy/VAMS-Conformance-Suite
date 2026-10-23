// An engine limit, not a language rule. IEEE 1364-2005 §11.4 dispatches
// events at one time until none is left, so a zero-delay loop never lets time
// advance and §11 has nothing to stop it. VerA refuses a time step past a
// budget of events (specification/Vague_Decisions.md): 10,000,000 by default, set by
// `vera --event-budget=N`. The default takes minutes to reach in a Debug
// build, so this fixture sets 1000 and pins that the budget ends the run by
// name rather than hanging.
//
// always #0 a = ~a reschedules itself at time 0 forever (§9.7.1: #0 suspends
// to the inactive region of the SAME time).
//! event-budget 1000
//! inherited IEEE 1364-2005 11.4
//! reject E1100
//! reject more than 1000 events at time 0
//! neighbour region_order.v
module b_11_zero_delay_loop_rejected;
  reg a;
  initial a = 0;
  always #0 a = ~a;
  initial #1 $display("time advanced");
endmodule
