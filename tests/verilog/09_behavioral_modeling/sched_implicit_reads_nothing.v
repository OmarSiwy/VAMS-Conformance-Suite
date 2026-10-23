// IEEE 1364-2005 9.7.5: "the implicit event_expression ... all net and
// variable identifiers which appear in the statement ... will be
// automatically added to the event expression". The clause states no
// restriction on a statement that reads nothing: its list is empty, and an
// empty list has no change to wait for, so the process suspends forever.
// By hand: `always @* a = 1'b1` reads nothing (a is only an LHS, 9.7.5's
// exclusion), so it never runs and a keeps the 4.2.2 reg start x. The
// initial process never passes its `@*`, so b stays x and "unreachable" is
// not printed. c reads src and is the legal neighbour that does wake: src
// goes 1 at #1, so c is 1 at #2.
// Wrong implementations: a refusal of the empty list (the defect this pins)
// compiles nothing; running the body once, as a settle node would, prints
// a=1. No invalid form: 9.7.5 gives `@*` no restriction to violate.
//! lrm 8.5
//! inherited IEEE 1364-2005 9.7.5
`timescale 1ns/1ns
module audit_sched_implicit_reads_nothing;
  reg a, b, c, src;
  always @* a = 1'b1;
  always @* c = src;
  initial begin
    @* b = 1'b0;
    $display("unreachable");
  end
  initial begin
    #1 src = 1;
    #1 $display("a=%b b=%b c=%b", a, b, c);
    $finish(0);
  end
endmodule
