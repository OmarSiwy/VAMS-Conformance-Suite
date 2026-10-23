// IEEE 1364-2005 §9.8.3, p. 142: "All variables shall be static; that is, a
// unique location exists for all variables, and leaving or entering blocks
// shall not affect the values stored in them. The block names give a means of
// uniquely identifying all variables at any simulation time."
//
//   begin : acc declares integer count and sets it to 15; after the block is
//   left, the enclosing code reads it through the block's name: acc.count
//   -> "15". A second process reads the same location as
//   b_9_8_3_block_name_reference.acc.count at t=1 -> "15".
//! inherited IEEE 1364-2005 9.8.3
`timescale 1ns/1ns
module b_9_8_3_block_name_reference;
  initial begin
    begin : acc
      integer count;
      count = 15;
    end
    $display("%0d", acc.count);
  end

  initial #1 begin
    $display("%0d", b_9_8_3_block_name_reference.acc.count);
    $finish(0);
  end
endmodule
