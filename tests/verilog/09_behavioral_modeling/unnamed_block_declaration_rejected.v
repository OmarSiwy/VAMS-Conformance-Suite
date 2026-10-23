// IEEE 1364-2005 §9.8.1, p. 140 (Syntax 9-13): "seq_block ::= begin [ :
// block_identifier { block_item_declaration } ] { statement } end".
// §9.8.3, pp. 141-142: "Both sequential and parallel blocks can be named by adding
// : name_of_block after the keywords begin or fork. The naming of blocks serves
// several purposes: — It allows local variables, parameters, and named events
// to be declared for the block."
//
// A block_item_declaration can follow only `: block_identifier`; here `reg r;`
// opens an unnamed begin-end block. Legal neighbour:
// named_block_variables.v declares integer count in `begin : acc`.
// The code moved 2026-10-08 with the refusal unchanged: E0209 ("expected an
// expression", A.8.3) became E0290, A.6.3's own "a declaration in an unnamed
// block", which the analog parse now reports too.
//! inherited IEEE 1364-2005 9.8.1 9.8.3
//! reject E0290
//! reject found `reg`
//! neighbour named_block_variables.v
module b_9_8_1_unnamed_block_declaration_rejected;
  initial begin
    reg r;
    r = 1'b1;
  end
endmodule
