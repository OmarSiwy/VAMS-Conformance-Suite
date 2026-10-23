// IEEE 1364-2005 §4.11, p. 39-40: "The local name spaces are block, module,
// generate block, port, specify block, and attribute." "The generate block
// name space is introduced by generate constructs (see 12.4). It unifies the
// definition of functions, tasks, named blocks, module instances, generate
// blocks, local parameters, named events, genvars, net type of declaration,
// and variable type of declaration."
//
// x is declared in the module (reg [3:0] x = 1) and in the generate block g
// (wire [3:0] x = 3): two spaces, two objects. The module's process reads
// x = 1 at t=1; g's own process, a module_or_generate_item of g, resolves x
// in g's space and reads 3 at t=2 (§12.7, p. 196: "If it is declared
// locally, then the local item shall be used").
// Output: "1" then "g 3".
//! inherited IEEE 1364-2005 4.11
`timescale 1ns/1ns
module b_4_11_generate_block_name_space;
  reg [3:0] x;
  generate
    if (1) begin : g
      wire [3:0] x = 3;
      initial #2 $display("g %0d", x);
    end
  endgenerate
  initial begin
    x = 1;
    #1 $display("%0d", x);
    #2 $finish(0);
  end
endmodule
