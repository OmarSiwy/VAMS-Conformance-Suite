// IEEE 1364-2005 §3.7.4, p. 15: "The compiler behavior dictated by a compiler
// directive shall take effect as soon as the compiler reads the directive."
// With §19.3.1, p. 351: "Once a text macro name has been defined, it can be
// used anywhere in a source description", and §19.3.2, p. 352: "An undefined
// text macro has no value, just as if it had never been defined."
//
// `W is used on a line read before its `define, when no macro W is in
// effect. Legal neighbour: directive_takes_effect_when_read.v, which
// uses `W after its `define.
//! inherited IEEE 1364-2005 3.7.4
//! reject E0115
//! reject undefined macro
//! neighbour directive_takes_effect_when_read.v
module b_3_7_4_macro_before_define_rejected;
  initial $display("%0d", `W);
`define W 8
endmodule
