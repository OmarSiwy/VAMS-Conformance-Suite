// IEEE 1364-2005 A.6.3, p. 498:
//   seq_block ::= begin [ : block_identifier { block_item_declaration } ] { statement } end
// A.2.8, p. 493: block_item_declaration ::=
//   { attribute_instance } reg [ signed ] [ range ] list_of_block_variable_identifiers ; | ...
//
// A named block declaring reg [3:0] r: r = 4'd12 -> "r=12".
//! inherited IEEE 1364-2005 A.6.3
module b_A_6_3_named_block_reg;
  initial begin : blk
    reg [3:0] r;
    r = 4'd12;
    $display("r=%0d", r);
    $finish(0);
  end
endmodule
