// IEEE1364-2005 17.2.9 p296: Each readmemb data number shall be binary; digit2 is not binary.
// IEEE1.2(a) p2 requires an error when input violates a shall requirement.
// The exact VerA phrase and nonzero CLI exit are harness-specific contracts,
// not standard-mandated wording or a portable simulation-termination oracle.
//! inherited IEEE 1364-2005 17.2.9
//! reject the memory file has a malformed data word
module audit_readmem_malformed_binary_digit_rejected;
  reg [7:0] mem[0:0];
  initial $readmemb("audit_readmem_invalid_binary_digit.txt",mem);
endmodule
