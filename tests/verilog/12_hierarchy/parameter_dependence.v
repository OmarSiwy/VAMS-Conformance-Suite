// IEEE 1364-2005 §12.2.3, p. 173: "overriding a parameter, whether by a defparam
// statement or in a module instantiation statement, effectively replaces the
// parameter definition with the new expression. Because memory_size depends on
// the value of word_size, a modification of word_size changes the value of
// memory_size." ... "If memory_size is updated due to either a defparam or an
// instantiation statement, then it will take on that value, regardless of the
// value of word_size."
//
// The clause's declaration, memory_size = word_size * 4096:
//   d0 (no override)             -> 32, 32 * 4096 = 131072
//   d1 #(.word_size(2))          -> 2,  8192
//   d2 #(.memory_size(5))        -> 32, 5 (word_size no longer matters)
//   d3 with defparam word_size=3 -> 3,  12288
//   d4 #(4) (ordered, first)     -> 4,  16384
//! lrm 6.3.2
//! lrm 6.3.2:2
//! lrm 6.3.4
//! lrm 6.3.4:1000
//! inherited IEEE 1364-2005 12.2.3
module mem_params;
  parameter
    word_size = 32,
    memory_size = word_size * 4096;
endmodule
module b_12_2_3_parameter_dependence;
  mem_params d0();
  mem_params #(.word_size(2)) d1();
  mem_params #(.memory_size(5)) d2();
  mem_params d3();
  defparam d3.word_size = 3;
  mem_params #(4) d4();
  initial begin
    $display("%0d %0d", d0.word_size, d0.memory_size);
    $display("%0d %0d", d1.word_size, d1.memory_size);
    $display("%0d %0d", d2.word_size, d2.memory_size);
    $display("%0d %0d", d3.word_size, d3.memory_size);
    $display("%0d %0d", d4.word_size, d4.memory_size);
  end
endmodule
