// Conditional host profile: known_keys.json supplies public test keys,
// CBC IV and padding. A decrypting host must bind that profile before
// this is a complete decryption test. Current VerA rejects the protect
// directive first (E0146); no key/IV command-line spelling is invented.
//! inherited IEEE 1364-2005 28.4.16 28.4.16.1 28.4.16.2 28.4.17 28.4.17.1 28.4.17.2 28.4.18 28.4.18.1 28.4.18.2 28.4.21 28.4.21.1 28.4.21.2 28.4.22 28.4.22.1 28.4.22.2
`define PROTECTED_VALUE 42
module protected_sha1_digest;
`pragma protect begin_protected
`pragma protect data_keyowner="VerAConformance"
`pragma protect data_keyname="des-fixture"
`pragma protect data_method="des-cbc"
`pragma protect digest_keyowner="VerAConformance"
`pragma protect digest_keyname="digest-fixture"
`pragma protect digest_key_method="des-cbc"
`pragma protect digest_method="sha1"
`pragma protect encoding=(enctype="base64",line_length=64,bytes=80)
`pragma protect data_block
gHbCKL32373t8sEGvD15nckvxrVeIl860S8eWw2QhIG1ZVCMR+++LjLuTsN2m/dY
N3sNtdQRLWi/uhem7bk4Jp0vCWN1q5BIQ0GHXjC9v7s=
`pragma protect encoding=(enctype="base64",line_length=64,bytes=24)
`pragma protect digest_block
2GS25RIIHnVZQDObhi6ZWVZcBOacpjWZ
`pragma protect end_protected
endmodule
