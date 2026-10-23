// IEEE 1364-2005 §8.7, p. 114: "UDP definitions allow a mixing of the
// level-sensitive and the edge-sensitive constructs in the same table. When
// the input changes, the edge-sensitive cases are processed first, followed
// by level-sensitive cases. Thus, when level-sensitive and edge-sensitive
// cases specify different output values, the result is specified by the
// level-sensitive case." ... "In this example, the preset and clear logic is
// level-sensitive. Whenever the preset and clear combination is 01, the
// output has value 1. Similarly, whenever the preset and clear combination
// has value 10, the output has value 0." (p. 115:) "The last two entries
// show that the transitions in j and k inputs do not change the output on a
// steady low or high clock."
//
// jk_edge_ff is the clause's table verbatim (pc = preset, clear; both
// active low). Inputs start x and q starts x; one input changes per step and
// q is displayed one unit after the step it is labelled with:
//   preset0  preset x->0, pc 0x: no row matches, x              -> x
//   clear1   clear x->1, pc 01: level `? ?? 01` -> 1            -> 1
//   clock0   clock x->0: no edge row; pc 01 level -> 1          -> 1
//   jk00     j x->0 then k x->0 on a steady clock: `b *?` and
//            `b ?*` give -, pc 01 level gives 1                  -> 1
//   pc11     preset 0->1, clear 1, state 1: `? ?? *1 : 1 : 1`   -> 1
//   r00      clock 0->1, jk 00, pc 11: `r 00 11 : ? : -`        -> 1
//   f        clock 1->0: `f ?? ?? : ? : -`                      -> 1
//   k1       k 0->1, clock 0: `b ?*` -> -                       -> 1
//   r01      clock r, jk 01: `r 01 11 : ? : 0`                  -> 0
//   j1       clock f (-), then j 0->1 on clock 0 (-)            -> 0
//   r11      clock r, jk 11, state 0: `r 11 11 : 0 : 1`         -> 1
//   f        clock f                                            -> 1
//   r11      clock r, jk 11, state 1: `r 11 11 : 1 : 0`         -> 0
//   k0       clock f (-), then k 1->0 (-)                       -> 0
//   r10      clock r, jk 10: `r 10 11 : ? : 1`                  -> 1
//   pc10     clear 1->0, pc 10: level `? ?? 10` -> 0 (the edge
//            row `? ?? 1*` needs state 0 and does not match)    -> 0
//   pc11     clear 0->1, state 0: `? ?? 1* : 0 : 0`             -> 0
//   f        clock 1->0 -> -                                    -> 0
//   r10      clock r, jk 10                                     -> 1
// Level dominance itself (an edge row and a level row matching one input
// change with different outputs) is exercised by
// udp_potential_edges_dominance.v; no input sequence reaches the
// §8.8's (p. 115) Table 8-3 case, whose state 0 with pc 01 the preset row forbids.
//! inherited IEEE 1364-2005 8.7
`timescale 1ns/1ns
primitive jk_edge_ff (q, clock, j, k, preset, clear);
output q; reg q;
input clock, j, k, preset, clear;
table
// clock jk pc state output/next state
   ?     ?? 01 : ? : 1 ; // preset logic
   ?     ?? *1 : 1 : 1 ;
   ?     ?? 10 : ? : 0 ; // clear logic
   ?     ?? 1* : 0 : 0 ;
   r     00 00 : 0 : 1 ; // normal clocking cases
   r     00 11 : ? : - ;
   r     01 11 : ? : 0 ;
   r     10 11 : ? : 1 ;
   r     11 11 : 0 : 1 ;
   r     11 11 : 1 : 0 ;
   f     ?? ?? : ? : - ;
   b     *? ?? : ? : - ; // j and k transition cases
   b     ?* ?? : ? : - ;
endtable
endprimitive

module b_8_7_jk_edge_ff;
  reg clock, j, k, preset, clear;
  wire q;
  jk_edge_ff u(q, clock, j, k, preset, clear);
  initial begin
    preset = 0;
    #1 $display("preset0 %b", q);
    clear = 1;
    #1 $display("clear1 %b", q);
    clock = 0;
    #1 $display("clock0 %b", q);
    j = 0;
    #1 k = 0;
    #1 $display("jk00 %b", q);
    preset = 1;
    #1 $display("pc11 %b", q);
    clock = 1;
    #1 $display("r00 %b", q);
    clock = 0;
    #1 $display("f %b", q);
    k = 1;
    #1 $display("k1 %b", q);
    clock = 1;
    #1 $display("r01 %b", q);
    clock = 0;
    #1 j = 1;
    #1 $display("j1 %b", q);
    clock = 1;
    #1 $display("r11 %b", q);
    clock = 0;
    #1 $display("f %b", q);
    clock = 1;
    #1 $display("r11 %b", q);
    clock = 0;
    #1 k = 0;
    #1 $display("k0 %b", q);
    clock = 1;
    #1 $display("r10 %b", q);
    clear = 0;
    #1 $display("pc10 %b", q);
    clear = 1;
    #1 $display("pc11 %b", q);
    clock = 0;
    #1 $display("f %b", q);
    clock = 1;
    #1 $display("r10 %b", q);
    $finish(0);
  end
endmodule
