// IEEE 1364-2005 §10.4.1, p. 154: "A function shall have at least one input
// declared." §10.4.4, p. 155: "c) A function definition shall contain at
// least one input argument."
//
// f declares a block item (reg a) and no input. It is never called, so the
// refusal can only come from the declaration. Legal neighbour:
// function_declaration_forms.v, where every function declares an
// input.
//! inherited IEEE 1364-2005 10.4.1 10.4.4
//! reject E1100
//! reject input
//! neighbour function_declaration_forms.v
module b_10_4_1_function_without_input_rejected;
  reg x;
  function f;
    reg a;
    f = 1'b1;
  endfunction
  initial begin
    x = 1'b0;
    $display("%b", x);
  end
endmodule
