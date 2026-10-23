// IEEE 1364-2005 §17.5.3, p. 304: "The logic array personality is declared as
// an array of regs that is as wide as the number of input terms and as deep
// as the number of output terms." ... "reg [1:n] mem[1:m];" ... "As shown in
// the examples in 17.5, PLA input terms, output terms, and memory shall be
// specified in ascending order."
//
// mem's bit (input-term) range is [2:1], descending, where the clause's
// reg [1:n] is ascending. Legal neighbour: pla_async_personality.v,
// whose personality is reg [1:2] ... [1:1].
//! inherited IEEE 1364-2005 17.5.3
//! reject E1100
//! reject ascending
//! neighbour pla_async_personality.v
`timescale 1 ns / 1 ns
module b_17_5_3_descending_personality_rejected;
  reg [2:1] mem [1:1];
  reg [1:2] in;
  reg o;
  initial begin
    mem[1] = 2'b11;
    in = 2'b11;
    $sync$and$array(mem, in, o);
    $display("%b", o);
  end
endmodule
