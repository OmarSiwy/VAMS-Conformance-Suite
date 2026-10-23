// IEEE 1364-2005 A.9.1, p. 507:
//   attribute_instance ::= (* attr_spec { , attr_spec } *)
//   attr_spec ::= attr_name [ = constant_expression ]
//   attr_name ::= identifier
// An attribute's name is an identifier; a number is not one.
//
// `(* 1 = 2 *)` names its attribute with the number 1. Legal neighbour:
// b_A_9_1_attributes.v (`(* keep = 1, note = "w" *)`).
//! inherited IEEE 1364-2005 A.9.1
//! reject E0208
//! reject expected an identifier: found 1
//! neighbour b_A_9_1_attributes.v
module b_A_9_1_attribute_name_not_identifier_rejected;
  (* 1 = 2 *) wire w;
  initial $display("unreachable");
endmodule
