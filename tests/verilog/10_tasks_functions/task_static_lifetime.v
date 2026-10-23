// A.2.7 `task_declaration ::= task [ automatic ] task_identifier ...` — this
// fixture is the case where `automatic` is ABSENT, which is the default and
// therefore the one a first implementation gets by accident or not at all.
//
// A task declared without `automatic` has STATIC storage: it has exactly one
// copy of its locals for the whole simulation, allocated once, and a local
// therefore keeps its value from one call to the next. That is IEEE Std 1364
// Verilog's Clause 10 lifetime rule, made part of this language by VAMS §1.1
// ("Verilog-AMS HDL consists of the complete IEEE Std 1364 Verilog
// specification"). Fixture 11 pins the `automatic` half.
//
// The observable is deliberately the RETENTION, because an implementation that
// stack-allocates everything (the easy way to build tasks) reads x on the second
// call and is caught here rather than in some later model that silently drifts.
//
// HAND DERIVATION — `n` is the static local; `clr` exists only to give it a
// defined starting value, since a task local cannot carry a declaration
// initializer and starts at x.
//   call 1  step(1, a):  clr is 1 -> n = 0; n = n + 1 = 1; o = 1 -> a = 0001
//   call 2  step(0, b):  clr is 0 -> n keeps the 1 the first call left;
//                        n = n + 1 = 2; o = 2 -> b = 0010
//   -> "static 0001 0010"
//
// Automatic (per-call) storage would give "static 0001 xxxx": the second call's
// fresh `n` is x, x + 1 is x, and o is x.
// Re-running the clear on every call would give "static 0001 0001".
//
//! lrm A.2.7
//! lrm 1.1
//! lrm A.2.7:1000
//! inherited IEEE 1364-2005 10.2.3
module d04_task_static_lifetime;
  reg [3:0] a, b;

  task step(input clr, output [3:0] o);
    reg [3:0] n;
    begin
      if (clr) n = 4'd0;
      n = n + 4'd1;
      o = n;
    end
  endtask

  initial begin
    step(1'b1, a);
    step(1'b0, b);
    $display("static %b %b", a, b);
    $finish(0);
  end
endmodule
