// IEEE1364-2005 17.2.9 p296: The input shall contain only permitted data, whitespace, comments or address directives.
// IEEE1.2(a) p2 requires an error when input violates a shall requirement.
// The exact VerA phrase and nonzero CLI exit are harness-specific contracts,
// not standard-mandated wording or a portable simulation-termination oracle.
//! inherited IEEE 1364-2005 17.2.9
//! reject the memory file has a malformed data word
module audit_readmem_malformed_punctuation_rejected;
  reg [7:0] mem[0:0];
  initial $readmemh("audit_readmem_invalid_punctuation.txt",mem);
endmodule
