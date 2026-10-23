// IEEE1364-2005 17.2.9, with3.5/3.5.1 and1.2(a) as applicable.
// Valid hexadecimal2^64 is outside task range0..0 and therefore requires error and terminated load.
// Error phrase/CLI exit are local harness contracts, not portable wording.
//! inherited IEEE 1364-2005 17.2.9
//! reject E1100
module audit_readmem_edge_address_overflow_rejected;
  reg [7:0] mem[0:0];
  initial $readmemh("audit_readmem_edge_address_overflow.txt",mem,0,0);
endmodule
