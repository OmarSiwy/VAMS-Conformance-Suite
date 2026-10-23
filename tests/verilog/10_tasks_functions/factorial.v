// IEEE 1364-2005 §10.4.4, p. 155: "Functions are more limited than tasks. The
// following rules govern their usage: a) A function definition shall not
// contain any time-controlled statements, that is, any statements containing
// #, @, or wait. b) Functions shall not enable tasks. c) A function definition
// shall contain at least one input argument. d) A function definition shall
// not have any argument declared as output or inout. e) A function shall not
// have any nonblocking assignments or procedural continuous assignments. f) A
// function shall not have any event triggers." "This example defines a
// function called factorial that returns an integer value. The factorial
// function is called iteratively and the results are printed."
//
// The clause's tryfact, verbatim but for the module name and $finish(0): a
// function obeying every rule a) to f), automatic so it recurses.
// factorial(n) = n * factorial(n - 1) for n >= 2, else 1. The results the
// clause prints (p. 156):
//   0! = 1, 1! = 1, 2! = 2, 3! = 6, 4! = 24, 5! = 120, 6! = 720, 7! = 5040.
//! inherited IEEE 1364-2005 10.4.4
module b_10_4_4_factorial;
  // define the function
  function automatic integer factorial;
    input [31:0] operand;
    integer i;
    if (operand >= 2)
      factorial = factorial (operand - 1) * operand;
    else
      factorial = 1;
  endfunction
  // test the function
  integer result;
  integer n;
  initial begin
    for (n = 0; n <= 7; n = n+1) begin
      result = factorial(n);
      $display("%0d factorial=%0d", n, result);
    end
    $finish(0);
  end
endmodule
