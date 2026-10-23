// IEEE 1364-2005 A.7.1, p. 500:
//   specify_block ::= specify { specify_item } endspecify
//   specify_item ::= specparam_declaration | pulsestyle_declaration
//     | showcancelled_declaration | path_declaration | system_timing_check
// A specify block holds these five items and nothing else.
//
// A continuous assignment inside a specify block is none of them. Legal
// neighbour: b_A_7_1_specify_block.v, whose assignments are outside it.
//! inherited IEEE 1364-2005 A.7.1
//! reject E0207
//! reject which begins no A.7.1 specify_item
//! neighbour b_A_7_1_specify_block.v
module b_A_7_1_statement_in_specify_rejected (a, y);
  input a;
  output y;
  specify
    assign y = a;
  endspecify
endmodule
