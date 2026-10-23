// IEEE 1364-2005 §4.7, p. 32: "Assignments to a reg are made by procedural
// assignments (see 6.2 and 9.2). Because the reg holds a value between
// assignments, it can be used to model hardware registers. Edge-sensitive
// (i.e., flip-flops) and level-sensitive (i.e., reset-set and transparent
// latches) storage elements can be modeled. A reg need not represent a
// hardware storage element because it can also be used to represent
// combinatorial logic."
//
// q: a flip-flop, always @(posedge clk) q <= d.
// l: a transparent latch, always @(en or d) if (en) l = d.
// c: combinatorial, always @(d) c = ~d.
//   t=1: d = 1, en = 1           t=2: q x (no edge yet), l follows d -> x 1
//   t=3: posedge clk, q <= 1     t=4: -> 1 1
//   t=5: clk = 0, en = 0         t=6: d = 0: l keeps 1, c = ~0 = 1
//   t=7: q holds 1 between assignments -> 1 1
//   t=8: posedge clk, q <= 0     t=9: -> 0 1 1
//! inherited IEEE 1364-2005 4.7
module b_4_7_reg_holds_between_assignments;
  reg clk, d, en;
  reg q, l, c;
  always @(posedge clk) q <= d;
  always @(en or d) if (en) l = d;
  always @(d) c = ~d;
  initial begin
    clk = 0;
    #1 d = 1; en = 1;
    #1 $display("%b %b", q, l);
    #1 clk = 1;
    #1 $display("%b %b", q, l);
    #1 clk = 0; en = 0;
    #1 d = 0;
    #1 $display("%b %b", q, l);
    #1 clk = 1;
    #1 $display("%b %b %b", q, l, c);
    $finish(0);
  end
endmodule
