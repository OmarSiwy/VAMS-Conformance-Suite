// IEEE 1364-2005 §7.14.1, p. 102: "The syntax for delays on gate primitives
// (including UDPs; see Clause 8), nets, and continuous assignments shall allow
// three values each for the rising, falling, and turn-off delays. The minimum,
// typical, and maximum values for each delay shall be specified as expressions
// separated by colons. There shall be no required relation (e.g., min <= typ
// <= max) between the expressions for minimum, typical, and maximum delays.
// These can be any three expressions."
//
// A gate, a net and a continuous assignment each carry the unordered triple
// 5:3:1 as their rise delay. Which member a tool selects is not fixed by the
// clause, so each measured rise delay must be 1, 3 or 5:
//   a rises at t=20; each output's first change after t=20 is at 20 + d,
//   d in {1, 3, 5} -> ok=1 for all three.
// The bufif1 carries three triples (rise, fall, turn-off), each unordered.
// Line: "ok=1 ok=1 ok=1 ok=1".
//! lrm A.2.2.3
//! lrm A.2.2.3:1000
//! inherited IEEE 1364-2005 7.14.1
`timescale 1ns/1ns
module b_7_14_1_unordered_delay_triples;
  reg a, en;
  wire og, oa, ob;
  wire #(5:3:1) on;
  buf #(5:3:1) g(og, a);
  assign on = a;
  assign #(5:3:1) oa = a;
  bufif1 #(5:3:1, 6:4:2, 9:8:7) b(ob, a, en);
  time dg, dn, da, db;
  initial begin
    a = 0; en = 1; dg = 0; dn = 0; da = 0; db = 0;
    #20 a = 1;
    fork
      begin @(og) dg = $time - 20; end
      begin @(on) dn = $time - 20; end
      begin @(oa) da = $time - 20; end
      begin @(ob) db = $time - 20; end
    join
    $display("ok=%b ok=%b ok=%b ok=%b", dg == 1 || dg == 3 || dg == 5,
      dn == 1 || dn == 3 || dn == 5, da == 1 || da == 3 || da == 5,
      db == 5 || db == 3 || db == 1);
    $finish(0);
  end
endmodule
