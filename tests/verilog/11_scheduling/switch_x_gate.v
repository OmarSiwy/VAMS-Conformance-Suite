// IEEE 1364-2005 §11.6.5, pp. 161-162: "Switch processing shall consider all
// the devices in a bidirectional switch-connected net before it can determine
// the appropriate value for any node on the net because the inputs and
// outputs interact." ... "Further refinement is required when some
// transistors have gate value x. A conceptually simple technique is to solve
// the network repeatedly with these transistors set to all possible
// combinations of fully conducting and nonconducting transistors. Any node
// that has a unique logic level in all cases has steady-state response equal
// to this level. All other nodes have steady-state response x."
//
// n1 is driven strong by d (assign); n2 is driven weak 1 (assign (weak0,
// weak1)); tranif1 t joins them under gate g. §7.11, p. 100: "The tran,
// tranif0, and tranif1 switches shall not affect signal strength across the
// bidirectional terminals, except that a supply strength shall be reduced to
// a strong strength." So St0/St1 from n1 reaches n2 as St0/St1.
//   d = 1, g = x: conducting, n2 sees St1 and We1 -> 1; nonconducting, n2
//                 sees We1 alone -> 1. Unique in all cases: n2 = 1.
//   d = 0, g = x: conducting, St0 beats We1 -> 0; nonconducting, We1 -> 1.
//                 Not unique: n2 = x.
//   d = 0, g = 1: conducting only: St0 beats We1 -> n2 = 0.
//   d = 0, g = 0: nonconducting only: n2 = 1.
// §7 gives no table for an x-gated tran; read like Figure 7-6's x-controlled
// bufif1 (p. 90), it passes StH (d = 1) or StL (d = 0), and §7.10.3's rules
// (p. 94) agree: StH with We1 keeps St1..We1, all strength1 -> 1; StL with
// We1 keeps St0..La0 plus the opposite-value gap to We1 (rule c) -> x.
// Each display is one time step after the change, so the net has settled.
//! inherited IEEE 1364-2005 11.6.5
// native-required
`timescale 1ns/1ns
module b_11_6_5_switch_x_gate;
  reg d, g;
  wire n1, n2;
  assign n1 = d;
  assign (weak0, weak1) n2 = 1'b1;
  tranif1 t(n1, n2, g);
  initial begin
    d = 1; g = 1'bx;
    #1 $display("d=1 g=x: n2=%b", n2);
    d = 0;
    #1 $display("d=0 g=x: n2=%b", n2);
    g = 1;
    #1 $display("d=0 g=1: n2=%b", n2);
    g = 0;
    #1 $display("d=0 g=0: n2=%b", n2);
    $finish(0);
  end
endmodule
