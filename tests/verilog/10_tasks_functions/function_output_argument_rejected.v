// IEEE 1364-2005 §10.4.4, p. 155: "d) A function definition shall not have any
// argument declared as output or inout." §10.1, p. 145: "A function shall have
// at least one input type argument and shall not have an output or inout type
// argument".
//
// f declares `output b`. Legal neighbour: factorial.v, whose
// function has one input and no other argument.
//! inherited IEEE 1364-2005 10.4.4 10.1
//! reject E1100
//! reject output
//! neighbour factorial.v
module b_10_4_4_function_output_argument_rejected;
  reg x;
  function f;
    input a;
    output b;
    begin
      f = a;
      b = a;
    end
  endfunction
  initial x = f(1'b1, x);
endmodule
