// IEEE 1364-2005 §5.2.1, pp. 56-57: "If the bit-select is out of the address
// bounds or the bit-select is x or z, then the value returned by the
// reference shall be x." ... "A constant part-select of a vector reg or net
// is given with the following syntax: vect[msb_expr:lsb_expr]" ... "The
// actual bit that is accessed by an address is, in part, determined by the
// declaration of acc."
//
// The clause's Example 2 (p. 57), reg [7:0] vect = 4 = 0000_0100:
//   vect[addr], addr = 2 -> 1;  addr = 9 (out of bounds) -> x;
//   addr = 0, 1, 3..7 -> 0 (printed as one 7-bit string, addr 0,1,3,4,5,6,7);
//   vect[3:0] -> 0100;  vect[5:1] -> 00010;
//   vect[addr] with addr = 4'bxxxx -> x, with addr = 4'bzzzz -> x;
//   addr with one x bit (4'b00x1) -> x ("If any bit of addr is x or z, then
//   the value of addr is x.").
// Example 1's point (p. 57): the same index names different bits under
// reg [15:0] acc and reg [2:17] acc2 given the same value 16'h0001:
//   acc[15] is the MSB -> 0; acc2[17] is the LSB -> 1; acc2[2] the MSB -> 0.
// Out-of-bounds indices are variables, not constants, so NOTE 2 (p. 57: such
// constant indices "may be flagged as a compile time error") does not apply.
//! inherited IEEE 1364-2005 5.2.1
module b_5_2_1_bit_part_select_addressing;
  reg [7:0] vect;
  reg [15:0] acc;
  reg [2:17] acc2;
  reg [3:0] addr;
  integer k;
  initial begin
    vect = 4;
    addr = 2;
    $display("%b", vect[addr]);
    addr = 9;
    $display("%b", vect[addr]);
    for (k = 0; k < 8; k = k + 1)
      if (k != 2) $write("%b", vect[k]);
    $display("");
    $display("%b %b", vect[3:0], vect[5:1]);
    addr = 4'bxxxx;
    $write("%b", vect[addr]);
    addr = 4'bzzzz;
    $write("%b", vect[addr]);
    addr = 4'b00x1;
    $display("%b", vect[addr]);
    acc = 16'h0001;
    acc2 = 16'h0001;
    $display("%b %b %b", acc[15], acc2[17], acc2[2]);
    $finish(0);
  end
endmodule
