//! inherited IEEE 1364-2005 12.7
//! reject a constant expression is required here
// §12.7 does not settle whether w in `input [w-1:0] w;` names the port or the
// outer localparam; VerA refuses the ambiguity (br961).
module triage_function_port_range_scope_rejected;
  localparam w = 8;

  function [w-1:0] copy;
    input [w-1:0] w;
    begin
      copy = w;
    end
  endfunction
endmodule
