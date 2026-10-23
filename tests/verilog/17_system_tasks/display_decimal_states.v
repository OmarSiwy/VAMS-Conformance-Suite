// IEEE1364-2005 17.1.1.3/.4: unsigned12-bit decimal field is4 columns.
// All x/z -> lowercase; mixed x -> X; mixed z -> Z unless x also occurs.
// %0d removes width, not state classification. %D is the same format.
//! inherited IEEE 1364-2005 17.1.1.3 17.1.1.4
//! expect stdout display_decimal_states.expected.txt
module audit_display_decimal_states;
  initial begin
    $display("all-x [%d][%0d]", 12'bx, 12'bx);
    $display("all-z [%d][%0d]", 12'bz, 12'bz);
    $display("mixed-x [%d][%0d]", 12'b00000000000x, 12'b00000000000x);
    $display("mixed-z [%D][%0d]", 12'b00000000000z, 12'b00000000000z);
    $display("both [%d][%0d]", 12'b0000000000xz, 12'b0000000000xz);
    $finish(0);
  end
endmodule
