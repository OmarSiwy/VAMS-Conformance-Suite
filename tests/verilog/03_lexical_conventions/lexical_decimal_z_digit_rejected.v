// IEEE3.5.1: INVALID decimal z followed by another digit.
// Neighbor is audit_lexical_decimal_unknown's legal12'dz_.
//! inherited IEEE 1364-2005 3.5.1
//! reject E0133
//! reject invalid number literal
module audit_lexical_decimal_z_digit_rejected;
  reg [11:0] value;
  initial begin value = 12'dz1; $finish(0); end
endmodule
