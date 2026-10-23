// IEEE 1364-2005 §28.2: "Tools that process the Verilog HDL shall perform
// envelope decryption for all decryption envelopes contained in the source
// text, where the proper key is supplied by the user." §19.10 lets a tool
// ignore a pragma_name it does not recognize, but §28.1 says the protect
// pragma "is reserved by this standard for the description of protected
// envelopes".
//
// VerA does not decrypt (clause 28 is out of scope, CLAUSES.tsv).
// Treating the directive as an unknown pragma would hand the data_block's
// ciphertext below to the parser as Verilog, so the first `pragma protect is
// refused by name (E0146). The envelope is §28.2.1's rot13 example, cut down:
// "ert o;" is "reg b;".
//
// Legal neighbour: 19_compiler_directives/pragma_unrecognized_no_effect.v.
//! inherited IEEE 1364-2005 28 28.1 28.2 28.2.2 28.3 28.4.3 28.4.4 28.4.9 28.4.11 28.4.12 28.4.15
//! reject E0146
module protect_decryption_envelope_rejected;
`pragma protect encoding=(enctype="raw")
`pragma protect data_method="x-caesar", data_keyname="rot13", begin_protected
`pragma protect data_block encoding=(enctype="raw", bytes=6)
ert o;
`pragma protect end_protected
endmodule
