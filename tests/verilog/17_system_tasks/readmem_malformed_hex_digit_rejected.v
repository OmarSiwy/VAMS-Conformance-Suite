// IEEE1364-2005 17.2.9 p296: Each readmemh data number shall be hexadecimal; g is not a hex digit.
// IEEE1.2(a) p2 requires an error when input violates a shall requirement.
// The exact VerA phrase and nonzero CLI exit are harness-specific contracts,
// not standard-mandated wording or a portable simulation-termination oracle.
//! inherited IEEE 1364-2005 17.2.9
//! reject the memory file has a malformed data word
module audit_readmem_malformed_hex_digit_rejected;
  reg [7:0] mem[0:0];
  initial $readmemh("audit_readmem_invalid_hex_digit.txt",mem);
endmodule
