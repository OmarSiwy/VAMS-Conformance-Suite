// IEEE1364-2005 17.2.9 p296 and1.2(a) p2: invalid radix digits
// require an error even beyond the destination word's retained low bits.
//! inherited IEEE 1364-2005 17.2.9
//! reject the memory file has a malformed data word
module audit_readmem_invalid_high_binary_rejected;
  reg [7:0] mem[0:0];
  initial $readmemb("audit_readmem_invalid_high_binary.txt",mem);
endmodule
