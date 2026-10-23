// IEEE 1364-2005 A.4.2, p. 495-496:
//   generate_region ::= generate { module_or_generate_item } endgenerate
//   genvar_declaration ::= genvar list_of_genvar_identifiers ;
//   list_of_genvar_identifiers ::= genvar_identifier { , genvar_identifier }
//   loop_generate_construct ::= for ( genvar_initialization ; genvar_expression ; genvar_iteration )
//     generate_block
//   genvar_initialization ::= genvar_identifier = constant_expression
//   genvar_expression ::= genvar_primary | unary_operator { attribute_instance } genvar_primary
//     | genvar_expression binary_operator { attribute_instance } genvar_expression
//     | genvar_expression ? { attribute_instance } genvar_expression : genvar_expression
//   genvar_iteration ::= genvar_identifier = genvar_expression
//   genvar_primary ::= constant_primary | genvar_identifier
//   conditional_generate_construct ::= if_generate_construct | case_generate_construct
//   if_generate_construct ::= if ( constant_expression ) generate_block_or_null
//     [ else generate_block_or_null ]
//   case_generate_construct ::= case ( constant_expression ) case_generate_item { case_generate_item } endcase
//   case_generate_item ::= constant_expression { , constant_expression } : generate_block_or_null
//     | default [ : ] generate_block_or_null
//   generate_block ::= module_or_generate_item
//     | begin [ : generate_block_identifier ] { module_or_generate_item } end
//   generate_block_or_null ::= generate_block | ;
//
// Every production but case_generate_construct and case_generate_item
// (b_A_4_2_case_generate.v). With parameter N = 3:
//   genvar i, j: a list of two genvar identifiers.
//   The loop runs i = 0, 2 (i < N + 1, i = i + 2) with a named generate_block
//   holding a nested loop over j = 0 only (j < (i ? 1 : 1), a ?: in a
//   parenthesized genvar_primary); in it an if generate assigns r0 = 1 when i == 0 and r2 = 1
//   otherwise.
//   if (N > 2) with a bare module_or_generate_item and an empty else (`;`):
//     p = 1.
//   if (-N > 0), a unary operator in the condition, is false (-3 > 0) and its
//     else arm is `;`: nothing drives q, which stays z.
// Output: "r0=1 r2=1 p=1 q=z".
//! inherited IEEE 1364-2005 A.4.2
`timescale 1ns/1ns
module b_A_4_2_generate_constructs;
  parameter N = 3;
  wire r0, r2, p, q;
  genvar i, j;
  generate
    for (i = 0; i < N + 1; i = i + 2) begin : outer
      for (j = 0; j < (i ? 1 : 1); j = j + 1) begin : inner
        if (i == 0) assign r0 = 1'b1;
        else assign r2 = 1'b1;
      end
    end
  endgenerate
  if (N > 2) assign p = 1'b1;
  else ;
  if (-N > 0) assign q = 1'b1;
  else ;
  initial #1 begin
    $display("r0=%b r2=%b p=%b q=%b", r0, r2, p, q);
    $finish(0);
  end
endmodule
