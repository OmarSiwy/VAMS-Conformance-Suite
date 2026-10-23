// An engine limit, not a language rule. IEEE 1364-2005 §9.6: "forever
// Continuously executes a statement." With no timing control in its body the
// process never suspends, so §11.4's loop never gets control back and
// simulation time can never advance. VerA counts every iteration of a loop
// inside one process against the same per-time-step budget as the events of
// that step (specification/Vague_Decisions.md §7, `vera --event-budget=N`,
// 10,000,000 by default) and refuses the step past it by name instead of
// hanging. This fixture sets 1000 so the refusal is quick.
//
// DERIVATION: at time 0 the initial process is one event, and every pass of
// `forever x = 1;` is one more loop iteration, so the 1001st count, inside
// the first activation and still at time 0, ends the run. The $display at #1
// never runs. Legal neighbour: untimed_loop_under_budget.v, a finite
// untimed loop under the same budget that runs to its end.
//! event-budget 1000
//! inherited IEEE 1364-2005 9.6
//! reject E1100
//! reject more than 1000 loop iterations and events at time 0
//! neighbour untimed_loop_under_budget.v
module b_9_6_forever_without_timing_rejected;
  reg x;
  initial forever x = 1;
  initial #1 $display("time advanced");
endmodule
