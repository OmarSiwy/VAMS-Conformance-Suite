// IEEE 1364-2005 §3.8, p. 16: "Nesting of attribute instances is disallowed.
// It shall be illegal to specify the value of an attribute with a constant
// expression that contains an attribute instance."
//
// The value of a is 1 + (* b *) 2, a constant expression holding the
// attribute instance (* b *) (legal on its own as a suffix to +). Legal
// neighbour: examples.v, whose b + (* mode = "cla" *) c is not
// inside another attribute.
//! inherited IEEE 1364-2005 3.8
//! reject E0357
//! reject the value contains an attribute instance
//! neighbour examples.v
module b_3_8_nested_attribute_rejected;
  (* a = 1 + (* b *) 2 *) reg r;
  initial $display("unreachable");
endmodule
