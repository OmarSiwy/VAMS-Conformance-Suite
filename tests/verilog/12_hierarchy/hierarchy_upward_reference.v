// IEEE 1364-2005 §12.6: "A lower level module can reference items in a module
// above it in the hierarchy." Syntax 12-7 `upward_name_reference ::=
// module_identifier.item_name`, and a `scope_name.item_name` whose scope_name
// is an instance name resolves by: "a) Look in the current scope for a scope
// named scope_name ... b) Look in the parent module's outermost scope for a
// scope named scope_name. If found, the item name shall be resolved from that
// scope. c) Repeat step b), going up the hierarchy."
//
// This is the clause's own example (modules a, b, c, each with an integer i;
// `b.i = 1;` in c is its "upward path"), cut to one top-level module, a,
// since the example's second top, d, only repeats the full-path forms.
//
// HAND DERIVATION (two copies of c, a.a_b1.b_c1 and a.a_b1.b_c2, run the
// same initial block):
//   t=0   each c: i <- 1 (its own); b.i <- 1, which is a.a_b1.i (upward by
//         module name)
//   t=5   each c: a.i <- a_b1.i + 10 = 11 (`a`: the root by its module name;
//         `a_b1`: not in c, not in b, found in a by step c)
//   t=10  b: b_c1.i <- 2 (downward)
//   t=20  a prints a.i, a_b1.i, a_b1.b_c1.i, a_b1.b_c2.i = "11 1 2 1"
//
//! inherited IEEE 1364-2005 12.6
`timescale 1ns/1ns
module a;
  integer i;
  b a_b1();
  initial begin
    #20 $display("%0d %0d %0d %0d", i, a_b1.i, a_b1.b_c1.i, a_b1.b_c2.i);
    $finish(0);
  end
endmodule
module b;
  integer i;
  c b_c1(), b_c2();
  initial #10 b_c1.i = 2;
endmodule
module c;
  integer i;
  initial begin
    i = 1;
    b.i = 1;
    #5 a.i = a_b1.i + 10;
  end
endmodule
