// IEEE 1364-2005 §10.4.1: "The keyword automatic declares an automatic
// function that is reentrant, with all the function declarations allocated
// dynamically for each concurrent function call." §10.4.4's factorial example
// is an automatic function calling itself. A call that never stops recursing
// has no value to return. VerA runs a design on a stack reserved for it
// (recursion_past_1024.v nests 5001 calls) and refuses the call that
// exhausts it with a named E1100, not a crash.
// f(n) calls f(n + 1) with no base case.
//! inherited IEEE 1364-2005 10.4.1 10.4.3 10.4.4
//! reject E1100
//! reject nesting here exhausts the
//! neighbour recursion_past_1024.v
module b_10_4_recursion_without_end_rejected;
  function automatic integer f(input integer n);
    f = f(n + 1);
  endfunction
  initial $display("%0d", f(0));
endmodule
