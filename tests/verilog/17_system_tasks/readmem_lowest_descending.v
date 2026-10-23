// IEEE1364-2005 §17.2.9, printed296: without explicit task addresses,
// loading begins at the LOWEST address, not the left declaration index.
// Both memories must map file words11,22,33,44 to indices4,5,6,7.
//! inherited IEEE 1364-2005 17.2.9
//! data audit_readmem_four.hex
module audit_readmem_lowest_descending;
  reg [7:0] descending [7:4];
  reg [7:0] ascending [4:7];
  initial begin
    $readmemh("audit_readmem_four.hex", descending);
    $readmemh("audit_readmem_four.hex", ascending);
    $display("descending=%h,%h,%h,%h", descending[4], descending[5], descending[6], descending[7]);
    $display("ascending=%h,%h,%h,%h", ascending[4], ascending[5], ascending[6], ascending[7]);
    $finish(0);
  end
endmodule
