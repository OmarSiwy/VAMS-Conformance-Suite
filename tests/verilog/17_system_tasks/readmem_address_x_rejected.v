// IEEE 1364-2005 §17.2.9: a file address is "an at character (@) followed by
// a hexadecimal number". The clause lets data words use x, z and `_` "as in a
// Verilog HDL source description" and says nothing of addresses. VerA's
// reading (specification/Vague_Decisions.md VD-041): an address names one word, and an
// x address names none, so `@x` is a malformed address and the load stops.
// Legal neighbour: readmem_address_underscore.v (`@1_`, `@0_0_`).
//! inherited IEEE 1364-2005 17.2.9
//! reject E1100
//! reject the memory file has a malformed `@` address
//! neighbour readmem_address_underscore.v
module b_17_2_9_readmem_address_x_rejected;
  reg [7:0] mem[0:1];
  initial $readmemh("b_17_2_9_readmem_address_x.txt", mem);
endmodule
