// IEEE 1364-2005 §5.1.13: a known condition evaluates only its selected
// arm; an x/z condition evaluates both arms and returns zero if either
// arm is real. This zero rule also applies when both real arms are equal.
// Each function call adds one to calls, independently of operand order.
// Results are 1.25/1 call, 9.5/2 calls, then zero/4 and zero/6 calls.
// The constant expression with equal real arms must use the same rule.
// This operator has no prohibited input; no rejection is invented.
//! inherited IEEE 1364-2005 5.1.13 10.4.1
// native-required
module native_real_conditionals;
  reg choice;
  integer calls;
  real result;
  function real hit(input real value);
    begin calls = calls + 1; hit = value; end
  endfunction
  initial begin
    calls = 0; choice = 1;
    result = choice ? hit(1.25) : hit(9.5);
    $display("true %.2f %0d", result, calls);
    choice = 0; result = choice ? hit(1.25) : hit(9.5);
    $display("false %.2f %0d", result, calls);
    choice = 1'bx; result = choice ? hit(1.25) : hit(9.5);
    $display("x %.2f %0d", result, calls);
    choice = 1'bz; result = choice ? hit(1.25) : hit(1.25);
    $display("z-equal %.2f %0d", result, calls);
    $display("constant %.2f", 1'bx ? 1.25 : 1.25);
    $finish(0);
  end
endmodule
