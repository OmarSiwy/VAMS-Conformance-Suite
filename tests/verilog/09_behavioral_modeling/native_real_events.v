// IEEE 1364-2005 §§4.8, 9.7.2: real variables and real array expressions
// have value-change events; +0 and -0 compare equal. Blocking, immediate
// NBA and delayed NBA writes of -0 over zero must therefore wake nobody.
// A selected array expression wakes only when its resulting value changes.
//
// At t=2, r and a[0] change to 1.25 and 2.5 (counts 1,1). Selecting
// a[1]=2.5 at t=4 changes no value. At t=6 selecting a[0]=9.5 increments
// the array count; the delayed a[1]=4.5 update at t=7 is unselected.
// Selecting a[1] at t=8 gives the third array change. r becomes zero at
// t=9; its pending -0 update at t=10 adds none (final counts 2,3), but it
// is still performed: r holds -0.0 and %.2f prints "-0.00", as C's printf
// does (VD-032; this line read 0.00 while VerA dropped the store).
// The delayed rows remain pending across tick boundaries, also exercising
// snapshot restoration. The legal unqualified event has the isolated
// forbidden-edge neighbor native_real_edge_rejected.v (§4.8.1).
//! inherited IEEE 1364-2005 4.8 9.2.2 9.7.2
// native-required
`timescale 1ns/1ns
module native_real_events;
  real r, a[0:1];
  integer scalar_changes, array_changes, sel, i;
  always @(r) scalar_changes = scalar_changes + 1;
  always @(a[sel]) array_changes = array_changes + 1;
  initial begin
    scalar_changes = 0; array_changes = 0; sel = 0; i = 1;
    #1 r = -0.0; a[0] = -0.0; r <= -0.0; a[0] <= -0.0;
    #1 $display("zero %0d %0d", scalar_changes, array_changes);
    r <= 1.25; a[0] <= 2.5;
    #1 $display("changed %0d %0d", scalar_changes, array_changes);
    a[1] = 2.5;
    #1 sel = 1;
    #1 a[0] = 9.5; a[i] <= #2 4.5; i = 0;
    #1 sel = 0;
    #2 sel = 1; r <= #2 -0.0;
    #1 r = 0.0;
    #2 $display("final %0d %0d %.2f %.2f", scalar_changes, array_changes, r, a[1]);
    $finish(0);
  end
endmodule
