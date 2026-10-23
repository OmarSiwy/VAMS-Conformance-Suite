// IEEE1364-2005 3.5.1/Syntax3-1: decimal permits a single x/z/? digit
// followed by underscores. The state fills every specified bit; s changes
// signed interpretation, not the bit pattern. Base/digit case is irrelevant.
//! lrm 2.6.1
//! lrm 2.6.1:21
//! inherited IEEE 1364-2005 3.5.1
//! expect stdout lexical_decimal_unknown.expected.txt
module audit_lexical_decimal_unknown;
  initial begin
    $display("x %b", 12'D X__);
    $display("z %b", 12'dz_);
    $display("question %b", 12'sd?);
    $finish(0);
  end
endmodule
