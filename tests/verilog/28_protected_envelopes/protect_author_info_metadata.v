// This metadata has no decryption action. Outside an envelope it must not
// alter the surrounding unprotected program. This checks acceptance only,
// not encryption, key handling or preservation by an encryption service.
//! inherited IEEE 1364-2005 28.3 28.4.6.1
`pragma protect author_info="test metadata"
module protect_author_info_metadata;
  initial begin $display("visible=42"); $finish(0); end
endmodule
