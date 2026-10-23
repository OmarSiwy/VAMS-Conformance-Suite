// IEEE1364-2005 17.2.9, with3.5/3.5.1 and1.2(a) as applicable.
// 3.5.1 forbids underscore as first character of a number.
// Error phrase/CLI exit are local harness contracts, not portable wording.
//! inherited IEEE 1364-2005 17.2.9
//! reject the memory file has a malformed data word
module audit_readmem_edge_underscore_leading_rejected;
  reg [7:0] mem[0:0];
  initial $readmemh("audit_readmem_edge_underscore_leading.txt",mem);
endmodule
