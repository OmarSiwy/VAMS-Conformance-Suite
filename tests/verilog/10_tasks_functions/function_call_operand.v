// IEEE 1364-2005 §10.4.3, p. 155: "A function call is an operand within an
// expression." ... "The order of evaluation of the arguments to a function
// call is undefined." "The following example creates a word by concatenating
// the results of two calls to the function getbyte (defined in 10.4.1):
//   word = control ? {getbyte(msbyte), getbyte(lsbyte)}:0;"
//
// getbyte returns the low byte of its 16-bit argument; it touches no state, so
// the undefined argument order cannot change a result.
//   msbyte = 16'h12AB, lsbyte = 16'h34CD:
//   control = 1: {ab, cd} = 16'habcd                  -> "abcd"
//   control = 0: 0                                    -> "0000"
//   As operands of + and of a two-argument call:
//   getbyte(16'h0010) + getbyte(16'h0020) = 8'h10 + 8'h20 = 8'h30, in a
//   16-bit context -> 16'h0030; add(getbyte(16'h0102), 8'h03) = 02 + 03 = 05
//                                                      -> "0030 05"
//! inherited IEEE 1364-2005 10.4.3
module b_10_4_3_function_call_operand;
  reg [15:0] msbyte, lsbyte, word, sum;
  reg control;

  function [7:0] getbyte (input [15:0] address);
    getbyte = address[7:0];
  endfunction

  function [7:0] add (input [7:0] a, input [7:0] b);
    add = a + b;
  endfunction

  initial begin
    msbyte = 16'h12AB;
    lsbyte = 16'h34CD;
    control = 1;
    word = control ? {getbyte(msbyte), getbyte(lsbyte)} : 0;
    $display("%h", word);
    control = 0;
    word = control ? {getbyte(msbyte), getbyte(lsbyte)} : 0;
    $display("%h", word);
    sum = getbyte(16'h0010) + getbyte(16'h0020);
    $display("%h %h", sum, add(getbyte(16'h0102), 8'h03));
    $finish(0);
  end
endmodule
