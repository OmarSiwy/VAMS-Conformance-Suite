// IEEE1364-2005 3.5 Syntax3-1/3.5.1 and17.2.9: underscores after
// the initial digit are ignored, including repeated and trailing separators.
//! inherited IEEE 1364-2005 17.2.9
module audit_readmem_underscore_legal;
  reg [7:0] h[0:0],b[0:0];
  initial begin
    $readmemh("readmem_underscore_legal.hex",h);
    $readmemb("readmem_underscore_legal.bin",b);
    $display("%h,%h",h[0],b[0]);
  end
endmodule
