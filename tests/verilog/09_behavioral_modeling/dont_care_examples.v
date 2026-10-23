// IEEE 1364-2005 §9.5.1, pp. 128-129: "Do-not-care values (z values for casez,
// z and x values for casex) in any bit of either the case expression or the
// case items shall be treated as do-not-care conditions during the comparison,
// and that bit position shall not be considered." ... "The syntax of literal
// numbers allows the use of the question mark (?) in place of z in these case
// statements."
// Example 2 (p. 129): "In this case, if r = 8'b01100110, then the task stat2 is
// called."
//
// Example 1: ir = 8'b00010110, casez items 8'b1???????, 8'b01??????,
//   8'b00010???, 8'b000001??. Bit 7 is 0 (item 1 fails), bit 6 is 0 (item 2
//   fails), bits 7..3 = 00010 match item 3 -> "instruction3".
// Example 2: r ^ mask = 01100110 ^ x0x0x0x0 = x1x0x1x0. casex ignores bits
//   7, 5, 3, 1 (x in the expression) and any x in an item:
//     8'b001100xx: bit 6 is 1 in r^mask, 0 in the item -> fails
//     8'b1100xx00: bit 6 1=1, bit 4 0=0, bit 2 is x in the item, bit 0 0=0
//                  -> matches -> "stat2"
// casez (4'b1z0z) against 4'b1101: the z bits 2 and 0 of the case expression
//   are not considered; bit 3 1=1, bit 1 0=0 -> "expr-z"
//! inherited IEEE 1364-2005 9.5.1
module b_9_5_1_dont_care_examples;
  reg [7:0] ir, r, mask;

  initial begin
    ir = 8'b00010110;
    casez (ir)
      8'b1???????: $display("instruction1");
      8'b01??????: $display("instruction2");
      8'b00010???: $display("instruction3");
      8'b000001??: $display("instruction4");
    endcase
    r = 8'b01100110;
    mask = 8'bx0x0x0x0;
    casex (r ^ mask)
      8'b001100xx: $display("stat1");
      8'b1100xx00: $display("stat2");
      8'b00xx0011: $display("stat3");
      8'bxx010100: $display("stat4");
    endcase
    casez (4'b1z0z)
      4'b1101: $display("expr-z");
      default: $display("BAD");
    endcase
    $finish(0);
  end
endmodule
