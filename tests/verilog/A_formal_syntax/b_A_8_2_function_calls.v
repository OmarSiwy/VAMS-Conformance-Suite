// IEEE 1364-2005 A.8.2, p. 504:
//   constant_function_call ::= function_identifier { attribute_instance }
//     ( constant_expression { , constant_expression } )
//   constant_system_function_call ::= system_function_identifier
//     ( constant_expression { , constant_expression } )
//   function_call ::= hierarchical_function_identifier{ attribute_instance }
//     ( expression { , expression } )
//   system_function_call ::= system_function_identifier [ ( expression { , expression } ) ]
//
//   W = clog(9), a constant_function_call in a parameter (§10.4.5): the
//     loop doubles k from 1 while k < 9 (1, 2, 4, 8): 4.
//   S = $clog2(9), a constant_system_function_call. Clause 5, p. 41 (quoted
//     for context): "the system functions allowed in constant expressions are
//     the conversion system functions listed in 17.8 and the mathematical
//     system functions listed in 17.11"; §17.11.1, p. 323: "The system
//     function $clog2 shall return the ceiling of the log base 2 of the
//     argument": 4.
//   add3(1, 2, 3), a function_call with three arguments: 6.
//   $time, a system_function_call without parentheses: 0 at t0.
//   $unsigned(v), one with parentheses, v = -2 (4-bit signed): 14.
// Output: "W=4 S=4 add3=6 t=0 u=14".
//! inherited IEEE 1364-2005 A.8.2
module b_A_8_2_function_calls;
  function integer clog(input integer n);
    integer k;
    begin
      clog = 0;
      for (k = 1; k < n; k = k * 2) clog = clog + 1;
    end
  endfunction
  function integer add3(input integer a, input integer b, input integer c);
    add3 = a + b + c;
  endfunction
  localparam W = clog(9);
  localparam S = $clog2(9);
  reg signed [3:0] v;
  initial begin
    v = -2;
    $display("W=%0d S=%0d add3=%0d t=%0d u=%0d", W, S, add3(1, 2, 3), $time, $unsigned(v));
    $finish(0);
  end
endmodule
