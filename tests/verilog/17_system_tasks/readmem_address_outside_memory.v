// IEEE 1364-2005 §17.2.9: "When addressing information is specified both in
// the system task and in the data file, the addresses in the data file shall
// be within the address range specified by the system task arguments;
// otherwise, an error message is issued, and the load operation is
// terminated." The rule needs task bounds. With none, a file address outside
// the declared memory matches no rule; VerA's reading (specification/Vague_Decisions.md
// VD-040) is the clause's nearest sibling, a warning: W1156 names the
// address, its words are skipped, and loading goes on at the next in-range
// address.
//
// HAND DERIVATION. mem[0:3], no bounds, so loading starts at 0. The file:
//   11 22   -> mem[0] = 11, mem[1] = 22
//   @8      -> outside 0..3: W1156
//   33 44   -> addresses 8 and 9: skipped
//   @2      -> back inside
//   55      -> mem[2] = 55
// mem[3] is never written and keeps its initial x (%h prints xx).
//
// Invalid neighbour: the same file address with task bounds is the clause's
// error, readmem_address_range_rejected.v.
//! inherited IEEE 1364-2005 17.2.9
module b_17_2_9_readmem_address_outside_memory;
  reg [7:0] mem[0:3];
  initial begin
    $readmemh("readmem_address_outside_memory.hex", mem);
    $display("%h %h %h %h", mem[0], mem[1], mem[2], mem[3]);
  end
endmodule
