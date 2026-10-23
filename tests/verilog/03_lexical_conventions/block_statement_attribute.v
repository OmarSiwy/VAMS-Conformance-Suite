// IEEE 1364-2005 §3.8, p. 16: "An attribute_instance can appear in the
// Verilog description as a prefix attached to a declaration, a module item,
// a statement, or a port connection." A.6.3 `seq_block ::= begin ...
// { statement } end` and `par_block ::= fork ... { statement } join`, with
// A.6.4 `statement ::= { attribute_instance } ...`: an instance may prefix
// every statement of either block.
//
// Legal neighbour of seq_block_attribute_before_end_rejected.v and
// par_block_attribute_before_join_rejected.v: the same (* k *) now
// prefixes a statement in each block. §3.8 standardizes no attribute, so each
// statement runs as if it were absent:
//   begin: a = 1, then b = a + 1 -> 2
//   fork: a = a + 10 -> 11 and b = b + 20 -> 22; each arm writes its own
//   variable and reads only it, so the arms' order changes nothing (§9.8.2)
//   after the join: displays "a 11 b 22"
// Printed: "a 11 b 22".
//! inherited IEEE 1364-2005 3.8.2
module b_3_8_2_block_statement_attribute;
  integer a, b;
  initial begin
    (* k *) a = 1;
    (* k *) b = a + 1;
    fork
      (* k *) a = a + 10;
      (* k *) b = b + 20;
    join
    (* k *) $display("a %0d b %0d", a, b);
  end
endmodule
