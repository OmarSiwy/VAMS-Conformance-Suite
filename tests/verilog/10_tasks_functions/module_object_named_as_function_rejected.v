// IEEE 1364-2005 §10.4.2, p. 154: "It is illegal to declare another object
// with the same name as the function in the scope where the function is
// declared."
//
// The module declares reg f and the function f in the same scope. Legal
// neighbour: function_declaration_forms.v, whose function names are
// not otherwise declared.
//! inherited IEEE 1364-2005 10.4.2
//! reject E1100
//! reject duplicate
//! neighbour function_declaration_forms.v
module b_10_4_2_module_object_named_as_function_rejected;
  reg x;
  reg f;
  function f;
    input a;
    f = a;
  endfunction
  initial x = f(1'b1);
endmodule
