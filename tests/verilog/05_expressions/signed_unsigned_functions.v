// IEEE 1364-2005 §5.5, pp. 64-65: "two system functions shall be used to
// handle type casting on expressions: $signed() and $unsigned(). These
// functions shall evaluate the input expression and return a value with the
// same size and value of the input expression and the type defined by the
// function: $signed - returned value is signed $unsigned - returned value is
// unsigned"
//
// The clause's example, reg [7:0] regA, regB; reg signed [7:0] regS:
//   regA = $unsigned(-4): -4 is a 32-bit signed decimal; $unsigned keeps the
//     bits, 32'hFFFFFFFC; truncated to 8 -> 11111100
//   regB = $unsigned(-4'sd4): -4'sd4 is 4 bits, 1100; $unsigned makes it
//     unsigned, so it zero-extends -> 00001100
//   regS = $signed(4'b1100): 4-bit signed 1100 = -4, sign-extended -> -4
// Same size: {$signed(4'b1100)} is 4 bits (concatenation is self-determined),
//   so {1'b1, $signed(4'b1100)} -> 11100.
//! inherited IEEE 1364-2005 5.5
module b_5_5_signed_unsigned_functions;
  reg [7:0] regA, regB;
  reg signed [7:0] regS;
  initial begin
    regA = $unsigned(-4);
    regB = $unsigned(-4'sd4);
    regS = $signed(4'b1100);
    $display("%b %b %0d %b", regA, regB, regS, {1'b1, $signed(4'b1100)});
    $finish(0);
  end
endmodule
