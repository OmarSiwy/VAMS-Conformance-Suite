// IEEE1364-2005 17.1.1.2/.7: numeric argument contains packed8-bit ASCII.
// Leading zeros omitted, no trailing terminator needed: 00414243 -> ABC.
// Numeric literal isolates %s from unsupported string-valued expressions.
//! inherited IEEE 1364-2005 17.1.1.2 17.1.1.7
//! expect stdout display_packed_ascii.expected.txt
module audit_display_packed_ascii;
  initial begin
    $display("string=[%s]", 32'h00414243);
    $display("upper=[%S]", 24'h444546);
    $display("char=[%c][%C]", 8'h5a, 8'h21);
    $finish(0);
  end
endmodule
