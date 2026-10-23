// IEEE 1364-2005 §10.2.3, p. 149: "A task may be enabled more than once
// concurrently. All variables of an automatic task shall be replicated on
// each concurrent task invocation to store state specific to that
// invocation." §9.8.2, p. 141: in a parallel block "Statements shall execute
// concurrently", "Delay values for each statement shall be considered
// relative to the simulation time of entering the block", and "Control shall
// pass out of the block when the last time-ordered statement executes."
//
// t(n) forks two arms and waits at `join`: arm 1 re-enters t at n - 1 one
// unit later, arm 2 prints two units later. Every activation's fork is the
// same source fork, so each activation must wait for its OWN two arms.
//
// HAND DERIVATION (an activation is named by its n):
//   t = 0  t(2) forks: arm 1 waits #1, arm 2 waits #2.
//   t = 1  t(2)'s arm 1 enters t(1), which forks: its arm 1 waits #1, its
//          arm 2 #2. t(2)'s arm 1 now waits for t(1) to return.
//   t = 2  t(2)'s arm 2 prints "2: n=2 arm"; t(1)'s arm 1 enters t(0), which
//          returns at once (n = 0). t(1) still waits for its arm 2; t(2) for
//          its arm 1.
//   t = 3  t(1)'s arm 2 prints "3: n=1 arm"; both of t(1)'s arms are done, so
//          it prints "3: n=1 joined" and returns; that ends t(2)'s arm 1, both
//          of t(2)'s arms are done, and it prints "3: n=2 joined".
// The three lines at t = 3 are one causal chain, not a race. One join count
// shared by the activations would let t(1)'s arm 1 finishing at t = 2 release
// a join early, and a "joined" line would print at t = 2.
//! inherited IEEE 1364-2005 10.2.3
//! inherited IEEE 1364-2005 9.8.2
`timescale 1ns/1ns
module b_10_2_3_recursive_task_fork_join;
  task automatic t(input integer n);
    if (n > 0) begin
      fork
        #1 t(n - 1);
        #2 $display("%0d: n=%0d arm", $time, n);
      join
      $display("%0d: n=%0d joined", $time, n);
    end
  endtask
  initial t(2);
endmodule
