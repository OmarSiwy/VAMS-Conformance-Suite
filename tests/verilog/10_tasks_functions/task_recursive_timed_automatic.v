// IEEE 1364-2005 §10.2.3: "A task may be enabled more than once concurrently.
// All variables of an automatic task shall be replicated on each concurrent
// task invocation to store state specific to that invocation", and
// "Variables declared in automatic tasks, including output type arguments,
// shall be initialized to the default initialization value whenever
// execution enters their scope. input and inout type arguments shall be
// initialized to the values passed". §10.2.2: when the task completes, the
// output values are passed to the enabling statement's variables.
//
// `sum` suspends (#d) before each recursive enable, so every level is a
// separate activation that lives across simulation time, and two callers
// have activations of it alive at once.
//
// HAND DERIVATION. sum(n, d, total) waits d, recurses on n-1, then
// total = (n-1's total) + n, so total = n(n+1)/2.
//   A = sum(2, 2): levels n=2 (t=0), n=1 (t=2), n=0 (t=4). The n=0 level
//     returns 0 at t=4 without waiting; n=1 then prints total 1 and n=2
//     prints 3, all at t=4. ra = 3.
//   B = sum(3, 3): levels n=3 (t=0), 2 (t=3), 1 (t=6), 0 (t=9); at t=9 the
//     chain unwinds printing totals 1, 3, 6. rb = 6.
//   B's n=2 level (entered t=3) is alive while A's n=1 level resumes at t=4,
//   and A's n=1 is alive while B's n=2 level is entered at t=3: if they
//   shared one frame, B's n (2) would overwrite A's n (1) and A would print
//   total 2 and ra = 4.
//! inherited IEEE 1364-2005 10.2.3 (automatic task storage per activation)
//! inherited IEEE 1364-2005 10.2.2 (output copy-back)
// native-required
`timescale 1ns/1ns
module audit_task_recursive_timed_automatic;
  integer ra, rb;
  task automatic sum(input integer n, input integer d, output integer total);
    integer below;
    begin
      if (n == 0) total = 0;
      else begin
        #d sum(n - 1, d, below);
        total = below + n;
        $display("%0d: n=%0d total=%0d", $time, n, total);
      end
    end
  endtask
  initial begin
    sum(2, 2, ra);
    $display("%0d: ra=%0d", $time, ra);
  end
  initial begin
    sum(3, 3, rb);
    $display("%0d: rb=%0d", $time, rb);
  end
endmodule
