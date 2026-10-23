// Verilog-AMS LRM 2.4 annex A.3.1 gives `bufif1` and annex A.2.2.1 the
// `wand`/`wor` net types; §1.1 makes IEEE Std 1364 clause 7 the resolution.
// IEEE 1364-2005 7.10.2: a signal "with a value H" has "strength levels that
// consist of high impedance joined with strength levels in the strength1
// part", and L likewise on the strength0 side; a bufif1 whose enable is x
// produces one (Figure 7-6). 7.10.4: "When ambiguous strength signals combine
// in wired logic, it is necessary to consider the results of all combinations
// of each of the strength levels in the first signal with each of the strength
// levels in the second signal". Each single-level pair follows 7.10.1 (unequal:
// "the stronger signal shall dominate") or, at equal strength, the table.
//
// A resolver that collapses H/L to x before the table prints x|0 = x, x|1 = 1
// and x&0 = 0 for the three x-enable columns; every one of those is wrong.
//
//! lrm annex A.3.1
//! lrm annex A.2.2.1
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 7.10.1 7.10.2 7.10.4
//
// HAND DERIVATION  Levels: Su = 7, St = 6, We = 3, HiZ = 0. The gates drive
// at the default (strong0, strong1).
//   o1 : wor,  bufif1(o1, 1, en) and an (supply1, supply0) assign of 0 (Su0)
//   o2 : wor,  bufif1(o2, 0, en) and a (weak1, weak0) assign of 1 (We1)
//   a1 : wand, bufif1(a1, 1, en) and a (weak1, weak0) assign of 0 (We0)
//
//   en=1  o1: St1 against Su0 -> Su0 dominates -> 0
//         o2: St0 dominates We1 -> 0
//         a1: St1 dominates We0 -> 1
//   en=0  every gate drives z, so each net is its assign: 0 1 0
//   en=x  o1: StH = HiZ .. St1. Every level of it is weaker than Su0 -> 0.
//         o2: StL = St0 .. HiZ against We1: St0, Pu0, La0 dominate (0 side);
//             We0 | We1 = We1; Me0, Sm0, HiZ lose to We1 (1 side).
//             The results span St0 .. We1 -> x.
//         a1: StH against We0: HiZ, Sm1, Me1 lose to We0; We1 & We0 = We0;
//             La1, Pu1, St1 dominate. Span We0 .. St1 -> x.

`timescale 1ns/1ns
module d03_wired_ambiguous_strength;
  reg en;
  wor o1, o2;
  wand a1;

  bufif1 g1(o1, 1'b1, en);
  bufif1 g2(o2, 1'b0, en);
  bufif1 g3(a1, 1'b1, en);
  assign (supply1, supply0) o1 = 1'b0;
  assign (weak1, weak0) o2 = 1'b1;
  assign (weak1, weak0) a1 = 1'b0;

  initial begin
    en = 1'b1;
    #1 $display("enabled %b %b %b", o1, o2, a1);
    en = 1'b0;
    #1 $display("disabled %b %b %b", o1, o2, a1);
    en = 1'bx;
    #1 $display("unknown %b %b %b", o1, o2, a1);
    $finish(0);
  end
endmodule
