// IEEE 1364-2005 §28.1: "An encryption envelope begins in the source text
// when a begin pragma expression is encountered. The end of the encryption
// envelope occurs at the point where an end pragma expression is
// encountered." §28.2.1: tools that provide encryption services "shall
// transform source text containing encryption envelopes by replacing each
// encryption envelope with a decryption envelope".
//
// The cleartext between the two directives is ordinary Verilog, so ignoring
// them would compile. It would also silently drop the author's request that
// the text be protected, and VerA does not implement clause 28
// (CLAUSES.tsv), so the first `pragma protect is refused by name (E0146).
//
// Legal neighbour: 19_compiler_directives/pragma_unrecognized_no_effect.v.
//! inherited IEEE 1364-2005 28.2.1 28.4.1 28.4.2
//! reject E0146
module protect_encryption_envelope_rejected;
  reg b;
`pragma protect data_method="x-caesar", data_keyname="rot13", begin
  initial b = 1'b0;
`pragma protect end
endmodule
