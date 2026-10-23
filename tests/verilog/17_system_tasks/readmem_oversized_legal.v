// IEEE1364-2005 17.2.9 file digits and inherited assignment truncation:
// discarded valid high digits do not make a file number malformed.
// Both words have retained low8bits=00010001, or hexadecimal11.
//! inherited IEEE 1364-2005 17.2.9
module audit_readmem_oversized_legal;
  reg [7:0] h[0:0],b[0:0];
  initial begin
    $readmemh("readmem_oversized_legal.hex",h);
    $readmemb("readmem_oversized_legal.bin",b);
    $display("%h,%h",h[0],b[0]);
  end
endmodule
