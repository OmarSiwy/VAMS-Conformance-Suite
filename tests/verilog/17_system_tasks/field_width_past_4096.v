// IEEE 1364-2005 §17.1.1.2: "The format specifications in Table 17-3 are used
// with real numbers and have the full formatting capabilities available in the
// C language", and §17.1.1.3 lets a field width override the automatic size.
// Neither bounds a width or a precision. VerA refused one past 4096 (E1011)
// until 2026-10 (#29): it pads without a buffer and sizes a real's buffer by
// its precision.
//
// HAND DERIVATION. Each line is bracketed so its padding is visible.
//   %4097d of 1: 4096 spaces, then "1".
//   %10000h of 8'hab: "ab" right-justified in 10000 columns, 9998 spaces.
//   %.4097f of 0.5 (exact in binary): "0.5" and 4096 zeros.
//   %5000.3f of 0.25: "0.250", 5 characters, behind 4995 spaces.
//! inherited IEEE 1364-2005 17.1.1.2 17.1.1.3
//! expect stdout field_width_past_4096.expected.txt
module b_17_1_1_2_field_width_past_4096;
  integer x;
  reg [7:0] h;
  initial begin
    x = 1;
    h = 8'hab;
    $display("[%4097d]", x);
    $display("[%10000h]", h);
    $display("[%.4097f]", 0.5);
    $display("[%5000.3f]", 0.25);
  end
endmodule
