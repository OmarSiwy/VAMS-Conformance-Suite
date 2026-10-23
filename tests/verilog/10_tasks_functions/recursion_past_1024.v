// IEEE 1364-2005 §10.4.2 lets an automatic function call itself and bounds
// nothing about the depth. VerA refused a call nested past 1024 activations
// or 4 MiB of stack (E1100) until 2026-10 (#29); both engines now run the
// design on a stack reserved for it, as deep as that stack allows.
//
// HAND DERIVATION. f(n) = 1 + f(n - 1) and f(0) = 0, so f(n) = n. f(5000)
// nests 5001 activations, past the old 1024, and prints 5000.
//! inherited IEEE 1364-2005 10.4.2
//! expect stdout recursion_past_1024.expected.txt
module b_10_4_recursion_past_1024;
  function automatic integer f(input integer n);
    begin
      if (n == 0) f = 0; else f = 1 + f(n - 1);
    end
  endfunction
  initial $display("%0d", f(5000));
endmodule
