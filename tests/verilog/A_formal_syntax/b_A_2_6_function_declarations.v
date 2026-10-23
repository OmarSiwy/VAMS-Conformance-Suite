// IEEE 1364-2005 A.2.6, p. 492:
//   function_declaration ::=
//       function [ automatic ] [ function_range_or_type ] function_identifier ;
//         function_item_declaration { function_item_declaration }
//         function_statement endfunction
//     | function [ automatic ] [ function_range_or_type ] function_identifier ( function_port_list ) ;
//         { block_item_declaration } function_statement endfunction
//   function_item_declaration ::= block_item_declaration | { attribute_instance } tf_input_declaration ;
//   function_port_list ::= { attribute_instance } tf_input_declaration { , { attribute_instance } tf_input_declaration }
//   function_range_or_type ::= [ signed ] [ range ] | integer | real | realtime | time
//
// Five functions, covering both declaration forms, automatic, and every
// function_range_or_type but real and realtime (b_A_2_6_real_functions.v):
//   add   (form 1, no range: 1 bit)   add(1, 1) = 1 + 1 = 2, truncated to 1 bit -> 0
//   neg   (form 2, signed [3:0])       neg(4'd3) = -3 -> %0d -3
//   fact  (automatic, integer, recursive) fact(5) = 120
//   tm    (time)                       tm(7) = 7 * 2 = 14
//   cnt   (form 1 with a block_item_declaration integer k beside its input)
//         cnt(3'b101) counts the ones = 2
// Output: "add=0 neg=-3 fact=120 tm=14 cnt=2".
//! inherited IEEE 1364-2005 A.2.6
module b_A_2_6_function_declarations;
  function add;
    input a, b;
    add = a + b;
  endfunction
  function signed [3:0] neg(input [3:0] v);
    neg = -v;
  endfunction
  function automatic integer fact(input integer n);
    fact = (n <= 1) ? 1 : n * fact(n - 1);
  endfunction
  function time tm(input [3:0] n);
    tm = n * 2;
  endfunction
  function [1:0] cnt;
    input [2:0] v;
    integer k;
    begin
      cnt = 0;
      for (k = 0; k < 3; k = k + 1) cnt = cnt + v[k];
    end
  endfunction
  initial begin
    $display("add=%0d neg=%0d fact=%0d tm=%0d cnt=%0d",
             add(1'b1, 1'b1), neg(4'd3), fact(5), tm(4'd7), cnt(3'b101));
    $finish(0);
  end
endmodule
