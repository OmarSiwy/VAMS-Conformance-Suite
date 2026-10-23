// IEEE1364-2005 17.2.9: addresses are hexadecimal numbers. Leading
// zeros do not increase the represented address or create arithmetic overflow.
// Address000...A is index10, safely inside task range10..10.
//! inherited IEEE 1364-2005 17.2.9
module audit_readmem_address_zero_padding;
  reg [7:0] mem[10:10];
  initial begin
    $readmemh("readmem_address_zero_padding.hex",mem,10,10);
    $display("%h",mem[10]);
  end
endmodule
