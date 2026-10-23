// IEEE 1364-2005 §5.1.13, p. 54: "The evaluation of a conditional operator
// shall begin with a logical equality comparison (see 5.1.8) of expression1
// with zero, termed the condition. If the condition evaluates to false (0),
// then expression3 shall be evaluated and used as the result of the
// conditional expression. If the condition evaluates to true (1), then
// expression2 is evaluated and used as the result. If the condition evaluates
// to an ambiguous value (x or z), then both expression2 and expression3 shall
// be evaluated; and their results shall be combined, bit by bit, using Table
// 5-21 to calculate the final result unless expression2 or expression3 is
// real, in which case the result shall be 0. If the lengths of expression2 and
// expression3 are different, the shorter operand shall be lengthened to match
// the longer and zero-filled from the left (the high-order end)."
//
// Condition by == 0:  4'b1x00: bit 3 is 1, so 4'b1x00 == 0 is 0: true ->
//   expression2 4'b1010.  4'b0x00: == 0 is ambiguous -> merge.
// Table 5-21, bit by bit (0/0 -> 0, 1/1 -> 1, anything else -> x):
//   x ? 4'b0011 : 4'b0101 -> MSB first: (0,0)=0 (0,1)=x (1,0)=x (1,1)=1
//                            -> 0xx1
//   4'b0x00 ? 4'b1100 : 4'b1010 -> (1,1)=1 (1,0)=x (0,1)=x (0,0)=0 -> 1xx0
//   z ? 4'b1100 : 4'b1100 -> 1100
//   x ? 2'b11 : 4'b1111: 2'b11 zero-filled to 0011; merged with 1111 ->
//                        (0,1)=x (0,1)=x (1,1)=1 (1,1)=1 -> xx11
//   x ? 1.5 : 2.5 -> real operand: 0 (printed %f: 0.000000)
// The clause's bus example, wire [15:0] busa = drive_busa ? data : 16'bz,
// data = 16'h00ff:
//   drive_busa = 1 -> 00ff;  0 -> zzzz;
//   x -> each bit merges data with z: (0,z) = x, (1,z) = x -> xxxx
//! inherited IEEE 1364-2005 5.1.13
module b_5_1_13_conditional_ambiguous;
  reg drive_busa;
  reg [15:0] data;
  wire [15:0] busa = drive_busa ? data : 16'bz;
  initial begin
    $display("%b %b", 4'b1x00 ? 4'b1010 : 4'b0101, 1'bx ? 4'b0011 : 4'b0101);
    $display("%b %b %b", 4'b0x00 ? 4'b1100 : 4'b1010, 1'bz ? 4'b1100 : 4'b1100, 1'bx ? 2'b11 : 4'b1111);
    $display("%f", 1'bx ? 1.5 : 2.5);
    data = 16'h00ff;
    drive_busa = 1;
    #1 $display("%h", busa);
    drive_busa = 0;
    #1 $display("%h", busa);
    drive_busa = 1'bx;
    #1 $display("%h", busa);
    $finish(0);
  end
endmodule
