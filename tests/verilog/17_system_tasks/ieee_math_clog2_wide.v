// IEEE1364-2005 17.11.1 permits arbitrary-width vectors, not just64bits.
// 65-bit1 shifted64 is2^64: ceiling log2=64. Adding1 crosses the exact
// power boundary so result65. A129-bit operand with only bit128 set gives128.
// All values are known, and explicitly wide operands avoid unsized-shift traps.
//! lrm 9.14
//! lrm 9.14:1
//! inherited IEEE 1364-2005 17.11.1
module audit_ieee_math_clog2_wide;
  reg [64:0] wide;
  reg [128:0] wider;
  initial begin
    wide = 65'd1 << 64;
    wider = 129'd1 << 128;
    $display("wide %0d", $clog2(wide));
    wide = wide + 65'd1;
    $display("next %0d wider %0d", $clog2(wide), $clog2(wider));
    $finish(0);
  end
endmodule
