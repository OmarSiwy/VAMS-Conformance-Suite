// IEEE 1364-2005 §17.2.9: a file address is "an at character (@) followed by
// a hexadecimal number". §3.5.1: "The underscore character (_) shall be legal
// anywhere in a number except as the first character." VerA's reading
// (specification/Vague_Decisions.md VD-041): an address is such a number, so `_` is
// legal after its first digit, the last position included.
//
// HAND DERIVATION. mem[0:1], no bounds. The file:
//   @1_    -> address 1 (the trailing `_` is ignored)
//   33     -> mem[1] = 33
//   @0_0_  -> address 0
//   11     -> mem[0] = 11
// so "11 33". The file has addresses, so no W1150 count warning.
//
// Invalid neighbour: an x digit names no word, readmem_address_x_rejected.v;
// a leading `_`, readmem_edge_underscore_leading_rejected.v covers the
// data-word form of the same §3.5.1 rule.
//! inherited IEEE 1364-2005 17.2.9
//! inherited IEEE 1364-2005 3.5.1
module b_17_2_9_readmem_address_underscore;
  reg [7:0] mem[0:1];
  initial begin
    $readmemh("readmem_address_underscore.hex", mem);
    $display("%h %h", mem[0], mem[1]);
  end
endmodule
