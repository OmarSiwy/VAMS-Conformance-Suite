// IEEE 1364-2005 A.2.6, p. 492:
//   function_range_or_type ::= [ signed ] [ range ] | integer | real | realtime | time
// §10.4.2, p. 154 (quoted for context): "The function definition shall
// implicitly declare a variable, internal to the function, with the same name
// as the function. This variable either defaults to a 1-bit reg or is the same
// type as the type specified in the function declaration."
//
// half is a real function, rt a realtime one; each returns its internal real
// variable: half(3) = 3 / 2.0 = 1.5, rt(2) = 2 + 0.25 = 2.25.
// Output: "half=1.50 rt=2.25".
//! inherited IEEE 1364-2005 A.2.6
// native-required
module b_A_2_6_real_functions;
  function real half(input integer n);
    half = n / 2.0;
  endfunction
  function realtime rt(input integer n);
    rt = n + 0.25;
  endfunction
  initial begin
    $display("half=%.2f rt=%.2f", half(3), rt(2));
    $finish(0);
  end
endmodule
