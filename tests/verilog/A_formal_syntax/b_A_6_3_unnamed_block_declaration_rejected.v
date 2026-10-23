// IEEE 1364-2005 A.6.3, p. 497-498:
//   par_block ::= fork [ : block_identifier { block_item_declaration } ] { statement } join
//   seq_block ::= begin [ : block_identifier { block_item_declaration } ] { statement } end
// The block_item_declarations sit inside the bracket that begins with
// `: block_identifier`: only a named block declares anything.
//
// `begin integer k; ... end` declares in an unnamed block. Legal neighbour:
// b_A_6_3_named_block_declarations.v (`begin : blk integer k; ... end`).
// The code moved 2026-10-08 with the refusal unchanged: E0209 ("expected an
// expression", A.8.3) became E0290, A.6.3's own "a declaration in an unnamed
// block", which the analog parse now reports too.
//! lrm A.6.3
//! lrm A.6.3:1000
//! inherited IEEE 1364-2005 A.6.3
//! reject E0290
//! neighbour b_A_6_3_named_block_declarations.v
module b_A_6_3_unnamed_block_declaration_rejected;
  initial begin
    integer k;
    k = 1;
    $display("unreachable %0d", k);
  end
endmodule
