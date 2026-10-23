// IEEE 1364-2005 A.2.6, p. 492:
//   function_port_list ::= { attribute_instance } tf_input_declaration
//     { , { attribute_instance } tf_input_declaration }
//   function_item_declaration ::= block_item_declaration
//     | { attribute_instance } tf_input_declaration ;
// A function's ports are tf_input_declarations only; tf_output_declaration
// and tf_inout_declaration appear in A.2.7's task productions and nowhere in
// A.2.6.
//
// `function f(input a, output b);` puts an output in a function_port_list.
// Legal neighbour: b_A_2_6_function_declarations.v
// (`function signed [3:0] neg(input [3:0] v);`).
// VerA refuses it at elaboration (E1100), naming §10.4.4's rule.
//! inherited IEEE 1364-2005 A.2.6
//! reject E1100
//! reject a function argument is an input
//! neighbour b_A_2_6_function_declarations.v
module b_A_2_6_function_output_port_rejected;
  function f(input a, output b);
    f = a;
  endfunction
  initial $display("unreachable");
endmodule
