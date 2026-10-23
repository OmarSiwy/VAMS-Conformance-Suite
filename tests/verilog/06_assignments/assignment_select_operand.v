// Verilog-AMS LRM 2.4 §8.5.3.1 Continuous assignment:
//   "A continuous assignment statement (6.1 of IEEE Std 1364 Verilog)
//    corresponds to a process, sensitive to the source elements in the
//    expression."
//
// A constant bit- or part-select (IEEE 1364-2005 §5.2.1) names bits of its
// vector, and its value changes only when one of those bits does; a
// variable index reads whichever bit it names, so any bit may matter.
// Each check below changes some bits of a vector and reads every select of
// it: those whose bits changed follow, the others hold. `w` is 100 bits, so
// selects in both of its 64-bit halves are read. `star` is an `@*` block
// (§9.7.5) over the same kind of operands.
//
//! lrm 8.5.3.1
//! lrm 8.5.3.1:1000
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 5.2.1 6.1.2 9.7.5
//
// Hand derivation (lo = w[3], hi = w[70], mid = w[67:64], nb = n[5],
// vi = w[k], star = w[70] ^ n[0]):
//   t1 w = 0, n = 0, k = 70        -> lo 0, hi 0, mid 0000, nb 0, vi 0, star 0
//   t2 w[70] = 1                   -> hi 1, vi 1, star 1; the rest hold
//   t3 w[65] = 1, w[3] = 1         -> mid 0010, lo 1; hi, vi, star hold at 1
//   t4 n[5] = 1, n[0] = 1          -> nb 1, star 1 ^ 1 = 0
//   t5 w[3] = x, w[70] = 0         -> lo x, hi 0, vi 0, star 0 ^ 1 = 1
//   t6 w[99] = 1, n[7] = 1, k = 3  -> no select of bit 99 or bit 7: all hold,
//                                     except vi = w[3] = x
`timescale 1ns/1ns
module select_operand;
  reg [99:0] w;
  reg [7:0] n;
  integer k;
  wire lo = w[3];
  wire hi = w[70];
  wire [3:0] mid = w[67:64];
  wire nb = n[5];
  wire vi = w[k];
  reg star;
  always @* star = w[70] ^ n[0];
  initial begin
    w = 0; n = 0; k = 70;
    #1 $display("t1 lo=%b hi=%b mid=%b nb=%b vi=%b star=%b", lo, hi, mid, nb, vi, star);
    w[70] = 1;
    #1 $display("t2 lo=%b hi=%b mid=%b nb=%b vi=%b star=%b", lo, hi, mid, nb, vi, star);
    w[65] = 1; w[3] = 1;
    #1 $display("t3 lo=%b hi=%b mid=%b nb=%b vi=%b star=%b", lo, hi, mid, nb, vi, star);
    n[5] = 1; n[0] = 1;
    #1 $display("t4 lo=%b hi=%b mid=%b nb=%b vi=%b star=%b", lo, hi, mid, nb, vi, star);
    w[3] = 1'bx; w[70] = 0;
    #1 $display("t5 lo=%b hi=%b mid=%b nb=%b vi=%b star=%b", lo, hi, mid, nb, vi, star);
    w[99] = 1; n[7] = 1; k = 3;
    #1 $display("t6 lo=%b hi=%b mid=%b nb=%b vi=%b star=%b", lo, hi, mid, nb, vi, star);
    $finish(0);
  end
endmodule
