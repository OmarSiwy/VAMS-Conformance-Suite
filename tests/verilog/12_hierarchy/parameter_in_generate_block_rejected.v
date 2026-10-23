// IEEE 1364-2005 §12.4, p. 181: "A generate block may not contain port
// declarations, parameter declarations, specify blocks, or specparam
// declarations." Syntax 12-5 (p. 182) makes it a syntax error: a
// generate_block holds module_or_generate_items, which include
// local_parameter_declaration but no parameter_declaration.
//
// Block g declares parameter P. Legal neighbour:
// generate_region_optional.v (generate blocks of always blocks and
// nested generate constructs).
//! lrm 6.6
//! lrm 6.6:1
//! inherited IEEE 1364-2005 12.4
//! reject E0229
//! reject a parameter declaration inside a generate region or block
//! neighbour generate_region_optional.v
module b_12_4_parameter_in_generate_block_rejected;
  generate
    if (1) begin : g
      parameter P = 1;
    end
  endgenerate
endmodule
