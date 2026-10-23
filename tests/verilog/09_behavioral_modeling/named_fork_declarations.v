// IEEE 1364-2005 §9.8.3, pp. 141-142: "Both sequential and parallel blocks can be
// named by adding : name_of_block after the keywords begin or fork. The naming
// of blocks serves several purposes: — It allows local variables, parameters,
// and named events to be declared for the block." ... p. 142: "All variables
// shall be static; that is, a unique location exists for all variables, and
// leaving or entering blocks shall not affect the values stored in them."
// §9.8.2, p. 141 (Syntax 9-14): "par_block ::= fork [ : block_identifier {
// block_item_declaration } ] { statement } join".
//
//   fork : par declares reg [3:0] v (starts x), sets it to 9 and is left.
//   Entered again, it adds 1 to the kept value 9 -> 10; after the repeat the
//   block is read by name from outside, par.v -> "10" (the only line printed).
//! inherited IEEE 1364-2005 9.8.2 9.8.3
module b_9_8_3_named_fork_declarations;
  initial begin
    repeat (2) fork : par
      reg [3:0] v;
      v = (v === 4'bx) ? 4'd9 : v + 4'd1;
    join
    $display("%0d", par.v);
    $finish(0);
  end
endmodule
