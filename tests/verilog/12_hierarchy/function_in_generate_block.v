//! inherited IEEE 1364-2005 12.4 A.1.4
// A function declaration is a module_or_generate_item_declaration and is
// legal inside a generate block (generate_case2).
module triage_function_in_generate_block;
  wire [2:0] value;
  parameter select = 1;

  generate
    case (select)
      0: begin
        function [2:0] funfun;
          input integer in;
          funfun = in;
        endfunction
        assign value = funfun(select);
      end
      1: begin
        function [2:0] funfun;
          input integer in;
          funfun = in;
        endfunction
        assign value = funfun(1);
      end
      default: assign value = 7;
    endcase
  endgenerate

  initial #1 if (value === 3'd1) $display("PASSED"); else $display("FAILED %b", value);
endmodule
