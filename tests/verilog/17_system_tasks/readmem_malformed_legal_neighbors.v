// IEEE1364-2005 17.2.9 p296: no length/base prefix is needed.
// Legal hexadecimal11 and binary10 load decimal17 and2, respectively.
// These independently observable positives accompany malformed-input cases.
//! inherited IEEE 1364-2005 17.2.9
module audit_readmem_malformed_legal_neighbors;
  reg [7:0] hexword[0:0],binword[0:0];
  initial begin
    $readmemh("audit_readmem_legal_one.hex",hexword);
    $readmemb("audit_readmem_legal_one.bin",binword);
    $display("%h,%h",hexword[0],binword[0]);
  end
endmodule
