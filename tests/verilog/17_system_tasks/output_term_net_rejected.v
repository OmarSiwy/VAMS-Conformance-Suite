// IEEE 1364-2005 §17.5, p. 303: "The input terms can be nets or variables
// whereas the output terms shall only be variables." Syntax 17-13:
//   output_terms ::= variable_lvalue
//
// o is a wire, a net, so it cannot be the task's output term. Legal
// neighbour: pla_async_personality.v, whose output terms are regs.
//! inherited IEEE 1364-2005 17.5
//! reject E1100
//! reject there is no procedural assignment to a net
//! neighbour pla_async_personality.v
`timescale 1 ns / 1 ns
module b_17_5_output_term_net_rejected;
  reg [1:2] mem [1:1];
  reg [1:2] in;
  wire o;
  initial begin
    mem[1] = 2'b11;
    in = 2'b11;
    $async$and$array(mem, in, o);
  end
endmodule
