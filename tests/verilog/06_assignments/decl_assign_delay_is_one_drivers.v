// IEEE 1364-2005 §6.1.3: a delay written on a net declaration that carries
// an assignment belongs to that continuous assignment and is not a net
// delay, so it is not added to the net's other drivers; a net delay
// (`wire #3 nn;` and separate assigns) delays a change from any driver
// (§7.14). (#71: VerA elaborated `wire #3 w = a;` as a net delay, which
// also delayed w's second driver.)
//
// Three 1-bit wires, each with the same two drivers:
//   d1 = a, delayed 3:  w by its declaration, ca by `assign #3`, nn by the
//                       net's own delay (its assign has none);
//   d2 = en ? b : z, no delay of its own.
// ca is the separate spelling §6.1.3 says w means, so w and ca agree.
// Stimulus: a=1, en=0, b=0 at t=0; en=1 at 10; en=0 at 20; a=0 at 30.
//   t=5   d1 = 1, d2 = z                   -> w=1 ca=1 nn=1
//   t=10  d2 drives 0 against d1's 1: x. w, ca at once; nn at 13
//         t=11 w=x ca=x nn=1    t=14 w=x ca=x nn=x
//   t=20  d2 back to z: 1. w, ca at once; nn at 23
//         t=21 w=1 ca=1 nn=x    t=24 w=1 ca=1 nn=1
//   t=30  a=0: d1 is delayed 3 on every spelling, so all three move at 33
//         t=32 w=1 ca=1 nn=1    t=34 w=0 ca=0 nn=0
// The bug (the declaration's delay on the net) prints w as nn: t=11 w=1 and
// t=21 w=x.
//! inherited IEEE 1364-2005 6.1.3 7.14
`timescale 1ns/1ns
module b_6_1_3_decl_assign_delay_is_one_drivers;
  reg a, en, b;
  wire #3 w = a;
  assign w = en ? b : 1'bz;
  wire ca;
  assign #3 ca = a;
  assign ca = en ? b : 1'bz;
  wire #3 nn;
  assign nn = a;
  assign nn = en ? b : 1'bz;
  initial begin
    a = 1'b1; en = 1'b0; b = 1'b0;
    #5 $display("t5 w=%b ca=%b nn=%b", w, ca, nn);
    #5 en = 1'b1;
    #1 $display("t11 w=%b ca=%b nn=%b", w, ca, nn);
    #3 $display("t14 w=%b ca=%b nn=%b", w, ca, nn);
    #6 en = 1'b0;
    #1 $display("t21 w=%b ca=%b nn=%b", w, ca, nn);
    #3 $display("t24 w=%b ca=%b nn=%b", w, ca, nn);
    #6 a = 1'b0;
    #2 $display("t32 w=%b ca=%b nn=%b", w, ca, nn);
    #2 $display("t34 w=%b ca=%b nn=%b", w, ca, nn);
    $finish(0);
  end
endmodule
