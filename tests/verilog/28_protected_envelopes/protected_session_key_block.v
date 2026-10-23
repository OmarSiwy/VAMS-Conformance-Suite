// Conditional host profile: known_keys.json supplies public test keys,
// CBC IV and padding. A decrypting host must bind that profile before
// this is a complete decryption test. Current VerA rejects the protect
// directive first (E0146); no key/IV command-line spelling is invented.
//! inherited IEEE 1364-2005 28.4.14 28.4.14.1 28.4.14.2 28.4.23 28.4.23.1 28.4.23.2 28.4.24 28.4.24.1 28.4.24.2 28.4.25 28.4.25.1 28.4.25.2 28.4.27 28.4.27.1 28.4.27.2
`define PROTECTED_VALUE 42
module protected_session_key_block;
`pragma protect begin_protected
`pragma protect key_keyowner="VerAConformance"
`pragma protect key_keyname="exchange-fixture"
`pragma protect key_method="des-cbc"
`pragma protect encoding=(enctype="base64",line_length=64,bytes=152)
`pragma protect key_block
HmR1lmmwZqix46pT213GCLJGD4OtmME9U7vcCpo4YqZvYw+xhz92F0XGsaoWCFUk
7XX/HumQ/bJdtzV3L+V4hQ3xGQyD7cLJLKoHdUxF8U7PIUJWgVCgCzSqfXu4TQP0
iLgc2dAxR7SLK1htwsLXI/uy0zMeDaVolUPGaRbW/+aWxd3Tf1ZtBGXIMDkIJ0xS
1x1P4iBpXX4=
`pragma protect encoding=(enctype="base64",line_length=64,bytes=80)
`pragma protect data_block
gHbCKL32373t8sEGvD15nckvxrVeIl860S8eWw2QhIG1ZVCMR+++LjLuTsN2m/dY
N3sNtdQRLWi/uhem7bk4Jp0vCWN1q5BIQ0GHXjC9v7s=
`pragma protect end_protected
endmodule
