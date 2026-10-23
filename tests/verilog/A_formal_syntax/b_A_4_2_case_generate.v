// IEEE 1364-2005 A.4.2, p. 496:
//   case_generate_construct ::= case ( constant_expression ) case_generate_item
//     { case_generate_item } endcase
//   case_generate_item ::= constant_expression { , constant_expression } : generate_block_or_null
//     | default [ : ] generate_block_or_null
//   generate_block_or_null ::= generate_block | ;
//
// case (N) with N = 3: an item of two expressions (1, 2), an item 3 whose
// generate_block is a named begin-end, an item 4 that is null (`;`), and a
// default without its colon. N = 3 picks the named block: c = 3.
// Output: "c=3".
//! inherited IEEE 1364-2005 A.4.2
`timescale 1ns/1ns
module b_A_4_2_case_generate;
  parameter N = 3;
  wire [1:0] c;
  case (N)
    1, 2: assign c = 2'd1;
    3: begin : three
      assign c = 2'd3;
    end
    4: ;
    default assign c = 2'd0;
  endcase
  initial #1 begin
    $display("c=%0d", c);
    $finish(0);
  end
endmodule
