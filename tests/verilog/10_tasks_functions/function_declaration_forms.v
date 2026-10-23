// IEEE 1364-2005 §10.4.1, p. 153: "The use of a function_range_or_type shall
// be optional. A function specified without a function_range_or_type defaults
// to a scalar for the return value. If used, function_range_or_type shall
// specify that the return value of the function is a real, an integer, a
// time, a realtime, or a vector (optionally signed) with a range of [n:m]
// bits." p. 154: "Function inputs shall be declared one of two ways. The first
// method shall have the name of the function followed by a semicolon. After
// the semicolon, one or more input declarations optionally mixed with block
// item declarations shall follow." ... "The second method shall have the name
// of the function, followed by an open parenthesis and one or more input
// declarations, separated by commas."
//
// getbyte (the clause's example, both forms): low byte of the 16-bit address.
//   getbyte1(16'h12AB) = getbyte2(16'h12AB) = ab       -> "ab ab"
// Return types (real and realtime are real_function_return.v):
//   scalar(4'b0110): no range -> 1-bit return; 4'b0110 truncates to its LSB 0.
//     scalar(4'b0111) -> 1.                           -> "0 1"
//   int_f(-3) returns integer -3 (32-bit signed)      -> "-3"
//   time_f(1) returns time 64'd1 << 40 = 1099511627776, which a 64-bit time
//     holds and a 32-bit integer would not          -> "1099511627776"
//   signed_f(16'hFFFE) returns signed [3:0] of the low nibble 4'b1110 = -2;
//     %0d of a signed 4-bit -2 prints "-2"            -> "-2"
//   auto_f(5) (automatic, second form, a block item declaration) = 5 + 1 = 6
//                                                     -> "6"
//! inherited IEEE 1364-2005 10.4.1
module b_10_4_1_function_declaration_forms;
  function [7:0] getbyte1;
    input [15:0] address;
    getbyte1 = address[7:0];
  endfunction

  function [7:0] getbyte2 (input [15:0] address);
    getbyte2 = address[7:0];
  endfunction

  function scalar;
    input [3:0] v;
    scalar = v;
  endfunction

  function integer int_f;
    input integer v;
    int_f = v;
  endfunction

  function time time_f;
    input integer v;
    time_f = 64'd1 << (40 * v);
  endfunction

  function signed [3:0] signed_f (input [15:0] v);
    signed_f = v[3:0];
  endfunction

  function automatic integer auto_f (input integer v);
    integer one;
    begin
      one = 1;
      auto_f = v + one;
    end
  endfunction

  initial begin
    $display("%h %h", getbyte1(16'h12AB), getbyte2(16'h12AB));
    $display("%b %b", scalar(4'b0110), scalar(4'b0111));
    $display("%0d", int_f(-3));
    $display("%0d", time_f(1));
    $display("%0d", signed_f(16'hFFFE));
    $display("%0d", auto_f(5));
    $finish(0);
  end
endmodule
