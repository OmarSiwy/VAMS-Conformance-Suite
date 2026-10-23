// IEEE 1364-2005 §4.10.1, p. 36-37: "A parameter with a signed type specification
// and with a range specification shall be signed and shall be the range of
// its declaration." The clause's example: "parameter signed [3:0]
// mux_selector = 0;".
//
// sneg = 4'b1111 and sm1 = -1, each signed [3:0]: both hold 1111, which as a
// signed 4-bit value is -1, so %0d prints -1 and (sneg < 0) is 1 (§5.5.1:
// both operands signed, so the compare is signed). ls, a localparam of the same
// declaration (§4.10.2: "identical to parameters"), likewise.
// Output: "-1 -1 -1 1 1".
//! inherited IEEE 1364-2005 4.10.1
module b_4_10_1_signed_ranged_parameter;
  parameter signed [3:0] sneg = 4'b1111;
  parameter signed [3:0] sm1 = -1;
  localparam signed [3:0] ls = 4'b1111;
  initial begin
    $display("%0d %0d %0d %b %b", sneg, sm1, ls, sneg < 0, sm1 < 0);
    $finish(0);
  end
endmodule
