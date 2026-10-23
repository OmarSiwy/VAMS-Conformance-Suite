// IEEE 1364-2005 §3.8, p. 16: "An attribute_instance can appear in the
// Verilog description as a prefix attached to a declaration, a module item,
// a statement, or a port connection." Annex A.6.3: `par_block ::= fork
// [ : block_identifier { block_item_declaration } ] { statement } join`, and
// A.6.4 `statement ::= { attribute_instance } ...`: an instance inside the
// block prefixes the statement after it.
//
// The (* a *) below comes after the block's only statement and right before
// `join`: no statement follows it for it to prefix. That is E0207 ("an
// attribute instance prefixes nothing"), as before `endmodule` or end of file
// (dangling_attribute_rejected.v). Before #66 the block's statement
// loop took it for the start of a statement and refused `join` as E0209
// "expected an expression". A parse error stops the run before elaboration,
// so E0207 is the only error.
//
// Legal neighbour: block_statement_attribute.v, whose `fork` block
// has the same instance prefixing its statements.
//! inherited IEEE 1364-2005 3.8.2
//! reject-only E0207
//! neighbour block_statement_attribute.v
module b_3_8_2_par_block_attribute_before_join_rejected;
  integer v;
  initial fork
    v = 1;
    (* a *)
  join
endmodule
