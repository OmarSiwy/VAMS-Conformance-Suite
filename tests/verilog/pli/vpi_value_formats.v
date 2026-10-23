// The 4-bit reg is `nibble`: it was `small`, which IEEE 1364-2005 Annex B
// reserves (the §4.4.1 charge strength, A.2.2.2), so the design was illegal.
module audit_vpi_value_formats;
  reg [34:0] wide;
  reg [3:0] nibble;
  real realvar;
  initial #10 $finish(0);
endmodule
