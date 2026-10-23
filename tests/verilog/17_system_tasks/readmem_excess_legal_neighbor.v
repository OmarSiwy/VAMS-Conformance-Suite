// IEEE1364-2005 17.2.9: two valid words for a one-word range require
// a warning, unlike malformed punctuation following the completed range.
//! inherited IEEE 1364-2005 17.2.9
module audit_readmem_excess_legal_neighbor;
  reg [7:0] mem[0:0];
  initial begin
    $readmemh("readmem_excess_legal_neighbor.hex",mem,0,0);
    $display("%h",mem[0]);
  end
endmodule
