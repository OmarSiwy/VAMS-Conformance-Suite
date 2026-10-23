// IEEE1364-2005 17.2.9 permits binary/hex numbers with source-number
// semantics;3.5 Syntax3-1 defines ? as z_digit, and3.5.1 makes ? a z alias.
// Fully occupied 8-bit words avoid any left-padding ambiguity.
//! inherited IEEE 1364-2005 17.2.9
module audit_readmem_question_z;
  reg [7:0] h[0:0],b[0:0];
  initial begin
    $readmemh("readmem_question_z.hex",h);
    $readmemb("readmem_question_z.bin",b);
    $display("hex=%b binary=%b",h[0],b[0]);
  end
endmodule
