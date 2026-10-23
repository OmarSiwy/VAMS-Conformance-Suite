//! inherited IEEE 1364-2005 17.1.1.3
// A field width like %04d is outside the clause's automatic sizing and its
// %0 override; VerA pads with spaces, not zeros (test_extended).
module triage_decimal_field_width_space_padded;
  initial $display("[%04d]", 7);
endmodule
