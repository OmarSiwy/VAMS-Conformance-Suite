// IEEE 1364-2005 §7.1.1, p. 76: "A gate or switch instance declaration shall
// begin with the keyword that specifies the gate or switch primitive being
// used by the instances that follow in the declaration. Table 7-1 lists the
// keywords that shall begin a gate or a switch instance declaration."
// §3.7.2, p. 15: "All keywords are defined in lowercase only."
//
// `AND` is not a Table 7-1 keyword (keywords are lowercase), so this is not a
// gate declaration. `AND g1(o, a, b);` is still well-formed as a module
// instantiation, so the refusal is module resolution finding no module
// `AND` in this compilation: indirect evidence that only the Table 7-1
// lowercase keywords declare a primitive.
// Legal neighbour: `and` in every_primitive.v.
//! inherited IEEE 1364-2005 7.1.1
//! reject E1100
//! reject undeclared module in instantiation
//! neighbour every_primitive.v
module b_7_1_1_unknown_gate_keyword_rejected;
  reg a, b;
  wire o;
  AND g1(o, a, b);
  initial $finish(0);
endmodule
