// IEEE 1364-2005 §17.2.9: @ preserves the task's direction and excludes
// count-mismatch warnings, including an @ after the range was filled.
// Initial four words fill indices 3,2,1,0; @2 then replaces indices 2,1.
// Absence of W1150 is independently asserted by focused executor tests.
//! inherited IEEE 1364-2005 17.2.9
module audit_readmem_address_restart;
  reg [7:0] mem[3:0];
  initial begin
    $readmemh("audit_readmem_restart.hex",mem,3,0);
    $display("restart=%h,%h,%h,%h",mem[0],mem[1],mem[2],mem[3]);
  end
endmodule
