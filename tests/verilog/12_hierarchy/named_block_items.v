// IEEE 1364-2005 §12.5, p. 191: "Inside any module, each module instance
// (including an arrayed instance), generate block instance, task definition,
// function definition, and named begin-end or fork-join block shall define a
// new branch of the hierarchy." p. 193, Example 2: "The next example shows how
// a pair of named blocks can refer to items declared within each other." ...
// "fork :mod_1 reg x; mod_2.x = 1; join fork :mod_2 reg x; mod_1.x = 0;
// join". Figure 12-2 (p. 193) lists wave.a.amod.keep.hold, the reg declared in
// the named block keep.
//
//   t=1: keep (a named block with its own reg hold) sets hold = 1; the parent
//        reads <top>.m.keep.hold = 1.
//   t=2: block mod_1 sets mod_2.x = 1, then block mod_2 sets mod_1.x = 0 (the
//        two forks run in sequence inside one begin-end); the parent reads
//        <top>.b.mod_1.x = 0 and <top>.b.mod_2.x = 1.
//   -> "1" then "0 1"
//! inherited IEEE 1364-2005 12.5
`timescale 1ns/1ns
module m;
  initial begin : keep
    reg hold;
    hold = 1;
  end
endmodule
module b_12_5_named_block_items;
  m mi();
  initial begin : b
    #2;
    fork :mod_1
      reg x;
      mod_2.x = 1;
    join
    fork :mod_2
      reg x;
      mod_1.x = 0;
    join
  end
  initial begin
    #1 $display("%b", mi.keep.hold);
    #2 $display("%b %b", b.mod_1.x, b.mod_2.x);
  end
endmodule
