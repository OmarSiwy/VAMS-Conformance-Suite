// A.2.6 `function_range_or_type ::= [ signed ] [ range ] | integer | real
// | realtime | time`, and A.8.2 `function_call` as an operand of an expression.
//
// A function's declared range is a real width boundary, not a hint: the body
// assigns to the implicit variable named by the function, so the result is
// truncated to that width, and only THEN does the call site's context extend it.
// VerA already implements exactly this layering for expressions — the digital
// executor's documented rule is "a first pass infers natural widths and
// signedness; evaluation then propagates the enclosing context" — so the risk
// here is that a function call is wired up as a plain substitution and the
// caller's 8-bit context leaks inward, which would lose the truncation.
//
// HAND DERIVATION — `tw` is 4 bits wide, `r` is 8.
//   tw(4'd3):   x = 0011; x + x = 6; 6 < 16 so no truncation; result 0110 = 6
//   tw(4'd10):  x = 1010; x + x = 20; 20 mod 16 = 4;          result 0100 = 4
//   r = 6 + 4 = 10, widened to eight bits -> 00001010
//   -> "fn 00001010"
//
// A caller-width leak computes 3+3 = 6 and 10+10 = 20 at eight bits, giving
// 6 + 20 = 26 = 00011010.
// Truncating the SUM instead of each call gives 10 either way here, which is why
// the two arguments are chosen so that exactly one of them overflows four bits:
// the discriminating digit is the one contributed by tw(4'd10).
//
//! lrm A.2.6
//! lrm A.8.2
//! lrm 1.1
//! lrm A.2.6:1000
//! inherited IEEE 1364-2005 10.4.2
module d04_function_return_width_is_the_boundary;
  reg [7:0] r;

  function [3:0] tw(input [3:0] x);
    begin
      tw = x + x;
    end
  endfunction

  initial begin
    r = tw(4'd3) + tw(4'd10);
    $display("fn %b", r);
    $finish(0);
  end
endmodule
