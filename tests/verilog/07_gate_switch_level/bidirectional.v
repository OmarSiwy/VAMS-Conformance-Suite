// D08 — bidirectional pass switches: tran and tranif1.
//
// Verilog-AMS 2.4 Annex A.3.4:
//     pass_en_switchtype ::= tranif0 | tranif1 | rtranif1 | rtranif0
//     pass_switchtype    ::= tran | rtran
// Annex A.3.1:
//     | pass_en_switchtype [delay2] pass_enable_switch_instance { , ... } ;
//     | pass_switchtype pass_switch_instance { , ... } ;
//     pass_switch_instance ::= [ name_of_gate_instance ]
//         ( inout_terminal , inout_terminal )
//     pass_enable_switch_instance ::= [ name_of_gate_instance ]
//         ( inout_terminal , inout_terminal , enable_terminal )
// Both terminals are `inout_terminal ::= net_lvalue` (A.3.3) — neither is an
// output, which is the entire content of the word "bidirectional".
//
// §8.5.3.5 "Switch (transistor) processing" states the requirement this fixture
// tests, and is the clause VerA's parser currently cites while modelling
// nothing (lib/frontend/parser.zig `parsePassSwitch`, W0250):
//
//     "The event-driven simulation algorithm described in 11 of IEEE Std
//      1364-2005 Verilog HDL depends on unidirectional signal flow and can
//      process each event independently. ... Switches provide bi-directional
//      signal flow and require coordinated processing of nodes connected by
//      switches. ... Switch processing shall consider all the devices in a
//      bidirectional switch-connected net before it can determine the
//      appropriate value for any node on the net, because the inputs and
//      outputs interact."
//
// Today `tran (na, nb);` parses, warns W0250, and connects nothing. That makes
// every row below a live defect and not a hypothetical one: with the switch
// omitted, `nb` in row 2 reads z instead of 1.
//
// HAND DERIVATION.
//
// The `tran` half. Two tri-state drivers, one per side, and a `tran` joining
// the two nets into a single resolved node:
//
//   ea eb | drivers present on the joined node          | na  nb
//   0  0  | none: both bufif1 are off (highz)           | z   z
//   1  0  | one strong 1, contributed from the na side  | 1   1
//   0  1  | one strong 0, contributed from the nb side  | 0   0
//   1  1  | strong 1 and strong 0 on one node: equal    | x   x
//         | strength, opposite value, unresolvable      |
//
// Row 2 and row 3 are the bidirectionality assertion and they are deliberately
// opposite in direction: row 2 needs the value to travel left-to-right and row
// 3 right-to-left, so an implementation that quietly treats a `tran` as a
// one-way buffer fails exactly one of them. Row 4 is the "the inputs and
// outputs interact" clause: the conflict must be seen as ONE node, not as two
// nets each with one happy driver.
//
// The `tranif1` half. `nc` carries a permanent strong 1 from a `buf`; `nd` has
// no driver of its own and can only get a value through the switch.
//
//   gt=0 : switch off. nd is isolated and undriven.             -> nc=1 nd=z
//   gt=1 : switch on. The one node has one strong 1 driver.     -> nc=1 nd=1
//   gt=x : conduction unknown. nd is "1 or z", IEEE 1364's H symbol, which is
//          not a member of {0,1,x,z}; the sound four-state projection is x.
//          nc is unaffected either way: it holds its own strong 1 whether or
//          not the switch conducts, and nd can never contribute anything but
//          z back through it.                                   -> nc=1 nd=x
//
//! lrm A.3.1
//! lrm A.3.3
//! lrm A.3.4
//! lrm 8.5.3.5
//! lrm 8.5.3.5:1
//! lrm A.3.1:1000
//! lrm A.3.3:1000
//! lrm A.3.4:1000
//! inherited IEEE 1364-2005 7.6 11.6.5
// native-required
`timescale 1ns/1ns
module d08_bidirectional;
  reg da, db, ea, eb, gt;
  wire na, nb;
  wire nc, nd;

  bufif1 ba (na, da, ea);
  bufif1 bb (nb, db, eb);
  tran   t1 (na, nb);

  buf     bc (nc, 1'b1);
  tranif1 t2 (nc, nd, gt);

  initial begin
    da = 1'b1; db = 1'b0;
    ea = 1'b0; eb = 1'b0; #1
      $display("ea=0 eb=0 got na=%b nb=%b want z z", na, nb);
    ea = 1'b1; eb = 1'b0; #1
      $display("ea=1 da=1 eb=0 got na=%b nb=%b want 1 1", na, nb);
    ea = 1'b0; eb = 1'b1; #1
      $display("ea=0 eb=1 db=0 got na=%b nb=%b want 0 0", na, nb);
    ea = 1'b1; eb = 1'b1; #1
      $display("ea=1 da=1 eb=1 db=0 got na=%b nb=%b want x x", na, nb);

    gt = 1'b0; #1
      $display("gt=0 got nc=%b nd=%b want 1 z", nc, nd);
    gt = 1'b1; #1
      $display("gt=1 got nc=%b nd=%b want 1 1", nc, nd);
    gt = 1'bx; #1
      $display("gt=x got nc=%b nd=%b want 1 x", nc, nd);
  end
endmodule
