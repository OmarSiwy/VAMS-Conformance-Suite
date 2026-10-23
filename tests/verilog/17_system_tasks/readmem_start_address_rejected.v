// IEEE 1364-2005 17.2.9, printed297: file addresses must be inside the
// task-requested range. Start-only3 implies3..3, so @2 is outside even though
// it is inside the declared memory. This is an error, not a count warning.
//! inherited IEEE 1364-2005 17.2.9
//! reject E1157
//! reject is outside the load range [3:3] the task gives
module audit_readmem_start_address_rejected;
  reg [7:0] mem[3:0];
  initial $readmemb("audit_readmem_formfeed_address.bin",mem,3);
endmodule
