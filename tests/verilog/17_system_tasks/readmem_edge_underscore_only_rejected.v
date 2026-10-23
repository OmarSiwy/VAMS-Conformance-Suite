// IEEE1364-2005 17.2.9, with3.5/3.5.1 and1.2(a) as applicable.
// An underscore alone is not a binary/hex value; Syntax3-1 requires a first digit.
// Error phrase/CLI exit are local harness contracts, not portable wording.
//! inherited IEEE 1364-2005 17.2.9
//! reject the memory file has a malformed data word
module audit_readmem_edge_underscore_only_rejected;
  reg [7:0] mem[0:0];
  initial $readmemh("audit_readmem_edge_underscore_only.txt",mem);
endmodule
