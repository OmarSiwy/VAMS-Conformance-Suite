// IEEE 1364-2005 §20.3 design for task_as_function.c: the built-in
// name $random, which the application registers as a system task, called as
// a function.
module b20_3;
  integer x;
  initial begin
    x = $random;
    $display("unreachable");
  end
endmodule
