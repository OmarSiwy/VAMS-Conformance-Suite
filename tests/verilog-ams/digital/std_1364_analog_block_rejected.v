// Under --std=1364-2005 the language is IEEE 1364-2005, whose annex A has no
// `analog_construct`. LRM 10.6 lets a `begin_keywords "1364-2005" region of
// a Verilog-AMS source keep Verilog-AMS semantics ("The directives do not
// affect the semantics"), but a 1364 tool has none to keep. The analog block
// is refused by name (E0242), not left to fail as a stray identifier.
//@ std 1364-2005
//! lrm 10.6
//! reject E0242
module std_1364_analog_block_rejected;
  real x;
  analog begin
    x = 1.0;
  end
endmodule
