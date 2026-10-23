// IEEE1364-2005 10.4.1/10.4.2 printed153-154: default return
// variable is one bit; explicit range controls return width; the implied
// function-name variable may be read in expressions inside its function.
// scalar(2)->0, scalar(3)->1. staged(3): assign3 then3+2 ->5 (0101).
// Separate statements avoid unspecified function argument evaluation order.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.4.1
//! inherited IEEE 1364-2005 10.4.2
//! expect stdout function_return_variable.expected.txt
module audit_function_return_variable;
  reg first,second;
  reg [3:0] third;
  function scalar(input [3:0] x);
    scalar=x;
  endfunction
  function [3:0] staged(input [3:0] x);
    begin staged=x; staged=staged+4'd2; end
  endfunction
  initial begin
    first=scalar(4'd2); second=scalar(4'd3); third=staged(4'd3);
    $display("returns %b %b %b",first,second,third);
    $finish(0);
  end
endmodule
