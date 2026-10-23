// IEEE 1364-2005 §10.2.3, p. 149: "All variables of a static task shall be
// static in that there shall be a single variable corresponding to each
// declared local variable in a module instance, regardless of the number of
// concurrent activations of the task. However, static tasks in different
// instances of a module shall have separate storage from each other.
// Variables declared in static tasks, including input, output, and inout type
// arguments, shall retain their values between invocations. They shall be
// initialized to the default initialization value as described in 4.2.2.
// Variables declared in automatic tasks, including output type arguments,
// shall be initialized to the default initialization value whenever execution
// enters their scope."
// §4.2.2, p. 23: "The initialization value for reg, time, and integer data
// types shall be the unknown value, x."
//
// sub has a static task bump with a local integer k, never assigned outside
// bump. On entry bump records whether k is still x (1 on the very first
// call only), then k = (k === x ? 0 : k) + 1, and returns k through its
// output argument.
//   u1 enables bump 3 times, u2 twice, each in its own instance's initial.
//   Separate storage per instance: u1's k ends at 3, u2's at 2; each
//   instance's first call saw x (fresh = 1), later calls did not.
//   u1 displays at t = 1, u2 at t = 2 (no same-time race):
//     "u1 k=3 first_fresh=1 last_fresh=0"
//     "u2 k=2 first_fresh=1 last_fresh=0"
//   Shared storage would give u2 k=5 and first_fresh=0.
// Automatic task fresh_auto(output reg o) with local reg a: on each entry a
//   and o are x again, even though the previous activation set both to 1.
//   `seen` records a === x and o === x on entry for two calls:
//     "auto 11 11"
//! inherited IEEE 1364-2005 10.2.3
`timescale 1ns/1ns
module b_10_2_3_task_storage_per_instance;
  reg [1:0] s1, s2;
  reg o;
  sub #(3, 1) u1();
  sub #(2, 2) u2();

  task automatic fresh_auto(output reg [1:0] seen, output reg o);
    reg a;
    begin
      seen = {a === 1'bx, o === 1'bx};
      a = 1;
      o = 1;
    end
  endtask

  initial begin
    #3;
    fresh_auto(s1, o);
    fresh_auto(s2, o);
    $display("auto %b %b", s1, s2);
    $finish(0);
  end
endmodule

module sub;
  parameter CALLS = 1, AT = 1;
  integer n, first_fresh, fresh, last_k;

  task bump;
    output integer kout;
    integer k;
    begin
      fresh = (k === 32'bx);
      k = (k === 32'bx ? 0 : k) + 1;
      kout = k;
    end
  endtask

  initial begin
    for (n = 0; n < CALLS; n = n + 1) begin
      bump(last_k);
      if (n == 0) first_fresh = fresh;
    end
    #AT $display("u%0d k=%0d first_fresh=%0d last_fresh=%0d", AT, last_k, first_fresh, fresh);
  end
endmodule
