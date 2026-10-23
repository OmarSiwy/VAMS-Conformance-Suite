// IEEE 1364-2005 A.8.2, p. 504:
//   function_call ::= hierarchical_function_identifier{ attribute_instance }
//     ( expression { , expression } )
// A user function call has parentheses holding at least one expression; only
// a system_function_call may omit its argument list.
//
// `f()` calls a function with an empty argument list. Legal neighbour:
// b_A_8_2_function_calls.v (`add3(1, 2, 3)`, and `$time` for the system
// function without parentheses).
//! inherited IEEE 1364-2005 A.8.2
//! reject E1100
//! reject `f` takes 1 arguments, not 0
//! neighbour b_A_8_2_function_calls.v
module b_A_8_2_empty_function_call_rejected;
  function integer f(input integer a);
    f = a;
  endfunction
  initial $display("%0d", f());
endmodule
