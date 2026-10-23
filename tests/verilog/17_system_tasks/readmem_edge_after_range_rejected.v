// IEEE1364-2005 17.2.9, with3.5/3.5.1 and1.2(a) as applicable.
// 17.2.9 constrains the entire file content; reaching the last destination does not legalize punctuation.
// Error phrase/CLI exit are local harness contracts, not portable wording.
//! inherited IEEE 1364-2005 17.2.9
//! reject the memory file has a malformed data word
module audit_readmem_edge_after_range_rejected;
  reg [7:0] mem[0:0];
  initial $readmemh("audit_readmem_edge_after_range.txt",mem,0,0);
endmodule
