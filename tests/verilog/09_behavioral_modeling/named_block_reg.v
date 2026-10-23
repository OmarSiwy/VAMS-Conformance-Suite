// IEEE 1364-2005 §9.8.3, pp. 141-142: "Both sequential and parallel blocks can
// be named by adding : name_of_block after the keywords begin or fork. The
// naming of blocks serves several purposes: — It allows local variables,
// parameters, and named events to be declared for the block." ... "All
// variables shall be static; that is, a unique location exists for all
// variables, and leaving or entering blocks shall not affect the values
// stored in them." Syntax 9-13/9-14 put { block_item_declaration } after the
// block name, and A.2.8 block_item_declaration ::= { attribute_instance } reg
// [ signed ] [ range ] list_of_block_variable_identifiers ; | ...
//
//   begin : seq declares reg [3:0] v and reg signed [7:0] s, both x on the
//   first entry. Each of the three entries sets v to 1 when it is x, else
//   doubles it (1, 2, 4), and s = -v (-1, -2, -4, signed, so %0d prints the
//   sign).
//   fork : par declares reg [1:0] w: the first entry sets it to 3, the
//   second, seeing the kept 3, to 0 -> printed "3" then "0".
// (Reading these by the block's name: named_fork_declarations.v.)
//! inherited IEEE 1364-2005 9.8.3
module b_9_8_3_named_block_reg;
  initial begin
    repeat (3) begin : seq
      reg [3:0] v;
      reg signed [7:0] s;
      v = (v === 4'bx) ? 4'd1 : v * 2;
      s = -v;
      $display("%0d %0d", v, s);
    end
    repeat (2) fork : par
      reg [1:0] w;
      begin
        w = (w === 2'bx) ? 2'd3 : 2'd0;
        $display("%0d", w);
      end
    join
    $finish(0);
  end
endmodule
