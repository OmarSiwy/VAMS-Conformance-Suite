// IEEE 1364-2005 §7.1.4, p. 77: "An optional name can be given to a gate or
// switch instance. If multiple instances are declared as an array of
// instances, an identifier shall be used to name the instances."
// Syntax 7-1: name_of_gate_instance ::= gate_instance_identifier [ range ],
// so a range cannot appear without the identifier.
//
// A range with no instance name. Legal neighbour: the named array arr[1:0]
// in optional_instance_name.v.
//! inherited IEEE 1364-2005 7.1.4
//! reject E0207
//! reject unexpected token: found `[`
//! neighbour optional_instance_name.v
module b_7_1_4_unnamed_array_rejected;
  reg [3:0] a, b;
  wire [3:0] o;
  and [3:0] (o, a, b);
  initial $finish(0);
endmodule
