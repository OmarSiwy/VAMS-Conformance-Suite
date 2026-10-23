// IEEE 1364-2005 §4.8.2: "Individual bits that are x or z in the net or the
// variable shall be treated as zero upon conversion." An unsized based
// constant with an x or z digit (§3.5.1) assigned to a real converts as
// any integral value does; its x/z fill is a matter of integral context,
// and a real is not one.
//
//   r = 'bx: every bit is x, so 0                      -> "0"
//   r = 'b1z: bit 1 is 1 and bit 0 is z (read as 0): 2  -> "2"
//! inherited IEEE 1364-2005 4.8.2
module b_4_8_2_unsized_unknown_literal_to_real;
  real r;

  initial begin
    r = 'bx;
    $display("%g", r);
    r = 'b1z;
    $display("%g", r);
  end
endmodule
