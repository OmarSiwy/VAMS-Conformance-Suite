// IEEE1364-2005 17.2.9, with3.5/3.5.1 and1.2(a) as applicable.
// 17.2.9 explicitly forbids whitespace between @ and its hexadecimal number.
// Error phrase/CLI exit are local harness contracts, not portable wording.
//! inherited IEEE 1364-2005 17.2.9
//! reject the memory file has a malformed `@` address
module audit_readmem_edge_address_gap_rejected;
  reg [7:0] mem[0:0];
  initial $readmemh("audit_readmem_edge_address_gap.txt",mem,0,0);
endmodule
