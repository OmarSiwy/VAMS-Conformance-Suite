//! inherited IEEE 1364-2005 4.8.2
// A real/integer conversion rounds to the nearest integer for any width; 2**63
// fits a 64-bit reg and 2**64 a 65-bit reg (pr2913404).
module triage_real_integer_conversion_widths;
  reg [63:0] u64;
  reg [64:0] u65;
  real r;
  reg fail;

  initial begin
    fail = 0;
    r = 2.0**63;
    u64 = r;
    if (u64 !== 64'h8000_0000_0000_0000) fail = 1;
    u65 = r;
    if (u65 !== 65'h8000_0000_0000_0000) fail = 1;
    r = 2.0**64;
    u65 = r;
    if (u65 !== 65'd18446744073709551616) fail = 1;
    if (fail) $display("FAILED"); else $display("PASSED");
  end
endmodule
