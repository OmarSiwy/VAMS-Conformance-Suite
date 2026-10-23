// IEEE 1364-2005 §9.6: "while  Executes a statement until an expression
// becomes false." An untimed loop that ends is legal however long it runs;
// VerA's per-time-step budget (specification/Vague_Decisions.md §7, `vera
// --event-budget=N`) counts its iterations with the step's events, and
// refuses only a step past the budget (forever_without_timing_rejected.v,
// the illegal neighbour, at the same budget of 1000).
//
// DERIVATION: at time 0 there are two process events and 900 iterations of
// the while loop (one count per pass back to its test): 902 <= 1000, so the
// loop ends with n = 900 and the run goes on to time 5.
//! event-budget 1000
//! inherited IEEE 1364-2005 9.6
module b_9_6_untimed_loop_under_budget;
  integer n;
  initial begin
    n = 0;
    while (n < 900) n = n + 1;
    $display("%0d", n);
  end
  initial #5 $display("t=%0t n=%0d", $time, n);
endmodule
