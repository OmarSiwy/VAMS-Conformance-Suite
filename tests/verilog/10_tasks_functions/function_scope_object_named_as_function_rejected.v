// IEEE 1364-2005 §10.4.2, p. 154: "Inside a function, there is an implied
// variable with the name of the function, which may be used in expressions
// within the function. It is, therefore, also illegal to declare another
// object with the same name as the function inside the function scope."
//
// Inside f, `reg f;` redeclares the implied return variable. Legal neighbour:
// function_declaration_forms.v, whose functions assign their implied
// variable without redeclaring it.
//! inherited IEEE 1364-2005 10.4.2
//! reject E1100
//! reject duplicate digital variable
//! neighbour function_declaration_forms.v
module b_10_4_2_function_scope_object_named_as_function_rejected;
  reg x;
  function f;
    input a;
    reg f;
    f = a;
  endfunction
  initial x = f(1'b1);
endmodule
