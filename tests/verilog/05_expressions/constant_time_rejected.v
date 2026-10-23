// IEEE 1364-2005 §5, p. 41: "The system functions that may be used in
// constant system function calls are pure functions, i.e., those whose value
// depends only on their input arguments and which have no side effects.
// Specifically, the system functions allowed in constant expressions are the
// conversion system functions listed in 17.8 and the mathematical system
// functions listed in 17.11."
//
// $time (§17.7.1) is neither a conversion nor a mathematical function, and a
// parameter's value is a constant expression (§4.10.1), so the declaration
// below is illegal. Legal neighbour: constant_operands.v uses $clog2
// (§17.11) and $rtoi (§17.8) in the same position.
//! inherited IEEE 1364-2005 5
//! reject E1100
//! reject a constant expression is required here
//! neighbour constant_operands.v
module b_5_constant_time_rejected;
  parameter P = $time;
  initial $display("%0d", P);
endmodule
