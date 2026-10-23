//! inherited IEEE 1364-2005 10.4.5
// A constant function may contain a named block (constfunccall1).
module triage_constant_function_named_block;
  function integer f1(input integer i);
    begin
      f1 = i + 1;
    end
  endfunction

  function integer f2(input integer i);
    begin : b2
      f2 = f1(i);
    end
  endfunction

  localparam p = f2(1);

  initial begin
    if (p === 2)
      $display("PASSED");
    else
      $display("FAILED %0d", p);
  end
endmodule
